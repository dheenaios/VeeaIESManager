//
//  DbNodeApConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 07/06/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation


/// This actually covers 2 tables: mesh_ap_config and node_ap_config
struct DbApConfig {
    static let TableNameMesh = "mesh_ap_config"
    static let TableNameNode = "node_ap_config"
    
    static let AP_1_1 = "ap_1_1"
    static let AP_1_2 = "ap_1_2"
    static let AP_1_3 = "ap_1_3"
    static let AP_1_4 = "ap_1_4"
    static let AP_1_5 = "ap_1_5"
    static let AP_1_6 = "ap_1_6"
    
    
    static let AP_2_1 = "ap_2_1"
    static let AP_2_2 = "ap_2_2"
    static let AP_2_3 = "ap_2_3"
    static let AP_2_4 = "ap_2_4"
    static let AP_2_5 = "ap_2_5"
    static let AP_2_6 = "ap_2_6"
    
    // MARK: - AP Level JSON Keys
    static let PSK = "psk"
    static let PASSWORD = "pass"
    static let USE = "use"
    static let LOCKED = "locked"
    static let SSID = "ssid"
    static let MDNS = "mdns"
    static let HIDDEN = "hidden"
    static let LAN_ID = "lan_id"
    static let SYSTEM_ONLY = "system_only"
    
    // Security
    static let SECUREMODE = "secure_mode"
    static let ENCRYPTMODE = "wpa_mode"
    static let RADIUS1AUTHID = "radius1_auth_id"
    static let RADIUS2AUTHID = "radius2_auth_id"
    static let RADIUS1ACCTID = "radius1_acct_id"
    static let RADIUS2ACCTID = "radius2_acct_id"
    
    static let ENABLE80211R = "80211r"
    static let ENABLE80211W = "80211w"
    
    
}
