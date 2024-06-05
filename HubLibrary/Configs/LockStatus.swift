//
//  LockStatus.swift
//  HubLibrary
//
//  Created by Al on 02/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 Configuration items relating to the lock status of IES subsystems.
 */
public struct LockStatus: TopLevelJSONResponse, Equatable, Codable {
    var originalJson: JSON = JSON()

    /// - beaconLocked: whether or not the Bluetooth (Eddystone) beacon subsystem is locked
    public internal(set) var beacon_locked: Bool
    
    /// - gatewayCellularLocked: whether or not the cellular backhaul is locked
    public internal(set) var gateway_cellular_locked: Bool
    
    /// - getewayEthernetLocked: whether or not the Ethernet backhaul is locked
    public internal(set) var gateway_ethernet_locked: Bool
    
    /// - gatewayWifiLocked: whether or not the Wi-Fi backhaul is locked
    public internal(set) var gateway_wifi_locked: Bool
    
    /// - mediaAnalyticsLocked: whether or not the media analytics subsystem is locked
    @DecodableDefault.False var media_analytics_locked: Bool

    /// - nodeLocked: whether or not the IES is locked
    public internal(set) var node_locked: Bool
    
    /// - retailAnalyticsLocked: whether or not the retail analytics subsystem is locked
    @DecodableDefault.False var retail_analytics_locked: Bool
    
    //
    // MARK: - internal
    //
    
    public static func == (lhs: LockStatus, rhs: LockStatus) -> Bool {
        return lhs.beacon_locked == rhs.beacon_locked &&
            lhs.gateway_cellular_locked == rhs.gateway_cellular_locked &&
            lhs.gateway_ethernet_locked == rhs.gateway_ethernet_locked &&
            lhs.gateway_wifi_locked == rhs.gateway_wifi_locked &&
            lhs.media_analytics_locked == rhs.media_analytics_locked &&
            lhs.node_locked == rhs.node_locked &&
            lhs.retail_analytics_locked == rhs.retail_analytics_locked
    }
    
    private enum CodingKeys: String, CodingKey {
            case beacon_locked, gateway_cellular_locked, gateway_ethernet_locked, gateway_wifi_locked, media_analytics_locked, node_locked, retail_analytics_locked
    }
}

extension LockStatus: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[LockStatus.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        for (index, element) in LockStatus.getAllKeys().enumerated() {
            vals[element] = getAllValues()[index]
        }
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = LockStatus.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public func getTableName() -> String {
        return LockStatus.getTableName()
    }
    
    public func getAllKeys() -> [String] {
        return LockStatus.getAllKeys()
    }
    
    public func getAllValues() -> [Any] {
        var values = [Any]()
        values.append(beacon_locked)
        values.append(node_locked)
        values.append(media_analytics_locked)
        values.append(retail_analytics_locked)
        values.append(gateway_cellular_locked)
        values.append(gateway_ethernet_locked)
        values.append(gateway_wifi_locked)
        
        return values
    }
    
    public static func getTableName() -> String {
        return DbNodeConfig.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        keys.append(DbNodeConfig.BeaconLocked)
        keys.append(DbNodeConfig.NodeLocked)
        keys.append(DbNodeConfig.MediaAnalyticsLocked)
        keys.append(DbNodeConfig.RetailAnalyticsLocked)
        keys.append(DbNodeConfig.GatewayCellularLocked)
        keys.append(DbNodeConfig.GatewayEthernetLocked)
        keys.append(DbNodeConfig.GatewayWifiLocked)
        
        return keys
    }
}
