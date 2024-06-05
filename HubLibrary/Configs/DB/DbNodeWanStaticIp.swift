//
//  DbNodeWanStaticIp.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 17/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

struct DbNodeWanStaticIp: DbSchemaProtocol {
    static var TableName = "node_wan_static_ip"
    
    // MARK: - Object Level
    static let wan_1 = "wan_1"
    static let wan_2 = "wan_2"
    static let wan_3 = "wan_3"
    static let wan_4 = "wan_4"
    
    // MARK: - Object props
    static let use = "use"
    static let ip4_address = "ip4_address"
    static let ip4_gateway = "ip4_gateway"
    static let ip4_dns_1 = "ip4_dns_1"
    static let ip4_dns_2 = "ip4_dns_2"
}

/*
 
 wan_1={'use': True, 'ip4_address': '', 'ip4_gateway': '', 'ip4_dns_1': '', 'ip4_dns_2': ''},
 wan_2={'use': True, 'ip4_address': '', 'ip4_gateway': '', 'ip4_dns_1': '', 'ip4_dns_2': ''},
 wan_3={'use': True, 'ip4_address': '', 'ip4_gateway': '', 'ip4_dns_1': '', 'ip4_dns_2': ''},
 wan_4={'use': True, 'ip4_address': '', 'ip4_gateway': '', 'ip4_dns_1': '', 'ip4_dns_2': ''}:
 
 */
