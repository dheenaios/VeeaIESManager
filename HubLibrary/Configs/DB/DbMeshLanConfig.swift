//
//  DbMeshLanConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 07/06/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation

struct DbMeshLanConfig: DbSchemaProtocol {
    static let TableName = "mesh_lan_config"
    
    // Top Level JSON Keys
    static let SERIAL_NUMBER = "serial_number";
    
    static let LAN_1 = "lan_1"; // Object
    static let LAN_2 = "lan_2"; // Object
    static let LAN_3 = "lan_3"; // Object
    static let LAN_4 = "lan_4"; // Object
    
    // LAN Level JSON Keys
    static let USE = "use"; // Boolean (is it in use)
    static let MODIFY = "modify"; 
    static let NAME = "name"; // String
    static let WAN = "wan_mode"; // String
    static let WAN_INTERFACE = "wan_id"; // Integer (eth0 and eth1)
    static let SUBNET = "ip4_subnet"; // String
    static let AP_SET_2 = "ap_set_2"; // String
    static let AP_SET_1 = "ap_set_1"; // Array of Strings
    static let DHCP = "dhcp"; // Bool
    static let MODE_VIA = "mode_via" // String
    static let ZONE = "zone" // String
    static let PORT_SET = "port_set" // String
    static let VLAN_SET = "vlan_set" // String
    static let CLIENT_TRAFFIC = "client_traffic" // String
    static let IP_Mode = "ip_mode"
}
