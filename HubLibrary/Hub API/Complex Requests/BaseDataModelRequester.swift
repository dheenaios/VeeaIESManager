//
//  CoreDataModel.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 26/04/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

class BaseDataModelRequester: HubApiRequester {
    
    private static let tag = "BaseDataModelRequester"
    
    private var responseCallBack: HubBaseDataModelDelegate?
    
    public func getRequireDataModel(connection: VeeaHubConnection,
                                    completion: @escaping HubBaseDataModelDelegate) {
        responseCallBack = completion
        
        validateUpdateToken(connection: connection) { (success, description) in
            if success {
                self.sendComplexRequest(connection: connection)
            }
            else {
                var d = "No error description"
                if let description = description {
                    d = description
                }
                
                completion(nil, APIError.Failed(message: d))
            }
        }
    }
    
    private func sendComplexRequest(connection: VeeaHubConnection) {
        var request = SecureURLRequestFactory.getBasePutRequest(connection: connection)
        let json = createCallJSON()
        if let jsonData = createJSONData(requestJSON: json) {
            request?.httpBody = jsonData
        }
        
        if let request = request {
            makeDataRequest(request: request) { (response) in
                self.processRequestResponse(response: response)
            }
            
            return
        }
        
        if let completion = responseCallBack {
            completion(nil, APIError.Failed(message: "Could not create BaseDataModel request"))
        }
    }
    
    public static var tableNames: [String] {
        let tableNames = [DbNodeConfig.TableName,
                          DbNodeWanConfig.TableName,
                          DbMeshLanConfig.TableName,
                          DbApConfig.TableNameMesh,
                          DbApConfig.TableNameNode,
                          DbNodeCapabilities.TableName,
                          DbNodeControl.TableName,
                          DbNodeInfo.TableName,
                          DbNodeStatus.TableName,
                          DbNodeServices.TableName,
                          DbNodeApStatus.TableName,
                          NodePortInfoConfig.getTableName(),
                          DbNodeVLanConfig.TableName,
                          DbMeshVLanConfig.TableName]

        return tableNames
    }
    
    // Only used in HubApi calls. MAS just calls the table
    public static func propsForTable(tableName: String) -> [String] {
        switch tableName {
        case DbNodeConfig.TableName:
            return NodeConfig.getAllKeys()
        case DbNodeWanConfig.TableName:
            return NodeWanConfig.getAllKeys()
        case DbMeshLanConfig.TableName:
            return MeshLanConfig.getAllKeys()
        case DbApConfig.TableNameMesh:
            return AccessPointsConfig.getAllKeys()
        case DbApConfig.TableNameNode:
            return AccessPointsConfig.getAllKeys()
        case DbNodeCapabilities.TableName:
            return AccessPointsConfig.getAllKeys()
        case DbNodeControl.TableName:
            return NodeControlConfig.getAllKeys()
        case DbNodeInfo.TableName:
            return NodeInfo.getAllKeys()
        case DbNodeStatus.TableName:
            return NodeStatus.getAllKeys()
        default:
            return [String]()
        }
    }
}

// MARK: - Model Processing
extension BaseDataModelRequester {
    private func processRequestResponse(response: RequestResponce) {
        guard let responseBody = response.responseBody else {
            
            if let completion = responseCallBack {
                completion(nil, APIError.Failed(message: "BaseDataModel response body was empty"))
            }
            
            return
        }
        
        let model = HubBaseDataModel.init(from: responseBody)
        if let completion = responseCallBack {
            completion(model, nil)
        }
    }
}


// MARK: - Request Creation
extension BaseDataModelRequester {
    // Gets all keys
    private func createCallJSON() -> [String : [String]] {
        var hash = [String : [String]]()
        
        for table in BaseDataModelRequester.tableNames {
            hash[table] = BaseDataModelRequester.propsForTable(tableName: table)
        }
        
        return hash
    }
}
