//
//  Triggers.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 31/08/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation

/*
 A set of configs designed to act as triggers to update a database table
 */

/// Make a set config call using this in order to tell the IES to update its wifi stats
public struct WifiStatsTrigger: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbWifiMetrics.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        keys.append(DbWifiMetrics.WifiMetricsTrigger)
        
        return keys
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[DbWifiMetrics.TableName] = getUpdateJSON()
    
        return json
    }
    
    public func getMasUpdate() -> MasUpdate? {
        // Create some json to create the patch
        var ojson = JSON()
        ojson[DbWifiMetrics.WifiMetricsTrigger] = false
        
        let njson = getUpdateJSON()
        let tableName = DbWifiMetrics.TableName
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    func getUpdateJSON() -> JSON {
        var json = JSON()
        json[DbWifiMetrics.WifiMetricsTrigger] = true
        
        return json
    }
    
    public init() {
        
    }
}

/// Make a set config call using this in order to tell the IES to update its Cellualar stats
public struct CellularStatsTrigger: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbNodeMetrics.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        keys.append(DbNodeMetrics.CellularMetricsTrigger)
        
        return keys
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[DbNodeMetrics.TableName] = getUpdateJSON()
        
        return json
    }
    
    public func getMasUpdate() -> MasUpdate? {
        // Create some json to create the patch
        var ojson = JSON()
        ojson[DbNodeMetrics.CellularMetricsTrigger] = false
        
        let njson = getUpdateJSON()
        let tableName = DbNodeMetrics.TableName
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    func getUpdateJSON() -> JSON {
        var json = JSON()
        json[DbNodeMetrics.CellularMetricsTrigger] = true
        
        return json
    }
    
    public init() {
        
    }
}
