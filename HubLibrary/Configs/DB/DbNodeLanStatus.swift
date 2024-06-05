//
//  DbNodeLanStatus.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 02/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

struct DbNodeLanStatus: DbSchemaProtocol {
    static var TableName = "node_lan_status"
    
    static let LAN_1 = "lan_1" // Object
    static let LAN_2 = "lan_2" // Object
    static let LAN_3 = "lan_3" // Object
    static let LAN_4 = "lan_4" // Object
    
    // MARK: - Object keys
    static let reason = "reason" // Object
    static let ip4_subnet = "ip4_subnet" // Object
    static let operational = "operational" // Object
}
