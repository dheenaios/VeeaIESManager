//
//  DbNodePortStatus.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 06/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct DbNodePortStatus: DbSchemaProtocol {
    
    static let TableName = "node_port_status"
    
    static let PORT_1 = "port_1" // Object
    static let PORT_2 = "port_2" // Object
    static let PORT_3 = "port_3" // Object
    static let PORT_4 = "port_4" // Object

    // Object Level Keys
    static let ipv4_addr = "ipv4_addr"
    static let operational = "operational"
    static let reason = "reason"

    
    
    // MARK: - Other objects added as part of VHM 1197.
    // Not added here as use of Cadable removes the need.
    // Props are the same as the db keys.
    // see PortStatusModel.swift
    
    // conf_lan
    // conf_role
    // conf_state
    // conf_l2
    // info_dhcp


}
