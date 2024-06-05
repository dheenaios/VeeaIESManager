//
//  API.swift
//  HubLibrary
//
//  Created by Al on 21/02/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation
import UIKit

/**
 This is the top-level API to an IES.
 
 Most API methods follow a common pattern:
 
 `func methodName(connection: VeeaHubConnection, completion: @escaping Delegate)`
 
 Use one of the `ApiFactory` accessor methods (`api`, `get`, or `getInstance`) to perform API operations, e.g.
 
 - `ApiFactory.api.getVmeshConfig(ies) { ... }`
 
 Note: API calls are asynchronous. If you need to update UI elements as a result of an API response you must perform the updates within the UI thread.
 
 */
public protocol API  {
    
    // MARK: - Authorisation Tokens
    func deleteCurrentAuthToken()
   
    //
    // MARK: - Config retrieval
    //
    
    /**
    Requests all config info from the MAS Api
     
    - parameters:
    - connection: the connection to obtain information from
    - completion:    the delegate to invoke when the operation completes
    */
    func getMasApiIntermediaryModel(connection: MasConnection,
                                    completion: @escaping MasIntermediaryModelDelegate)
    
    /**
     Requests all basic config information relating to the Hub functions.
     
     - parameters:
     - connection: the connection to obtain information from
     - completion:    the delegate to invoke when the operation completes
     */
    func getBaseDataModel(connection: VeeaHubConnection,
                          completion: @escaping HubBaseDataModelDelegate)
    
    /**
     Requests all optional app config information relating to the Hub functions.
     
     - parameters:
     - connection: the connection to obtain information from
     - completion:    the delegate to invoke when the operation completes
     */
    func getOptionAppsDataModel(connection: VeeaHubConnection,
                                installedAppManifest: InstalledAppsConfig,
                                completion: @escaping HubOptionalAppsDataModelDelegate)
    
    
    /// Make a call for the contents of a Db using the db name
    ///
    /// - Parameters:
    ///   - connection: connection
    ///   - dbName: name of the db
    ///   - completion: the result of the call. The response object
    func makeCallToDBNamed(connection: HubConnectionDefinition,
                           dbName: String,
                           completion: @escaping SecureRequestResponceDelegate)
    
    /**
     Requests information relating to node configuration.
     
     - parameters:
        - connection:          the connection to obtain information from
        - completion:   the delegate to invoke when the operation completes
     */
    func getNodeConfig(connection: HubConnectionDefinition,
                       completion: @escaping NodeConfigDelegate)

    /**
     Requests information relating to node status.

     - parameters:
        - connection:          the connection to obtain information from
        - completion:   the delegate to invoke when the operation completes
     */
    func getNodeStatus(connection: HubConnectionDefinition,
                       completion: @escaping NodeStatusDelegate)
    
    // MARK: - Stats
    //
    /**
     Requests statistics from the IES's cellular interface.
     
     - parameters:
        - connection:          the connection to obtain information from
        - completion:   the delegate to invoke when the operation completes
     */
    func getCellularStats(connection: HubConnectionDefinition,
                          completion: @escaping CellularStatsDelegate)
    
    /**
     Requests statistics from the connection's Wi-Fi interface.
     
     - parameters:
        - connection:          the connection to obtain information from
        - completion:   the delegate to invoke when the operation completes
     */
    func getWifiStats(connection: HubConnectionDefinition,
                      completion: @escaping WifiStatsDelegate)
    
    /**
    Requests statistics from the IES's last ACS Scan Report
    
    - parameters:
       - connection: the connection to obtain information from
       - completion: the delegate to invoke when the operation completes
    */
    func getAcsScanReport(connection: HubConnectionDefinition,
                          completion: @escaping AcsScanReportDelegate)

    /**
    Requests statistics from the IES's last Wds Scan Report

    - parameters:
       - connection: the connection to obtain information from
       - completion: the delegate to invoke when the operation completes
    */
    func getWdsScanReport(connection: HubConnectionDefinition,
                          completion: @escaping WdsScanReportDelegate)
    
    //
    // MARK: - Actions
    //

    /**
     Requests that the connection update its onboard clock. Returns the UTC time according to the IES.
     
     - parameters:
        - connection:          the connection to obtain information from
        - completion:   the delegate to invoke when the operation completes
     */
    func refreshTime(connection: HubConnectionDefinition,
                     completion: @escaping RefreshTimeDelegate)
    
    /**
     Requests that the connection use the supplied time for its internal clock.
     
     - parameters:
        - connection:          the connection to obtain information from
        - newUtcTime:   the new time string (UTC) to use, in this format: yyyy-MM-dd HH:mm:ss
        - completion:   the delegate to invoke when the operation completes
     */
    func updateTime(connection: HubConnectionDefinition,
                    newUtcTime: String,
                    completion: @escaping Delegate)
    
    //
    // MARK: - Config updates
    //
    
    /// Requests that the connection updates its configuration.
    ///
    /// - Parameters:
    ///   - connection: the connection to obtain information from
    ///   - config: the configuration to update. Conforms to SecureAPIRequestConfigProtocol
    ///   - completion: the delegate to invoke when the operation completes
    func setConfig(connection: HubConnectionDefinition,
                   config: ApiRequestConfigProtocol,
                   completion: @escaping Delegate)


    /// Requests that the connection updates its configuration.
    /// - Parameters:
    ///   - connection: the connection to obtain information from
    ///   - config: the configuration to update. Conforms to SecureAPIRequestConfigProtocol
    /// - Returns: A tuple with an optional message and an error
    func setConfig(connection: HubConnectionDefinition,
                       config: ApiRequestConfigProtocol) async -> (String?, APIError?)
    
    
    
    
    // MARK: - Firewall Rules

    
    /// Get all rules (accept, drop, forward)
    /// - Parameters:
    ///   - connection: the connected hub
    ///   - completion: completion Delegate
    func getAllFirewallRules(connection: HubConnectionDefinition,
                             completion: @escaping FirewallDelegate)
    
    /// Update multiple firewall rules as per their status (DELETE, CREATE, UPDATE) of type Accept, Drop or Forward. 
    ///
    /// - Parameters:
    ///   - connection: the connected connection
    ///   - rules: the rule to be updated
    ///   - completion: completion delegate
    func updateFirewall(connection: HubConnectionDefinition, rules: [FirewallRule],
                        completion: @escaping FirewallDelegate)

}

public enum APIError: Error {
    case Failed(message: String)
    case NoData(reason: Error)
    case NoConnection
    
    public func errorDescription() -> String {
        switch self {
        case .NoConnection:
            return "No IES Connected"
        case .Failed(message: let reason):
            return reason
        case .NoData(reason: let error):
            return "API call returned no data: \(error.localizedDescription)"
        }
    }
}

/**
 Implement this to handle configuration update (`setConfig`) responses.
 
 - parameters:
    - result:   return value, if any
    - error:    error value, if any
 */
public typealias Delegate = (String?, APIError?) -> Void

public typealias SecureRequestResponceDelegate = (RequestResponce) -> Void

/**
 Implement this to handle firewall responses.
 
 - parameters:
 - result:   return value, if any. Can be empty and the call is still successful
 - error:    error value, if any.
 */
public typealias FirewallDelegate = ([FirewallRule]?, APIError?) -> Void

/**
 Implement this to handle MasApiIntermediaryDataModel responses.
 
 - parameters:
 - result:   return value, if any. Can be empty and the call is still successful
 - error:    error value, if any.
 */
public typealias MasIntermediaryModelDelegate = (MasApiIntermediaryDataModel?, APIError?) -> Void

/**
 Implement this to handle HubBaseDataModel responses.
 
 - parameters:
 - result:   return value, if any. Can be empty and the call is still successful
 - error:    error value, if any.
 */
public typealias HubBaseDataModelDelegate = (HubBaseDataModel?, APIError?) -> Void

/**
 Implement this to handle OptionalAppsDataModel responses.
 
 - parameters:
 - result:   return value, if any. Can be empty and the call is still successful
 - error:    error value, if any.
 */
public typealias HubOptionalAppsDataModelDelegate = (OptionalAppsDataModel?, APIError?) -> Void

/**
 Implement this interface to handle cellular stats responses.

 - parameters:
    - callularStats: return value, if any
    - error:         error value, if any
 */
public typealias CellularStatsDelegate = (CellularStats?, APIError?) -> Void

/**
 Implement this interface to handle node config responses.

 - parameters:
    - nodeConfig:   return value, if any
    - error:        error value, if any
 */
public typealias NodeConfigDelegate = (NodeConfig?, APIError?) -> Void

public typealias NodeStatusDelegate = (NodeStatus?, APIError?) -> Void

/**
 Implement this interface to handle time refresh responses.
 
 - parameters:
    - iesTime:     return value, if any
    - error:       error value, if any
 */
public typealias RefreshTimeDelegate = (HubTime?, APIError?) -> Void

/**
 Implement this interface to handle Wi-Fi stats responses.
 
 - parameters:
    - wifiStats: return value, if any
    - error:     error value, if any
*/
public typealias WifiStatsDelegate = (WifiStats?, APIError?) -> Void

public typealias AcsScanReportDelegate = (AcsScanReport?, APIError?) -> Void

public typealias WdsScanReportDelegate = (WdsScanReport?, APIError?) -> Void
