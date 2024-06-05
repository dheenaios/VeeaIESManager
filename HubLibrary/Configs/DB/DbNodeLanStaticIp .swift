//
//  DbNodeLanStaticIp .swift
//  HubLibrary
//
//  Created by Richard Stockdale on 24/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct DbNodeLanStaticIp: DbSchemaProtocol {
    static var TableName = "node_lan_static_ip"

    static let LAN_1 = "lan_1" // Object
    static let LAN_2 = "lan_2" // Object
    static let LAN_3 = "lan_3" // Object
    static let LAN_4 = "lan_4" // Object
    
    
    // Object keys
    static let HOST = "host"
    static let IP = "ip"
    static let MAC = "mac"
    static let NAME = "name"
    static let USE = "use"
}
