//
//  GatewayConfig.swift
//  HubLibrary
//
//  Created by Al on 03/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//
import Foundation

/**
 Configuration items relating to an individual IES gateway
 */
public class GatewayLock: Equatable {
    
    var backhaulType: BackhaulType? {
        for type in BackhaulType.allCases {
            if type.rawValue == name {
                return type
            }
        }
        
        return nil
    }
    
    public static func == (lhs: GatewayLock, rhs: GatewayLock) -> Bool {
        return lhs.locked == rhs.locked &&
        lhs.restricted == rhs.restricted &&
        lhs.name == rhs.name &&
        lhs.title == rhs.title
    }
    
    /// - locked: whether or not the gateway is locked
    public var locked: Bool
    
    /// - restricted: whether or not the gateway is restricted
    public var restricted: Bool
    
    /// - name: the name of the gateway configuration item, e.g. "cellular", "ethernet", "wifi"
    public var name: String
    
    public var title: String {
        get {
            let components = name.components(separatedBy: "_")
            return components[1].localizedCapitalized
        }
    }
    
    //
    // MARK: - internal
    //
    init(_ name: String, locked: Bool, restricted: Bool) {
        self.name = name
        self.locked = locked
        self.restricted = restricted
    }
    
    var description: String {
        return "Name: \(self.name), locked: \(self.locked), restricted: \(self.restricted)"
    }
    
    public convenience init(from: GatewayLock) {
        self.init(from.name, locked: from.locked, restricted: from.restricted)
    }
    
    public func debugDescription() -> String {
        return "GatewayLock { name:\(name), locked:\(locked), restricted:\(restricted) }"
    }
}

/**
 Configuration items relating to the IES gateway
 */
public struct GatewayConfig: TopLevelJSONResponse, Equatable {
    public static func == (lhs: GatewayConfig, rhs: GatewayConfig) -> Bool {
        return lhs.locks == rhs.locks &&
        lhs.passphrase == rhs.passphrase &&
        lhs.ssid == rhs.ssid &&
        lhs.lockOrder == rhs.lockOrder &&
        lhs.cellularLocked == rhs.cellularLocked
        
    }
    
    
    var originalJson: JSON
    
    /// - locks: the names and settings for each type of gateway
    public var locks = [GatewayLock]()
    
    /// - passphrase: the passphrase for the gateway
    public var passphrase: String
    
    /// - ssid: the gateway SSID
    public var ssid: String
    
    /// - lockOrder: the order in which each gateway type will be tried
    public var lockOrder: [String]      // deprecated
    {
        get {
            var lockNames = [String]()
            for lock in locks {
                lockNames.append(lock.name)
            }

            return lockNames
        }
    }

    // See VHM-1661
    private let originalLockOrder: [String]
    
    /// - cellularLocked: whether or not the cellular gateway interface is locked
    public var cellularLocked: Bool     // deprecated
    {
        get {
            return lockValue(named: "cellular")
        }
    }
    
    /// - cellularRestricted: whether or not the cellular gateway interface is restricted
    public var cellularRestricted: Bool     // deprecated
    {
        get {
            return restrictValue(named: "cellular")
        }
    }
    
    /// - ethernetLocked: whether or not the Ethernet gateway interface is locked
    public var ethernetLocked: Bool     // deprecated
    {
        get {
            return lockValue(named: "ethernet")
        }
    }
    
    /// - ethernetRestricted: whether or not the Ethernet gateway interface is restricted
    public var ethernetRestricted: Bool     // deprecated
    {
        get {
            return restrictValue(named: "ethernet")
        }
    }
    
    /// - wifiLocked: whether or not the Wi-Fi gateway interface is locked
    public var wifiLocked: Bool         // deprecated
    {
        get {
            return lockValue(named: "wifi")
        }
    }
    
    /// - wifiRestricted: whether or not the Wi-Fi gateway interface is restricted
    public var wifiRestricted: Bool         // deprecated
    {
        get {
            return restrictValue(named: "wifi")
        }
    }
    
    public var gatewayServiceDiscovery: Bool
    
    private func lockValue(named: String) -> Bool {
        for lock in locks {
            if lock.name.contains(named) {
                return lock.locked
            }
        }
        
        return false
    }
    
    private func restrictValue(named: String) -> Bool {
        for lock in locks {
            if lock.name.contains(named) {
                return lock.restricted
            }
        }
        
        return false
    }
    
    //
    // MARK: - 
    //
    init(from json: JSON) {
        originalJson = json
        
        let lockOrder = JSONValidator.valiate(key: DbNodeConfig.GatewayLockOrder,
                                              json: json,
                                              expectedType:[String].self,
                                              defaultValue: [String]()) as! [String]
        self.originalLockOrder = lockOrder
        
        let cellularLocked = JSONValidator.valiate(key: DbNodeConfig.GatewayCellularLocked,
                                                   json: json,
                                                   expectedType:Bool.self,
                                                   defaultValue: false) as! Bool
        
        let ethernetLocked = JSONValidator.valiate(key: DbNodeConfig.GatewayEthernetLocked,
                                                   json: json,
                                                   expectedType:Bool.self,
                                                   defaultValue: false) as! Bool
        
        let wifiLocked = JSONValidator.valiate(key: DbNodeConfig.GatewayWifiLocked,
                                               json: json,
                                               expectedType:Bool.self,
                                               defaultValue: false) as! Bool
        
        let cellularRestricted = JSONValidator.valiate(key: DbNodeConfig.GatewayCellularRestricted,
                                                       json: json,
                                                       expectedType:Bool.self,
                                                       defaultValue: false) as! Bool
        
        let ethernetRestricted = JSONValidator.valiate(key: DbNodeConfig.GatewayEthernetRestricted,
                                                       json: json,
                                                       expectedType:Bool.self,
                                                       defaultValue: false) as! Bool
        
        let wifiRestricted = JSONValidator.valiate(key: DbNodeConfig.GatewayWifiRestricted,
                                                   json: json,
                                                   expectedType:Bool.self,
                                                   defaultValue: false) as! Bool
        
        for name in lockOrder {
            var locked = false
            var restricted = false
            if name.contains("cellular") {
                locked = cellularLocked
                restricted = cellularRestricted
                
            } else if name.contains("ethernet") {
                locked = ethernetLocked
                restricted = ethernetRestricted
                
            } else if name.contains("wifi") {
                if !BackhaulStateController.isBackhaulWiFiAvailable { continue }
                locked = wifiLocked
                restricted = wifiRestricted
            }
            
            locks.append(GatewayLock(name, locked: locked, restricted: restricted))
        }
        
        gatewayServiceDiscovery = JSONValidator.valiate(key: DbNodeConfig.GatewayServiceDiscovery,
                                                        json: json,
                                                        expectedType:Bool.self,
                                                        defaultValue: false) as! Bool
        
        ssid = JSONValidator.valiate(key: DbNodeConfig.GatewaySsid,
                                     json: json,
                                     expectedType:String.self,
                                     defaultValue: "") as! String
        
        passphrase = JSONValidator.valiate(key: DbNodeConfig.GatewayPsk,
                                           json: json,
                                           expectedType:String.self,
                                           defaultValue: "") as! String
    }
}

extension GatewayConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[GatewayConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    func getUpdateJson() -> JSON {
        var json = originalJson
        json.removeValue(forKey: "_rev")
        json.removeValue(forKey: "_id")

        // VHM-1661 and 1275.
        var lOrder = lockOrder
        if originalLockOrder.count != lockOrder.count {
            // If wifi is not supported it is not shown as a lock option.
            // However, even though it it not supported it is returned in gateway_lock_order
            // So even though we do not show it we need to make sure we return it. :-/
            if !BackhaulStateController.isBackhaulWiFiAvailable {
                lOrder.append("gateway_wifi_locked")
            }
        }

        json[DbNodeConfig.GatewayLockOrder] = lOrder
        json[DbNodeConfig.GatewayCellularLocked] = cellularLocked
        json[DbNodeConfig.GatewayEthernetLocked] = ethernetLocked
        json[DbNodeConfig.GatewayWifiLocked] = wifiLocked
        json[DbNodeConfig.GatewayCellularRestricted] = cellularRestricted
        json[DbNodeConfig.GatewayEthernetRestricted] = ethernetRestricted
        json[DbNodeConfig.GatewayWifiRestricted] = wifiRestricted
        json[DbNodeConfig.GatewaySsid] = ssid
        json[DbNodeConfig.GatewayPsk] = passphrase
        json[DbNodeConfig.GatewayServiceDiscovery] = gatewayServiceDiscovery
        
        return json
    }
    
    public func getMasUpdate() -> MasUpdate? {
        var ojson = originalJson
        ojson.removeValue(forKey: "_rev")
        ojson.removeValue(forKey: "_id")

        let njson = getUpdateJson()
        let tableName = GatewayConfig.getTableName()
        
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
        
        keys.append(DbNodeConfig.GatewayLockOrder)
        keys.append(DbNodeConfig.GatewayCellularLocked)
        keys.append(DbNodeConfig.GatewayEthernetLocked)
        keys.append(DbNodeConfig.GatewayWifiLocked)
        keys.append(DbNodeConfig.GatewayCellularRestricted)
        keys.append(DbNodeConfig.GatewayEthernetRestricted)
        keys.append(DbNodeConfig.GatewayWifiRestricted)
        keys.append(DbNodeConfig.GatewaySsid)
        keys.append(DbNodeConfig.GatewayPsk)
        keys.append(DbNodeConfig.GatewayServiceDiscovery)
        
        return keys
    }
}

