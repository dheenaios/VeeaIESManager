//
//  BeaconConfig.swift
//  HubLibrary
//
//  Created by Al on 03/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 Configuration items for the IES beacon.
 */
public struct BeaconConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    /// - instanceId: the beacon instance ID
    public var beacon_instance_id: String
    
    /// - locked: whether or not the beacon is locked
    public var beacon_locked: Bool
    
    /// - subDomain: the beacon subdomain (namespace)
    public var beacon_sub_domain: String

    //
    // MARK: - internal
    //
    
    public static func == (lhs: BeaconConfig, rhs: BeaconConfig) -> Bool {
        return lhs.beacon_locked == rhs.beacon_locked &&
            lhs.beacon_instance_id == rhs.beacon_instance_id &&
            lhs.beacon_sub_domain == rhs.beacon_sub_domain
    }
    
    private enum CodingKeys: String, CodingKey {
        case beacon_instance_id,
             beacon_locked,
             beacon_sub_domain
    }
}

extension BeaconConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[BeaconConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        vals[DbNodeConfig.BeaconSubDomain] = beacon_sub_domain
        vals[DbNodeConfig.BeaconInstanceId] = beacon_instance_id
        vals[DbNodeConfig.BeaconLocked] = beacon_locked
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = BeaconConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public static func getTableName() -> String {
        return DbNodeConfig.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeConfig.BeaconSubDomain)
        keys.append(DbNodeConfig.BeaconInstanceId)
        keys.append(DbNodeConfig.BeaconLocked)
        
        return keys
    }
}
