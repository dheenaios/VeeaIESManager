//
//  ConfigCalls.swift
//  MAS API
//
//  Created by Richard Stockdale on 30/08/2020.
//  Copyright © 2020 Richard Stockdale. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class MasApiGetConfigCalls {
    
    public typealias MasApiGetResult = ([MasApiCallResponse]?, APIError?) -> Void
    
    public var callResponses: [MasApiCallResponse]
    
    private var completion: MasApiGetResult?
    private let masConnection: MasConnection
    
    private struct RequestDetails {
        var tableName: String
        var request: URLRequest
    }
    
    /*
     The Node Config table populates the following configs:
     LockStatus NodeConfig BeaconConfig LocationConfig
     GatewayConfig AnalyticsConfig IpConfig
     RouterConfig VmeshConfig
     */
    private let tables = [NodeConfig.getTableName(),
                          NodeWanConfig.getTableName(),
                          MeshLanConfig.getTableName(),
                          NodeCapabilities.getTableName(),
                          NodeControlConfig.getTableName(),
                          NodeInfo.getTableName(),
                          NodeStatus.getTableName(),
                          InstalledAppsConfig.getTableName(),
                          MeshVLanConfig.getTableName(),
                          NodeVLanConfig.getTableName(),
                          PublicWifiSettingsConfig.getTableName(),
                          PublicWifiOperatorsConfig.getTableName(),
                          PublicWifiInfoConfig.getTableName(),
                          NodePortConfig.getTableName(),
                          MeshPortConfig.getTableName(),
                          NodePortStatusConfig.getTableName(),
                          NodeWanStaticIpConfig.getTableName(),
                          NodeLanConfigStaticIp.getTableName(),
                          NodeLanStaticIpConfig.getTableName(),
                          NodeLanConfig.getTableName(),
                          NodeLanStatusConfig.getTableName(),
                          SdWanConfig.getTableName(),
                          CellularDataStatsConfig.getTableName(),
                          AccessPointsConfig.getMeshTableName(),
                          AccessPointsConfig.getNodeTableName(),
                          MeshRadiusConfig.getTableName(),
                          NodeApStatus.getTableName(),
                          NodePortInfoConfig.getTableName(),
                          MeshWdsTopologyConfig.tableName]
    
    func makeCalls(completion: @escaping MasApiGetResult) {
        self.completion = completion
        
        callResponses = [MasApiCallResponse]()
        let requests = makeRequests()
        
        for request in requests {
            URLSession.sendDataWith(request: request.request) { result, error in
                guard let data = result.data else {
                    //print(String(describing: error))
                    var masResponse = MasApiCallResponse(nodeId: 0,
                                                         tableName: request.tableName,
                                                         json: nil,
                                                         data: nil)

                    masResponse.error = APIError.Failed(message: error?.localizedDescription ?? "No data")
                    self.callResponses.append(masResponse)

                    if self.callResponses.count == requests.count {
                        self.complete(errorText: nil)
                        //print("Done")
                    }

                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSON {
                    let masResponse = MasApiCallResponse(nodeId: self.masConnection.nodeId,
                                                         tableName: request.tableName,
                                                         json: json,
                                                         data: data,
                                                         error: nil)

                    self.callResponses.append(masResponse)
                }
                else {
                    var masResponse = MasApiCallResponse(nodeId: 0,
                                                         tableName: request.tableName,
                                                         json: nil,
                                                         data: data)

                    masResponse.error = APIError.Failed(message: "Error encoding JSON")
                    self.callResponses.append(masResponse)
                }

                if self.callResponses.count == requests.count {
                    self.complete(errorText: nil)
                }
            }
        }
    }
    
    private func complete(errorText: String?) {
        guard let completion = completion else {
            return
        }
        
        guard let errorText = errorText else {
            completion(callResponses, nil)
            return
        }
        
        completion(nil, APIError.Failed(message: errorText))
    }
    
    init(masConnection: MasConnection) {
        self.masConnection = masConnection
        self.callResponses = [MasApiCallResponse]()
    }
}

// MARK: - Make Requests
extension MasApiGetConfigCalls {
    
    private func makeRequests() -> [RequestDetails] {
        
        // Create the requests
        var requests = [RequestDetails]()
        
        for table in tables {
            let url = masConnection.urlFor(tableName: table)
            var request = URLRequest(url: URL(string: url)!, timeoutInterval: Double.infinity)
            request.addValue(AuthorisationManager.shared.formattedAuthToken!, forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            let requestDetail = RequestDetails(tableName: table, request: request)
            requests.append(requestDetail)
        }
        
        return requests
    }
}
