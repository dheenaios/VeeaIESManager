//
//  OptionalDataModelAppsRequester.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 29/04/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

public enum KnownApps: String {
    case publicWifi = "public_wifi"
    case sdWan = "sd_wan"
    case ports = "ports"
    case legacyLanAndStaticTables = "legacyLanAndStaticTables"
    case lanAndStaticTables = "lanAndStaticTables" //  See VHM-141
    case wanStaticIps = "wanStaticIps"
    case node_lan_status = "node_lan_status"
    case enhancedSecuritySupported = "enhancedSecuritySupported"
    case MeshWdsTopologyConfig = "MeshWdsTopologyConfig"
}

class OptionalDataModelAppsRequester: HubApiRequester {
    
    private static let tag = "OptionalDataModelAppsRequester"
    private var responseCallBack: HubOptionalAppsDataModelDelegate?
    
    private var appKeys: [String]?
    
    public static var publicWifiTables: [String] {
        let tableNames = [DbPublicWifiInfo.TableName,
                          DbPublicWifiOperator.TableName,
                          DbPublicWifiSettings.TableName]
        return tableNames
    }
    
    public static var sdWanTables: [String] {
        let tableNames = [DbNodeSdWan.TableName, DbCellularDataCount.TableName]
    
        return tableNames
    }
    
    public static var ethernetPortTables: [String] {
        let tableNames = [DbNodePortConfig.TableName,
                          DbMeshPortConfig.TableName,
                          DbNodePortStatus.TableName]
        return tableNames
    }
    
    public static var wanStaticIpTables: [String] {
        let tableNames = [DbNodeWanStaticIp.TableName]
        return tableNames
    }
    
    public static var legacyLanAndStaticTables: [String] {
        let tableNames = [DbNodeLanStaticIp.TableName]
        return tableNames
    }
    
    public static var nodeLanStatus: [String] {
        let tableNames = [DbNodeLanStatus.TableName]
        return tableNames
    }
    
    public static var LanAndStaticTables: [String] {
        let tableNames = [DbNodeLanStaticIp.TableName,
                          DbNodeLanConfig.TableName]
        return tableNames
    }
    
    public static var radiusServerTable: [String] {
        let tableNames = [DbMeshRadiusConfig.TableName]
        return tableNames
    }

    public static var meshWdsTopologyTable: [String] {
        let tableNames = [MeshWdsTopologyConfig.tableName]
        return tableNames
    }
    
    public func getInstalledAppModels(connection: VeeaHubConnection,
                                      installedAppManifest: InstalledAppsConfig,
                                      completion: @escaping HubOptionalAppsDataModelDelegate) {
        
        if installedAppManifest.installedAppKeys.isEmpty {
            completion(OptionalAppsDataModel(), nil)
        }
        
        appKeys = installedAppManifest.installedAppKeys
        
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
    }
}

// MARK: - Model Processing
extension OptionalDataModelAppsRequester {
    private func processRequestResponse(response: RequestResponce) {
        guard let responseBody = response.responseBody else {
            
            if let completion = responseCallBack {
                completion(nil, APIError.Failed(message: "OptionalAppsDataModel response body was empty"))
            }
            
            return
        }
        
        let model = OptionalAppsDataModel(from: responseBody)
        if let completion = responseCallBack {
            completion(model, nil)
        }
    }
}

// MARK: - Request Creation
extension OptionalDataModelAppsRequester {
    // Gets all keys
    private func createCallJSON() -> [String : [String]] {
        var hash = [String : [String]]()
        
        guard let appKeys = appKeys else {
            return hash
        }
        
        for app in appKeys {
            processManifestItem(appName: app, jsonHash: &hash)
        }
        
        return hash
    }
    
    private func processManifestItem(appName: String,  jsonHash: inout [String : [String]]) {
        switch appName {
        case KnownApps.publicWifi.rawValue:
            for table in OptionalDataModelAppsRequester.publicWifiTables {
                jsonHash[table] = [String]()
            }
        case KnownApps.sdWan.rawValue:
            for table in OptionalDataModelAppsRequester.sdWanTables {
                jsonHash[table] = [String]()
            }
        case KnownApps.ports.rawValue:
            for table in OptionalDataModelAppsRequester.ethernetPortTables {
                jsonHash[table] = [String]()
            }
        case KnownApps.legacyLanAndStaticTables.rawValue:
            for table in OptionalDataModelAppsRequester.legacyLanAndStaticTables {
                jsonHash[table] = [String]()
            }
        case KnownApps.node_lan_status.rawValue:
            for table in OptionalDataModelAppsRequester.nodeLanStatus {
                jsonHash[table] = [String]()
            }
        case KnownApps.lanAndStaticTables.rawValue:
            for table in OptionalDataModelAppsRequester.LanAndStaticTables {
                jsonHash[table] = [String]()
            }
        case KnownApps.wanStaticIps.rawValue:
            for table in OptionalDataModelAppsRequester.wanStaticIpTables {
                jsonHash[table] = [String]()
            }
        case KnownApps.enhancedSecuritySupported.rawValue:
            for table in OptionalDataModelAppsRequester.radiusServerTable {
                jsonHash[table] = [String]()
            }
        case KnownApps.MeshWdsTopologyConfig.rawValue:
            for table in OptionalDataModelAppsRequester.meshWdsTopologyTable {
                jsonHash[table] = [String]()
            }
        default:
            Logger.log(tag: OptionalDataModelAppsRequester.tag, message: "Unknown app: \(appName)")
        }
    }
}
