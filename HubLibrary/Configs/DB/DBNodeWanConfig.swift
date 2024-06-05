//
//  DBNodeWanConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 07/06/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation

struct DbNodeWanConfig: DbSchemaProtocol {
    static let TableName = "node_wan_config"
    
    static let WAN_1 = "wan_1"; // Object
    static let WAN_2 = "wan_2"; // Object
    static let WAN_3 = "wan_3"; // Object
    static let WAN_4 = "wan_4"; // Object
    
    // WAN Level JSON Keys
    static let USE = "use"; // Boolean (is it in use)
    static let INTERFACE = "interface" // ?
    static let PORT = "port"
    static let NAME = "name" // String
    static let VLANTAG = "vlan_tag"; // Integer (eth0 and eth1)
    static let ZONE = "zone" // String
}
