//
//  InstalledAppsConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 01/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

public struct InstalledAppsConfig: TopLevelJSONResponse, Equatable {
    var originalJson: JSON
    
    public static func == (lhs: InstalledAppsConfig, rhs: InstalledAppsConfig) -> Bool {
        if lhs.installedAppConfigurations.count != rhs.installedAppConfigurations.count {
            return false
        }
        
        for (index, lc) in lhs.installedAppConfigurations.enumerated() {
            let rc = rhs.installedAppConfigurations[index]
            
            if lc.appId != rc.appId {
                return false
            }
            if lc.appName != rc.appName {
                return false
            }
        }
        
        return lhs.installedAppKeys == rhs.installedAppKeys
    }
    
    let tag = "InstalledAppsConfig"
    
    public var installedAppConfigurations: [InstalledAppConfigProtocol]
    public var installedAppKeys: [String]
    
    /// Returns a config for a given identifier (e.g. public_wifi)
    ///
    /// - Parameter appID: identifier
    /// - Returns: The config struct confirming to InstalledAppConfigProtocol. May be nil if it does not exist
    public func getAppConfigForAppId(appID: String) -> InstalledAppConfigProtocol? {
        
        for config in installedAppConfigurations {
            if config.appId == appID {
                return config
            }
        }
        
        return nil
    }
    
    init(from json: JSON) {
        originalJson = json
        
        installedAppConfigurations = [InstalledAppConfigProtocol]()
        installedAppKeys = JSONValidator.valiate(key: DbNodeServices.Services,
                                                 json: json,
                                                 expectedType: [String].self,
                                                 defaultValue: [String]()) as! [String]
        
        for key in installedAppKeys {
            if let item = json[key] {
                if key == DbNodeServices.PublicWifiAppConfigKey {
                    installedAppConfigurations.append(PublicWifiInstalledAppConfig(from: item as! JSON, key: key))
                }
                else {
                    installedAppConfigurations.append(BasicInstalledAppConfig(from: item as! JSON, key: key))
                }
                
                
            }
            else {
                Logger.log(tag: tag, message: "Could not find item for key: \(key)")
            }
        }
    }
    
    static func getTableName() -> String {
        return DbNodeServices.TableName
    }
    
    public mutating func addAppConfig(appName: String, appId: String) {
        installedAppConfigurations.append(BasicInstalledAppConfig(appName: appName, appId: appId))
        installedAppKeys.append(appId)
    }

    public mutating func addAppConfig(app: KnownApps) {
        addAppConfig(appName: app.rawValue, appId: app.rawValue)
    }
    
    public mutating func removeAppConfig(appName: String, appId: String) {
        for (index, config) in installedAppConfigurations.enumerated() {
            if config.appName == appName {
                installedAppConfigurations.remove(at: index)
                
                for (index, key) in installedAppKeys.enumerated() {
                    if key == appId {
                        installedAppKeys.remove(at: index)
                        return
                    }
                }
                
                return
            }
        }
    }
}

// MARK: - Intalled app configs

public protocol InstalledAppConfigProtocol {
    var appName: String {get set}
    var appId: String {get set}
}


/// Basic config.
public struct BasicInstalledAppConfig: InstalledAppConfigProtocol {
    public var appName: String
    public var appId: String
    
    init(from json: JSON, key: String) {
        appId = key
        appName = JSONValidator.valiate(key: DbNodeServices.AppConfigName,
                                        json: json,
                                        expectedType: String.self,
                                        defaultValue: "") as! String
    }
    
    init(appName: String, appId: String) {
        self.appId = appId
        self.appName = appName
    }
}

/// Basic config.
public struct PublicWifiInstalledAppConfig: InstalledAppConfigProtocol {
    public var appName: String
    public var appId: String
    
    public var operatorName: String
    
    public var isVeeaFi: Bool {
        get {
            return appName == "VeeaFi"
        }
    }
    
    init(from json: JSON, key: String) {
        appId = key
        appName = JSONValidator.valiate(key: DbNodeServices.AppConfigName,
                                        json: json,
                                        expectedType: String.self,
                                        defaultValue: "") as! String
        
        operatorName = JSONValidator.valiate(key: DbNodeServices.PublicWifiOperator,
                                             json: json,
                                             expectedType: String.self,
                                             defaultValue: "") as! String
    }
}
