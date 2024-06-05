//
//  ApiImpl+Mas.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 14/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

// MARK: - Mas extensions for API
extension APIImpl {
    
    // MARK: - GET
    
    /// Get Base and Optional data models from the MAS API
    /// - Parameters:
    ///   - connection: The connection details
    ///   - completion: The completion handler
    func getMasApiIntermediaryModel(connection: MasConnection,
                                    completion: @escaping MasIntermediaryModelDelegate) {
        let masRequest = MasApiGetConfigCalls(masConnection: connection)
        masRequest.makeCalls { (responses, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let responses = responses else {
                completion(nil, APIError.Failed(message: "No responses returned from the MAS API".localized()))
                return
            }
            
            // Remove any document not found responses as these will crash in the configs if sent for init
            var presentResponses = [MasApiCallResponse]()
            for r in responses {
                if let json = r.json {
                    if let success = json["success"], let message = json["message"] {
                        Logger.log(tag: "MAS ApiImpl", message: "Got unexpected JSON with keys Success \(success) and message \(message), on table \(r.tableName)")
                        continue
                    }
                }
                
                presentResponses.append(r)
            }
            
            if responses.count != presentResponses.count {
                Logger.log(tag: "MAS ApiImpl", message: "There were \(responses.count - presentResponses.count) table that were not present")
            }
            
            
            let model = MasApiIntermediaryDataModel(responses: presentResponses)
            completion(model, nil)
        }
    }
    
    func getNodeConfigMas(connection: MasConnection,
                          completion: @escaping NodeConfigDelegate) {
        let config = MasSingleTableGet(masConnection: connection, tableName: NodeConfig.getTableName())
        config.makeCall { (result) in
            if (result.error != nil) {
                completion(nil, result.error)
                return
            }
            
            guard let json = result.json else {
                completion(nil, result.error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                var nodeConfig = try decoder.decode(NodeConfig.self, from: jsonData)
                nodeConfig.originalJson = json
                
                completion(nodeConfig, result.error)
            }
            catch {
                Logger.logDecodingError(className: "NodeConfig", tag: "NodeConfig", error: error)
                completion(nil, result.error)
            }
            
        }
    }

    func getNodeStatusMas(connection: MasConnection,
                          completion: @escaping NodeStatusDelegate) {
        let config = MasSingleTableGet(masConnection: connection, tableName: NodeStatus.getTableName())
        config.makeCall { (result) in
            if (result.error != nil) {
                completion(nil, result.error)
                return
            }

            guard let json = result.json else {
                completion(nil, result.error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                var nodeStatus = try decoder.decode(NodeStatus.self, from: jsonData)
                nodeStatus.originalJson = json

                completion(nodeStatus, result.error)
            }
            catch {
                Logger.logDecodingError(className: "NodeStatus", tag: "NodeStatus", error: error)
                completion(nil, result.error)
            }

        }
    }
    
    func getCellularStatsMas(connection: MasConnection,
                             completion: @escaping CellularStatsDelegate) {
        // Send cellular stats trigger
        sendConfigViaMas(connection: connection,
                         config: CellularStatsTrigger()) { (message, error) in
            let delay = DispatchTime.now() + .milliseconds(400)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                let config = MasSingleTableGet.init(masConnection: connection, tableName: CellularStats.getTableName())
                config.makeCall { (result) in
                    guard let json = result.json,
                          let data = result.data else {
                        completion(nil, result.error)
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(CellularStats.self, from: data)
                        model.originalJson = json
                        completion(model, nil)
                    }
                    catch {
                        Logger.logDecodingError(className: "CellularStats", tag: self.tag, error: error)
                        completion(nil, APIError.Failed(message: "Cellular Data was in an unexpected format"))
                    }
                }
            }
        }
    }
    
    func getWifiStatsMas(connection: MasConnection,
                         completion: @escaping WifiStatsDelegate) {
        sendConfigViaMas(connection: connection, config: WifiStatsTrigger()) { (message, error) in
            let delay = DispatchTime.now() + .milliseconds(400)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                let config = MasSingleTableGet(masConnection: connection, tableName: WifiStats.getTableName())
                config.makeCall { (result) in
                    if (result.error != nil) {
                        completion(nil, result.error)
                        return
                    }
                    
                    guard let json = result.json else {
                        completion(nil, result.error)
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                        let wifiStats = try decoder.decode(WifiStats.self, from: jsonData)
                        wifiStats.originalJson = json
                        completion(wifiStats, result.error)
                    }
                    catch {
                        Logger.logDecodingError(className: "wifiStats", tag: "ApiImpl+Mas", error: error)
                        completion(nil, result.error)
                    }
                }
            }
        }
    }
    
    func getAcsScanReportMas(connection: MasConnection,
                             completion: @escaping AcsScanReportDelegate) {
        let config = MasSingleTableGet(masConnection: connection, tableName: DbAcsScanReport.TableName)
        config.makeCall { (result) in
            if (result.error != nil) {
                completion(nil, result.error)
                return
            }
            
            guard let data = result.data else {
                completion(nil, result.error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                var model = try decoder.decode(AcsScanReport.self, from: data)
                
                if let json = result.json {
                    model.originalJson = json
                }
                
                completion(model, nil)
            }
            catch {
                Logger.logDecodingError(className: "AcsScanReport", tag: self.tag, error: error)
                completion(nil, APIError.Failed(message: error.localizedDescription))
            }
        }
    }

    func getWdsScanReportMas(connection: MasConnection,
                             completion: @escaping WdsScanReportDelegate) {
        let config = MasSingleTableGet(masConnection: connection, tableName: WdsScanReport.tableName)
        config.makeCall { (result) in
            if (result.error != nil) {
                completion(nil, result.error)
                return
            }

            guard let data = result.data else {
                completion(nil, result.error)
                return
            }

            do {
                let decoder = JSONDecoder()
                var model = try decoder.decode(WdsScanReport.self, from: data)

                if let json = result.json {
                    model.originalJson = json
                }

                completion(model, nil)
            }
            catch {
                Logger.logDecodingError(className: "WdsScanReport", tag: self.tag, error: error)
                completion(nil, APIError.Failed(message: error.localizedDescription))
            }
        }
    }
    
    func makeMasCallToDBNamed(connection: MasConnection,
                              dbName: String,
                              completion: @escaping SecureRequestResponceDelegate) {
        let config = MasSingleTableGet(masConnection: connection, tableName: dbName)
        config.makeCall { (result) in
            let response = RequestResponce.init(json: result.json, error: result.error)
            completion(response)
        }
    }
    
    func refreshTimeMas(connection: MasConnection,
                        completion: @escaping RefreshTimeDelegate) {
        // Get request to IesTime
        let config = MasSingleTableGet(masConnection: connection, tableName: HubTime.getTableName())
        config.makeCall { (result) in
            guard let json = result.json else {
                completion(nil, result.error)
                return
            }
            
            let model = HubTime(from: json)
            
            self.sendConfigViaMas(connection: connection, config: model) { (message, error) in
                completion(model, error)
            }
        }
    }
    
    func updateTimeMas(connection: MasConnection,
                       newUtcTime: String,
                       completion: @escaping Delegate) {
        
        // Create two json objects to let us make a patch
        var ojson = JSON()
        ojson[DbNodeInfo.NodeTime] = "someTime"
        
        var njson = JSON()
        njson[DbNodeInfo.NodeTime] = newUtcTime
        
        let tableName = DbNodeInfo.TableName
        
        guard let data = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            completion("Could not create update time patch", APIError.Failed(message: "Could not create update time patch"))
            return
        }
        
        let patch = MasApiPatchConfigCall.init(patchData: data,
                                               masConnection: connection,
                                               tableName: tableName)
        
        sendPatch(patch: patch, completion: completion)
    }
    
    // MARK: - Sending
    func sendConfigViaMas(connection: MasConnection,
                          config: ApiRequestConfigProtocol,
                          completion: @escaping Delegate) {
        
        guard let update = config.getMasUpdate() else {
            //print("Config provided no MAS API data")
            completion("", APIError.Failed(message: "Config provided no data to send to the API"))
            
            return
        }
        
        // Do the call
        let patch = MasApiPatchConfigCall(patchData: update.data,
                                          masConnection: connection,
                                          tableName: update.tableName)
        sendPatch(patch: patch, completion: completion)
    }
    
    private func sendPatch(patch: MasApiPatchConfigCall, completion: @escaping Delegate) {
        patch.makeCall { (success, message) in
            if !success {
                Logger.log(tag: "ApiImpl+Mas", message: "Patch to \(patch.tableName) failed")
                completion(nil, APIError.Failed(message: message))
            }
            else {
                completion("Success", nil)
            }
        }
    }
    
    // MARK: - Firewall
    func getAllFirewallRulesMas(connection: MasConnection,
                                completion: @escaping FirewallDelegate) {
        
        getFirewallRulesJson(connection: connection) { (result) in
            guard let json = result.json else {
                completion(nil, result.error)
                return
            }
            
            var firewallRules = [FirewallRule]()
            
            // Accept Deny rules
            if let rules = json["firewall_rules"] as? [JSON] {
                for rule in rules {
                    let r = FirewallRule.init(json: rule)
                    firewallRules.append(r)
                }
            }
            
            // Forward rules
            if let rules = json["forward_rules"] as? [JSON] {
                for rule in rules {
                    let r = FirewallRule.init(json: rule)
                    firewallRules.append(r)
                }
            }
            
            completion(firewallRules, result.error)
        }
    }
    
    private func getFirewallRulesJson(connection: MasConnection, completion: @escaping MasSingleTableGet.MasApiGetResult) {
        let request = MasSingleTableGet.init(masConnection: connection, tableName: "node_firewall")
        request.makeCall { (result) in
            completion(result)
        }
    }
    
    func updateFirewallMas(connection: MasConnection,
                           rules: [FirewallRule],
                           completion: @escaping FirewallDelegate) {
        getFirewallRulesJson(connection: connection) { (result) in
            guard let json = result.json else {
                completion(nil, APIError.Failed(message: "Could not get existing rules json"))
                return
            }
            
            var modifiedJson = json
            modifiedJson.removeValue(forKey: "_rev")
            modifiedJson.removeValue(forKey: "_id")

            self.createPatchJson(connection: connection,
                                 rulesToUpdate: rules,
                                 currentRules: modifiedJson,
                                 completion: completion)
        }
    }
    
    private func createPatchJson(connection: MasConnection,
                                 rulesToUpdate: [FirewallRule],
                                 currentRules: JSON,
                                 completion: @escaping FirewallDelegate) {
        var forwardRules = [JSON]()
        var acceptDeny = [JSON]()
        
        for rule in rulesToUpdate {
            if let json = rule.getMasUpdateJson() {
                if rule.ruleActionType! == .FORWARD {
                    if let updateState = rule.mUpdateState {
                        if updateState != .DELETE {
                            forwardRules.append(json)
                        }
                    }
                    else {
                        forwardRules.append(json)
                    }
                }
                else {
                    if let updateState = rule.mUpdateState {
                        if updateState != .DELETE {
                            acceptDeny.append(json)
                        }
                    }
                    else {
                        acceptDeny.append(json)
                    }
                }
            }
        }
        
        var updatedRules = JSON()
        updatedRules["forward_rules"] = forwardRules
        updatedRules["firewall_rules"] = acceptDeny
        
        let tableName = "node_firewall"
        
        // Make the patch
        guard let patchData = MasApiPatchDataHelper.patch(sourceJson: currentRules, targetJson: updatedRules, tableName: tableName) else {
            completion(nil, APIError.Failed(message: "Could not create patch data"))
            return
        }
        
        let masUpdate = MasUpdate.init(tableName: tableName, data: patchData)
        sendFirewallPatch(masUpdate: masUpdate,
                          connection: connection,
                          completion: completion)
    }
    
    private func sendFirewallPatch(masUpdate :MasUpdate, connection: MasConnection, completion: @escaping FirewallDelegate) {
        let config = MasApiPatchConfigCall.init(patchData: masUpdate.data,
                                                masConnection: connection,
                                                tableName: masUpdate.tableName)
        config.makeCall { (success, message) in
            if !success {
                completion(nil, APIError.Failed(message: message))
            }
            else {
                completion(nil, nil)
            }
        }
    }
}
