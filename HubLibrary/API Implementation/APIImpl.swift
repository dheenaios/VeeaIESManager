//
//  APIImpl.swift
//  HubLibrary
//
//  Created by Al on 21/02/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/// See also Extensions in APIApps.swift
class APIImpl : API {
    // MARK: - API Calls
    
    let tag = "APIImpl"
        
    func deleteCurrentAuthToken() {
        SecureAPIAuthorisation.shared.deleteToken()
    }
    
    /// Get Base Data model from the Hub API
    /// - Parameters:
    ///   - connection: The connection details
    ///   - completion: The completion handler
    func getBaseDataModel(connection: VeeaHubConnection,
                          completion: @escaping HubBaseDataModelDelegate) {
        let model = BaseDataModelRequester()
        model.getRequireDataModel(connection: connection,
                                  completion: completion)
    }
    
    /// Get Optional Data model from the Hub API
    /// - Parameters:
    ///   - connection: The connection details
    ///   - completion: The completion handler
    func getOptionAppsDataModel(connection: VeeaHubConnection,
                                installedAppManifest: InstalledAppsConfig,
                                completion: @escaping HubOptionalAppsDataModelDelegate) {
        
        let model = OptionalDataModelAppsRequester()
        
        model.getInstalledAppModels(connection: connection,
                                    installedAppManifest: installedAppManifest,
                                    completion: completion)
    }
    
    func getCellularStats(connection: HubConnectionDefinition,
                          completion: @escaping CellularStatsDelegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            if let connection = connection as? MasConnection {
                getCellularStatsMas(connection: connection, completion: completion)
            }
            
            return
        }
        
        getCellularStatsHubApi(connection: hubConnection, completion: completion)
    }
 
    func getNodeConfig(connection: HubConnectionDefinition,
                       completion: @escaping NodeConfigDelegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            if let connection = connection as? MasConnection {
                getNodeConfigMas(connection: connection, completion: completion)
            }
            
            return
        }
        
        getNodeConfigHubApi(connection: hubConnection,
                            completion: completion)
    }

    func getNodeStatus(connection: HubConnectionDefinition,
                       completion: @escaping NodeStatusDelegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            if let connection = connection as? MasConnection {
                getNodeStatusMas(connection: connection, completion: completion)
            }

            return
        }

        getNodeStatusHubApi(connection: hubConnection,
                            completion: completion)
    }
    
    func getWifiStats(connection: HubConnectionDefinition,
                      completion: @escaping WifiStatsDelegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            if let connection = connection as? MasConnection {
                getWifiStatsMas(connection: connection, completion: completion)
            }
            
            return
        }
        
        getWifiStatsHubApi(connection: hubConnection, completion: completion)
    }
    
    
    
    func getAcsScanReport(connection: HubConnectionDefinition,
                          completion: @escaping AcsScanReportDelegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            
            if let connection = connection as? MasConnection {
                getAcsScanReportMas(connection: connection, completion: completion)
            }
            
            return
        }
        
        getAcsScanReportHubApi(connection: hubConnection,
                               completion: completion)
    }

    func getWdsScanReport(connection: HubConnectionDefinition,
                          completion: @escaping WdsScanReportDelegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {

            if let connection = connection as? MasConnection {
                getWdsScanReportMas(connection: connection, completion: completion)
            }

            return
        }

        getWdsScanReportHubApi(connection: hubConnection,
                               completion: completion)
    }

    func makeCallToDBNamed(connection: HubConnectionDefinition,
                           dbName: String,
                           completion: @escaping SecureRequestResponceDelegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            if let connection = connection as? MasConnection {
                makeMasCallToDBNamed(connection: connection, dbName: dbName, completion: completion)
            }
            
            return
        }
        
        makeCallToDBNamedHubApi(dbName: dbName,
                                connection: hubConnection,
                                completion: completion)
    }
      
    func refreshTime(connection: HubConnectionDefinition,
                     completion: @escaping RefreshTimeDelegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            if let connection = connection as? MasConnection {
                refreshTimeMas(connection: connection, completion: completion)
            }
            
            return
        }
        
        refreshTimeHubApi(connection: hubConnection, completion)
    }
    
    func updateTime(connection: HubConnectionDefinition,
                    newUtcTime: String,
                    completion: @escaping Delegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            if let connection = connection as? MasConnection {
                updateTimeMas(connection: connection, newUtcTime: newUtcTime, completion: completion)
            }
            
            return
        }
        
        updateTimeHubApi(newUtcTime: newUtcTime,
                         connection: hubConnection,
                         completion: completion)
    }

    // MARK: - Firewall
    
    func getAllFirewallRules(connection: HubConnectionDefinition,
                             completion: @escaping FirewallDelegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            if let connection = connection as? MasConnection {
                getAllFirewallRulesMas(connection: connection,
                                       completion: completion)
            }
            
            return
        }
        
        getAllFirewallRulesHubApi(connection: hubConnection,
                                  completion: completion)
    }
    
    private func getAllFirewallRulesHubApi(connection: HubConnectionDefinition,
                                           completion: @escaping FirewallDelegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            return
        }
        
        HubApiRequester.shared.getAllFirewallRules(connection: hubConnection) { (rules, error) in
            DispatchQueue.main.async {
                completion(rules, error)
            }
        }
    }
    
    func updateFirewall(connection: HubConnectionDefinition, rules: [FirewallRule], completion: @escaping FirewallDelegate) {
        if let c = connection as? MasConnection {
            updateFirewallMas(connection: c,
                              rules: rules,
                              completion: completion)
            return
        }
        
        updateFirewallHubApi(connection: connection,
                             updatedRules: rules,
                             completion: completion)
    }
    
    private func updateFirewallHubApi(connection: HubConnectionDefinition,
                                      updatedRules: [FirewallRule],
                                      completion: @escaping FirewallDelegate) {
        let firewallRules = FirewallRules(updatedRules: updatedRules)
        
        setConfig(connection: connection, config: firewallRules) { message, error in
            Logger.log(tag: "updateFirewallHubApi", message: "Update completed, message: \(message ?? "No message"). Error: \(error?.localizedDescription ?? "No error")")
            completion(updatedRules, error)
        }
    }
    
    // MARK: - Config
    

    func setConfig(connection: HubConnectionDefinition,
                   config: ApiRequestConfigProtocol,
                   completion: @escaping Delegate) {
        guard let hubConnection = connection as? VeeaHubConnection else {
            if let c = connection as? MasConnection {
                sendConfigViaMas(connection: c,
                                 config: config,
                                 completion: completion)
            }
            
            return
        }
        
        sendConfigViaHubApi(config: config,
                            connection: hubConnection,
                            completion: completion)
    }

    func setConfig(connection: HubConnectionDefinition,
                   config: ApiRequestConfigProtocol) async -> (String?, APIError?)  {
        await withCheckedContinuation({ continuation in
            setConfig(connection: connection, config: config) { message, error in
                continuation.resume(returning: (message, error))
            }
        })
    }
}
