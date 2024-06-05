//
//  NodeCapabilities.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 12/03/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

public struct NodeCapabilities: TopLevelJSONResponse {
    var originalJson: JSON
    
    let tag = "NodeCapabilities"
    
    public var availableNodeCapabilities: [NodeCapability]
    public let capabilitiesKeys: [String]
    public let functionality: [String]
    
    init(from json: JSON) {
        
        originalJson = json
        
        functionality = JSONValidator.valiate(key: DbNodeCapabilities.Features,
                                              json: json,
                                              expectedType: [String].self,
                                              defaultValue: [String]()) as! [String]
        
        availableNodeCapabilities = [NodeCapability]()
        capabilitiesKeys = JSONValidator.valiate(key: DbNodeCapabilities.Capabilities,
                                                 json: json,
                                                 expectedType: [String].self,
                                                 defaultValue: [String]()) as! [String]
        
        for key in capabilitiesKeys {
            if let item = json[key] {
                availableNodeCapabilities.append(NodeCapability(from: item as! JSON, key: key))
            }
            else {
                Logger.log(tag: tag, message: "Could not find capability item for key: \(key)")
            }
        }
    }
    
    /// Creates the object with basic vh05 capabilities
    public init() {
        originalJson = JSON()
        
        capabilitiesKeys = [DbNodeCapabilities.BluetoothKey, DbNodeCapabilities.PhysicalAP1Key]
        
        availableNodeCapabilities = [NodeCapability]()
        let bluetoothCap = NodeCapability.init(key: DbNodeCapabilities.BluetoothKey, name: "")
        let ap1Cap = NodeCapability.init(key: DbNodeCapabilities.PhysicalAP1Key, name: "")
        functionality = [String]()
        availableNodeCapabilities.append(bluetoothCap)
        availableNodeCapabilities.append(ap1Cap)
    }
    
    static func getTableName() -> String {
        return DbNodeCapabilities.TableName
    }
    
    // MARK: - Capability Queries
    public func hasCapabilityForKey(key: String) -> Bool {
        for capability in availableNodeCapabilities {
            if capability.capabilityId == key {
                return true
            }
        }
        
        return false
    }
    
    public func capabilityForKey(key: String) -> NodeCapability? {
        for capability in availableNodeCapabilities {
            if capability.capabilityId == key {
                return capability
            }
        }
        
        return nil
    }
}

extension NodeCapabilities: Equatable {
    public static func == (lhs: NodeCapabilities, rhs: NodeCapabilities) -> Bool {
        return lhs.availableNodeCapabilities == rhs.availableNodeCapabilities && lhs.capabilitiesKeys == rhs.capabilitiesKeys
    }
}

// MARK: - Capability Helpers
extension NodeCapabilities {
    
    public var showWifiIPAddress: Bool {
        get {
            guard let m = originalJson[DbNodeCapabilities.management] as? [String : Any],
                  let n = m[DbNodeCapabilities.tables_ro] as? [String : Any],
                  let nodeStatusArray = n[DbNodeCapabilities.node_status] as? [String] else {
                return false
            }
            
            if nodeStatusArray.contains("wifi_ipv4_addr") {
                return true
            }
            else {
                return false
            }
        }
    }
    
    public var showCellularIPAddress: Bool {
        get {
            guard let m = originalJson[DbNodeCapabilities.management] as? [String : Any],
                  let n = m[DbNodeCapabilities.tables_ro] as? [String : Any],
                  let nodeStatusArray = n[DbNodeCapabilities.node_status] as? [String] else {
                return false
            }
            
            if nodeStatusArray.contains("cellular_ipv4_addr") {
                return true
            }
            else {
                return false
            }
        }
    }
    
    
    public var isCellularAvailable: Bool {
        get {
            return hasCapabilityForKey(key: DbNodeCapabilities.CellularKey)
        }
    }
    
    public var isWifiWanPresent: Bool {
        get {
            return hasCapabilityForKey(key: DbNodeCapabilities.WifiWan)
        }
    }
    
    public var showClientIsolationOptions: Bool {
        get {
            guard let m = originalJson[DbNodeCapabilities.management] as? [String : Any],
                  let _ = m[DbNodeCapabilities.keysRewritable] as? [String : Any],
                  let _ = m[DbNodeCapabilities.keysReadOnly ] as? [String : Any] else {
                return false
            }
            
            return true
        }
    }
    
    public var hasClientTrafficFeature: Bool {
        get {
            guard let m = originalJson[DbNodeCapabilities.management] as? [String : Any],
                  let keysRw = m[DbNodeCapabilities.keysRewritable] as? [String : Any] else {
                return false
            }
            
            if let tables = keysRw["client_traffic"] as? [String] {
                if tables.contains("mesh_lan_config") {
                    return true
                }
            }
            
            return false
        }
    }
    
    public var hasOperationFor2GHZ: Bool {
        get {
            guard let m = originalJson[DbNodeCapabilities.management] as? [String : Any],
                  let keysRw = m[DbNodeCapabilities.keysRewritable] as? [String : Any] else {
                return false
            }
            
            if let tables = keysRw["access1_local_control"] as? [String] {
                if tables.contains("node_config") {
                    return true
                }
            }
            
            return false
        }
    }
    
    public var hasOperationFor5GHZ: Bool {
        get {
            guard let m = originalJson[DbNodeCapabilities.management] as? [String : Any],
                  let keysRw = m[DbNodeCapabilities.keysRewritable] as? [String : Any] else {
                return false
            }
            
            if let tables = keysRw["access2_local_control"] as? [String] {
                if tables.contains("node_config") {
                    return true
                }
            }
            
            return false
        }
    }
    public var isLanIdEditableOnAP: Bool {
        // Note from Rajat: We should create two separate methods one for node_ap_config and another for mesh_ap_config.
        // It's logically possible that LanID is read only for node_ap but editable for mesh_ap
        get {
            guard let m = originalJson[DbNodeCapabilities.management] as? [String : Any],
                  let keysRw = m[DbNodeCapabilities.keysRewritable] as? [String : Any],
                  let keysRo = m[DbNodeCapabilities.keysReadOnly ] as? [String : Any] else {
                return false
            }
            
            //VHM 934
            // Case 1: If lan_id contains node_ap_config and mesh_ap_config and if its under keys_ro then disable editing for lan_id
            if let tables = keysRo["lan_id"] as? [String] {
                if tables.contains("node_ap_config") && tables.contains("mesh_ap_config") {
                    return false
                }
            }
            
            // Case 2: If it exists under keys_rw then it should be editable.
            if let tables = keysRw["lan_id"] as? [String] {
                if tables.contains("node_ap_config") && tables.contains("mesh_ap_config") {
                    return true
                }
            }
            
            return false
        }
    }
    // [VHM-983 VeeaHub Manager configuration for automatic wired mesh - JIRA](https://max2inc.atlassian.net/browse/VHM-983)
    public var supportsWiredMesh: Bool {
        guard let m = originalJson[DbNodeCapabilities.management] as? [String : Any],
              let keysRw = m[DbNodeCapabilities.keysRewritable] as? [String : Any] else {
            return false
        }
        
        if let tables = keysRw["mesh"] as? [String] {
            if tables.contains("node_port_config") && tables.contains("mesh_port_config") {
                return true
            }
        }
        
        
        return false
    }
    
    func boolFor(key: String, in json: JSON) -> Bool {
        let val = JSONValidator.valiate(key: key,
                                        json: json,
                                        expectedType: Bool.self,
                                        defaultValue: false) as! Bool
        
        return val
    }
    
    func stringFor(key: String, in json: JSON) -> String {
        let val = JSONValidator.valiate(key: key,
                                        json: json,
                                        expectedType: String.self,
                                        defaultValue: "") as! String
        
        return val
    }
}

// MARK: - Management
extension NodeCapabilities {
    /// Gets table names from the management object in the capabilities table
    public var getTables: [String] {
        if let managementJson = originalJson[DbNodeCapabilities.management] {
            let tables = JSONValidator.valiate(key: DbNodeCapabilities.managementTables,
                                               json: managementJson as! JSON,
                                               expectedType: [String].self,
                                               defaultValue: [String]())
            
            return tables as! [String]
        }
        
        return [String]()
    }
    
    private func hasTable(tableName: String) -> Bool {
        let tables = getTables
        
        for table in tables {
            if table == tableName {
                return true
            }
        }
        
        return false
    }
    
    /// VHM 141: Table name has changed for more recent images
    public var usesNodeLanDhcpTable: Bool {
        hasTable(tableName: "node_lan_dhcp")
    }

    // VHM-1595: Does the hub support wan isolation mode
    public var usesNodePortStaticIpTable: Bool {
        hasTable(tableName: "node_port_static_ip")
    }

    // VHM-1595: Does the hub support wan isolation mode
    public var usesNodeLanConfigStaticIpTable: Bool {
        return hasTable(tableName: "node_lan_config_static_ip")
    }

    // VHM-1612: ip_mode present
    public var usesIpModeTableRw: Bool {
        if let managementJson = originalJson[DbNodeCapabilities.management] {
            let tables = JSONValidator.valiate(key: DbNodeCapabilities.keysRewritable,
                                               json: managementJson as! JSON,
                                               expectedType: [String : Any].self,
                                               defaultValue: [String : Any]()) as! [String : Any]

            if let rw = tables[DbNodeCapabilities.keysRewritableIpMode] as? [String] {
                return rw.contains(where: { $0 == "mesh_lan_config" })
            }
        }

        return false
    }

    // VHM-1616: ip_mode present
    public var usesIpModeTableRo: Bool {
        if let managementJson = originalJson[DbNodeCapabilities.management] {
            let tables = JSONValidator.valiate(key: DbNodeCapabilities.keysReadOnly,
                                               json: managementJson as! JSON,
                                               expectedType: [String : Any].self,
                                               defaultValue: [String : Any]()) as! [String : Any]

            if let rw = tables[DbNodeCapabilities.keysReadOnlyIpMode] as? [String] {
                return rw.contains(where: { $0 == "mesh_lan_config" })
            }
        }

        return false
    }


    /// Essentially a check to see if the IP mode functionality is available. VHM-1616: ip_mode present
    public var usesSomeIpModeTable: Bool {
        usesIpModeTableRo || usesIpModeTableRw
    }


    /// VHM 694.
    public var usesNodeLanStatusTable: Bool {
        hasTable(tableName: "node_lan_status")
    }
}

// MARK: - ETHERNET
// This information is not indexed in the capabilities JSON for some reason
extension NodeCapabilities {
    public var numberOfEthernetPortsAvailable: Int {
        get {            
            var i = 0
            for portRoles in ethernetPortRoles {
                if !portRoles.roles.isEmpty {
                    i += 1
                }
            }
            
            return i
        }
    }
    
    // VHM-1139: how net_roles for MEN on the network tab, ethernetPortRoles for all other occasions
    public var ethernetPortRoles: [PhysicalPortRoles] {
        get {
            if let ethernetJson = originalJson[DbNodeCapabilities.ETHPORTS] {
                let roles = JSONValidator.valiate(key: "roles",
                                                  json: ethernetJson as! JSON,
                                                  expectedType: [[String]].self,
                                                  defaultValue: [Any]()) as! [[String]]
                                
                let roleModels = PhysicalPortRoles.physicalPortRolesFromDescriptions(descriptions: roles)
                
                return roleModels
            }
            
            return [PhysicalPortRoles]()
        }
    }
    
    // VHM-1139: Show net_roles for MEN on the network tab
    public var netPortRoles: [PhysicalPortRoles]? {
        get {
            if let ethernetJson = originalJson[DbNodeCapabilities.ETHPORTS] {
                let roles = JSONValidator.valiate(key: "net_roles",
                                                  json: ethernetJson as! JSON,
                                                  expectedType: [[String]].self,
                                                  defaultValue: [Any]()) as! [[String]]
                if roles.isEmpty {
                    return nil
                }
                
                let roleModels = PhysicalPortRoles.physicalPortRolesFromDescriptions(descriptions: roles)
                
                return roleModels
            }
            
            return nil
        }
    }
    
    public var ethernetConfigs: [Role] {
        get {
            var configs = [Role]()
            
            if let ethernetJson = originalJson[DbNodeCapabilities.ETHPORTS] {
                let configStrings = JSONValidator.valiate(key: "config",
                                                          json: ethernetJson as! JSON,
                                                          expectedType: [String].self,
                                                          defaultValue: [String]()) as! [String]
                
                for configStr in configStrings {
                    configs.append(Role.roleFromDescription(description: configStr))
                }
            }
            
            return configs;
        }
    }
    
    public var wanStaticIps: [Int]? {

        if let ethernetJson = originalJson[DbNodeCapabilities.ETHPORTS] as? JSON {
            guard let wanStaticIps = ethernetJson["wan_static_ip"] as? [Int] else {
                return nil
            }
           
            return wanStaticIps
        }
        
        return nil
    }
}

public struct NodeCapability {
    public var capabilityName: String
    public var capabilityId: String
    public var sourceJson: [String: Any]?
    
    init(from json: JSON, key: String) {
        sourceJson = json
        capabilityId = key
        capabilityName = JSONValidator.valiate(key: DbNodeCapabilities.CapabilityConfigName,
                                        json: json,
                                        expectedType: String.self,
                                        defaultValue: "") as! String
    }
    
    /// Init used to manually create a capability
    ///
    /// - Parameters:
    ///   - key: the key
    ///   - name: the capability name (usually from the JSON)
    init(key: String, name: String) {
        capabilityId = key
        capabilityName = name
    }
}

extension NodeCapability: Equatable {
    public static func == (lhs: NodeCapability, rhs: NodeCapability) -> Bool {
        return lhs.capabilityName == rhs.capabilityName &&
            lhs.capabilityId == rhs.capabilityId
    }
}
