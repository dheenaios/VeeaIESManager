//
//  AnalyticsConfig.swift
//  HubLibrary
//
//  Created by Al on 03/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 Configuration items for the IES analytics.
 
 Controls whether or not analytics are enabled for retail and media.
 */
public struct AnalyticsConfig: TopLevelJSONResponse, Equatable, Codable {
    var originalJson: JSON = JSON()
    
    /// - mediaAnalyticsLocked: whether or not media analytics are locked.
    @DecodableDefault.False var media_analytics_locked: Bool
    
    /// - retailAnalyticsLocked: whether or not retail analytics are locked
    @DecodableDefault.False var retail_analytics_locked: Bool
    
    private enum CodingKeys: String, CodingKey {
        case media_analytics_locked,
             retail_analytics_locked
    }
    
    //
    // MARK: - internal
    //
    
    public static func == (lhs: AnalyticsConfig, rhs: AnalyticsConfig) -> Bool {
        return lhs.media_analytics_locked == rhs.media_analytics_locked &&
            lhs.retail_analytics_locked == rhs.retail_analytics_locked
    }
}

extension AnalyticsConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[AnalyticsConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        
        for (index, element) in AnalyticsConfig.getAllKeys().enumerated() {
            vals[element] = getAllValues()[index]
        }
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = AnalyticsConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public func getTableName() -> String {
        return AnalyticsConfig.getTableName()
    }
    
    public func getAllKeys() -> [String] {
        return AnalyticsConfig.getAllKeys()
    }
    
    public func getAllValues() -> [Any] {
        var values = [Any]()
        
        values.append(media_analytics_locked)
        values.append(retail_analytics_locked)
        
        return values
    }
    
    public static func getTableName() -> String {
        return DbNodeConfig.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeConfig.MediaAnalyticsLocked)
        keys.append(DbNodeConfig.RetailAnalyticsLocked)
        
        return keys
    }
}
