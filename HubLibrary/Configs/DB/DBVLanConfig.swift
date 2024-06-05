//
//  DBVLanConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 02/04/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

struct  DbNodeVLanConfig: DbSchemaProtocol {
    static var TableName = "node_vlan_config"
    
    static let VLAN_1 = "vlan_1" // Object
    static let VLAN_2 = "vlan_2" // Object
    static let VLAN_3 = "vlan_3" // Object
    static let VLAN_4 = "vlan_4" // Object
    
    static let LOCKED = "locked"
    static let NAME = "name"
    static let PORT = "port"
    static let ROLE = "role"
    static let TAG = "tag"
    static let USE = "use"
}

// Same as the above other than the table name
struct  DbMeshVLanConfig: DbSchemaProtocol {
    static var TableName = "mesh_vlan_config"
    
    static let VLAN_1 = "vlan_1" // Object
    static let VLAN_2 = "vlan_2" // Object
    static let VLAN_3 = "vlan_3" // Object
    static let VLAN_4 = "vlan_4" // Object
    
    static let LOCKED = "locked"
    static let NAME = "name"
    static let PORT = "port"
    static let ROLE = "role"
    static let TAG = "tag"
    static let USE = "use"
}
