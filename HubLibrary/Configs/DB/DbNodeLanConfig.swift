//
//  DbNodeLanConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 29/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct  DbNodeLanConfig: DbSchemaProtocol {
    static var TableName = "node_lan_dhcp"
    
    static let LAN_1 = "lan_1" // Object
    static let LAN_2 = "lan_2" // Object
    static let LAN_3 = "lan_3" // Object
    static let LAN_4 = "lan_4" // Object
    
    // Object keys
    static let ALLOW_MAC = "allow_mac"
    static let DNS_1 = "dns_1"
    static let DNS_2 = "dns_2"
    static let START_IP = "start_ip"
    static let END_IP = "end_ip"
    static let FILTER_MAC = "filter_mac"
    static let LEASE_TIME = "lease_time"
}
