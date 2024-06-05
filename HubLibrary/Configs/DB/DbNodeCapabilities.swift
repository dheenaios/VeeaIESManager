//
//  DbNodeCapabilities.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 12/03/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

struct DbNodeCapabilities: DbSchemaProtocol {
    static let TableName = "node_capabilities"
    static let Capabilities = "capabilities"
    static let Features = "features"
    
    static let management = "management"
    static let node_status = "node_status"

    /// Known Capability Object Keys
    
    // MARK: - DB Object Keys
    static let CapabilityConfigName = "name"
    
    // MARK: - Known capability names
    // used in NodeCapabilities helper methods
    // NOTE: There may in time be many more and the existing ones may change
    static let PhysicalAP1Key = "ap"
    static let PhysicalAP2Key = "ap2"
    static let BluetoothKey = "bluetooth"
    static let VmeshKey = "vmesh"
    static let ZigbeeKey = "zigbee"
    static let CellularKey = "cellular"
    static let WifiWan = "wifi_wan"
    
    static let ETHERNET = "ethernet"
    static let ETHPORTS = "ethports"
    static let WANSTATICIP = "wan_static_ip"
    
    // AP
    static let apKey = "ap"
    static let ap2Key = "ap2" /// Top Level Object
    
    static let singleBand = "single_band"
    static let meshRadioKey = "mesh_radio"
    static let multiRadio = "multi_radio"
    
    //ACS
    static let acsSupport = "acs_support"
    static let dfsSupport = "dfs_support"
    static let unii1_and_dfs_ch = "unii1_and_dfs_ch"
    
    // VMESH
    static let vmeshAcsSupport = "acs_support"
    static let vmeshDfsSupport = "dfs_support"
    static let vmeshUnii1AndDfsCh = "unii1_and_dfs_ch"
    static let vmeshName = "name"
    static let radioSelect = "radio_select"
    static let wdsSupport = "wds_support"
    
    // MANAGEMENT
    static let keysRewritable = "keys_rw"
    static let keysRewritableIpMode = "ip_mode"
    static let keysReadOnlyIpMode = "ip_mode"
    
    static let keysReadOnly = "keys_ro"
    static let managementTables = "tables"
    
    static let tables_ro = "tables_ro"
    static let cellular_ipv4_addr = "cellular_ipv4_addr"
    static let wifi_ipv4_addr = "wifi_ipv4_addr"
    
    // 802.11ax
    static let supports80211ax = "80211ax"
    
    static let vmesh_local_control = "vmesh_local_control"
}
