//
//  DbNodePortConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 10/09/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct DbNodePortConfig: DbSchemaProtocol {
    static var TableName = "node_port_config"
    
    static let PORT_1 = "port_1" // Object
    static let PORT_2 = "port_2" // Object
    static let PORT_3 = "port_3" // Object
    static let PORT_4 = "port_4" // Object
    
    // PORT LEVEL KEYS
    static let PORTNAME = "name"
    static let ROLE = "role"
    static let USE = "use"
    static let LOCKED = "locked"
    static let LANID = "lan_id"
    static let MDNS = "mdns"
    static let MESH = "mesh"
    static let RESET_TRIGGER = "reset_trigger"
}

struct DbMeshPortConfig: DbSchemaProtocol {
    static var TableName = "mesh_port_config"
    
    static let PORT_1 = "port_1" // Object
    static let PORT_2 = "port_2" // Object
    static let PORT_3 = "port_3" // Object
    static let PORT_4 = "port_4" // Object
    
    // PORT LEVEL KEYS
    static let PORTNAME = "name"
    static let ROLE = "role"
    static let USE = "use"
    static let LOCKED = "locked"
    static let LANID = "lan_id"
    static let MDNS = "mdns"
}
