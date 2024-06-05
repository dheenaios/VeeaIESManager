//
//  ApiImpl+HubApi.swift
//  IESManager
//
//  Created by Richard Stockdale on 04/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

// MARK: - Hub Api extensions for API
extension APIImpl {
    func getCellularStatsHubApi(connection: VeeaHubConnection,
                                completion: @escaping CellularStatsDelegate) {
        setConfig(connection: connection, config: CellularStatsTrigger()) { (result, error) in
            let config = HubApiGetConfigRequest(tableName: CellularStats.getTableName(), keys: [String]())
            let requester = HubApiRequester.shared
            
            let delay = DispatchTime.now() + .milliseconds(400)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                requester.sendRequest(connection: connection,
                                      config: config) { (response) in
                    if let model = CellularStats.cellularStatsFrom(response: response) {
                        completion(model, response.error)
                    }
                    else {
                        completion(nil, response.error)
                    }
                }
            }
        }
    }
    
    func getNodeConfigHubApi(connection: VeeaHubConnection,
                             completion: @escaping NodeConfigDelegate) {
        let config = HubApiGetConfigRequest(tableName: NodeConfig.getTableName(), keys: NodeConfig.getAllKeys())
        HubApiRequester.shared.sendRequest(connection: connection,
                                           config: config) { (response) in
            guard let responseBody = response.responseBody else {
                completion(nil, response.error)
                return
            }
            
            if let model = responseBody[NodeConfig.getTableName()] {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try JSONSerialization.data(withJSONObject: model, options: .prettyPrinted)
                    var nodeConfig = try decoder.decode(NodeConfig.self, from: jsonData)
                    nodeConfig.originalJson = model
                    
                    completion(nodeConfig, response.error)
                }
                catch {
                    Logger.logDecodingError(className: "NodeConfig", tag: "ApiImpl", error: error)
                    completion(nil, response.error)
                }
            }
            else {
                completion(nil, response.error)
            }
        }
    }

    func getNodeStatusHubApi(connection: VeeaHubConnection,
                             completion: @escaping NodeStatusDelegate) {
        let config = HubApiGetConfigRequest(tableName: NodeStatus.getTableName(), keys: NodeStatus.getAllKeys())
        HubApiRequester.shared.sendRequest(connection: connection,
                                           config: config) { (response) in
            guard let responseBody = response.responseBody else {
                completion(nil, response.error)
                return
            }

            if let model = responseBody[NodeStatus.getTableName()] {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try JSONSerialization.data(withJSONObject: model, options: .prettyPrinted)
                    var nodeStatus = try decoder.decode(NodeStatus.self, from: jsonData)
                    nodeStatus.originalJson = model

                    completion(nodeStatus, response.error)
                }
                catch {
                    Logger.logDecodingError(className: "nodeStatus", tag: "ApiImpl", error: error)
                    completion(nil, response.error)
                }
            }
            else {
                completion(nil, response.error)
            }
        }
    }
    
    func getWifiStatsHubApi(connection: VeeaHubConnection,
                            completion: @escaping WifiStatsDelegate) {
        setConfig(connection: connection, config: WifiStatsTrigger()) { (result, error) in
            let delay = DispatchTime.now() + .milliseconds(400)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                let config = HubApiGetConfigRequest(tableName: WifiStats.getTableName(), keys: WifiStats.getAllKeys())
                HubApiRequester.shared.sendRequest(connection: connection, config: config) { (response) in
                    if let model = WifiStats.wifiStatsFrom(response: response) {
                        completion(model, response.error)
                    }
                    else {
                        completion(nil, response.error)
                    }
                }
            }
        }
    }
    
    func getAcsScanReportHubApi(connection: VeeaHubConnection,
                                completion: @escaping AcsScanReportDelegate) {
        let config = HubApiGetConfigRequest(tableName: DbAcsScanReport.TableName, keys: [String]())
        HubApiRequester.shared.sendRequest(connection: connection, config: config) { (response) in
            guard let responseBody = response.responseBody else {
                completion(nil, response.error)
                return
            }
            
            if let json = responseBody[DbAcsScanReport.TableName] {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    var acsScanReport = try decoder.decode(AcsScanReport.self, from: jsonData)
                    acsScanReport.originalJson = json
                    completion(acsScanReport, response.error)
                }
                catch {
                    Logger.logDecodingError(className: "AcsScanReport", tag: "ApiImpl", error: error)
                    completion(nil, response.error)
                }
            }
            else {
                completion(nil, response.error)
            }
        }
    }

    func getWdsScanReportHubApi(connection: VeeaHubConnection,
                                completion: @escaping WdsScanReportDelegate) {
        let config = HubApiGetConfigRequest(tableName: WdsScanReport.tableName, keys: [String]())
        HubApiRequester.shared.sendRequest(connection: connection, config: config) { (response) in
            guard let responseBody = response.responseBody else {
                completion(nil, response.error)
                return
            }

            if let json = responseBody[WdsScanReport.tableName] {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    var wdsScanReport = try decoder.decode(WdsScanReport.self, from: jsonData)
                    wdsScanReport.originalJson = json
                    completion(wdsScanReport, response.error)
                }
                catch {
                    Logger.logDecodingError(className: "wdsScanReport", tag: "ApiImpl", error: error)
                    completion(nil, response.error)
                }
            }
            else {
                completion(nil, response.error)
            }
        }
    }
    
    func makeCallToDBNamedHubApi(dbName: String,
                                 connection: VeeaHubConnection,
                                 completion: @escaping SecureRequestResponceDelegate) {
        let config = HubApiGetConfigRequest(tableName: dbName, keys: [String]())
        HubApiRequester.shared.sendRequest(connection: connection, config: config) { (response) in
            completion(response)
        }
    }
    
    func refreshTimeHubApi(connection: VeeaHubConnection, _
                           completion: @escaping RefreshTimeDelegate) {
        let config = HubApiGetConfigRequest(tableName: HubTime.getTableName(), keys: HubTime.getAllKeys())
        HubApiRequester.shared.sendRequest(connection: connection,
                                           config: config) { (response) in
            if let model = HubTime(response: response) {
                
                var keys = config.getKeys()
                keys.append(DbNodeInfo.NodeTimeTrigger)
                
                var values = [Any]()
                values.append(model.node_time)
                values.append(true)
                
                let updateConfig = HubApiUpdateConfigRequest(tableName: HubTime.getTableName(),
                                                             keys: keys,
                                                             values: values)
                
                HubApiRequester.shared.sendUpdateRequest(connection: connection,
                                                         config: updateConfig,
                                                         response: { (updateResponse) in
                    
                    completion(model, updateResponse.error)
                })
            }
            else {
                completion(nil, response.error)
            }
        }
    }
    
    func updateTimeHubApi(newUtcTime: String,
                          connection: VeeaHubConnection,
                          completion: @escaping Delegate) {
        let updateConfig = HubApiUpdateConfigRequest(tableName: DbNodeInfo.TableName,
                                                     keys: [DbNodeInfo.NodeTime],
                                                     values: [newUtcTime])
        
        HubApiRequester.shared.sendUpdateRequest(connection: connection,
                                                 config: updateConfig,
                                                 response: { (updateResponse) in
            if let error = updateResponse.error {
                completion(nil, error)
                return
            }
            
            completion(nil, nil)
        })
    }
    
    func sendConfigViaHubApi(config: ApiRequestConfigProtocol,
                             connection: VeeaHubConnection,
                             completion: @escaping Delegate) {
        let update = getUpdate(config: config)
        HubApiRequester.shared.sendUpdateRequest(connection: connection,
                                                 config: update,
                                                 response: { (updateResponse) in
            if let error = updateResponse.error {
                completion(nil, error)
                return
            }
            
            completion(nil, nil)
        })
    }
    
    /// Get an update for the Hub API. Just the changed objects
    /// - Parameter config: The config to send. Must conform to JSONResponse and ApiRequestConfigProtocol protocols.
    /// - Returns: The diffed json. OR the full json if diffing fails
    fileprivate func getUpdate(config: ApiRequestConfigProtocol) -> HubApiUpdateConfigRequest {
        let fullUpdate = HubApiUpdateConfigRequest(json: config.getHubApiUpdateJSON())
        
        var original: JSON?
        if let c = config as? TopLevelJSONResponse { original = c.originalJson }
        
        guard var o = original else {
            return fullUpdate
        }
        
        let u = config.getHubApiUpdateJSON()
        if u.keys.count != 1 { return HubApiUpdateConfigRequest(json: config.getHubApiUpdateJSON()) }
        
        guard let tableName = u.keys.first else { return fullUpdate }
        guard var updatedJson = u[tableName] else { return fullUpdate }
        if updatedJson.isEmpty { return fullUpdate }
        
        // Remove _id and _rev keys
        o.removeValue(forKey: "_rev")
        o.removeValue(forKey: "_id")
        updatedJson.removeValue(forKey: "_rev")
        updatedJson.removeValue(forKey: "_id")

        do {
            let diff = try JsonDiffer.diffJson(original: o, target: updatedJson)

            var diffedJson = SecureUpdateJSON()
            diffedJson[tableName] = diff

            // If the diff is empty the no changes
            return HubApiUpdateConfigRequest(json: diffedJson)
        }
        catch {
            return fullUpdate
        }
    }
}
