//
//  DbNodeLanConfigStaticIp.swift
//  IESManager
//
//  Created by Richard Stockdale on 31/03/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation

struct DbNodeLanConfigStaticIp: DbSchemaProtocol {
    static var TableName = "node_lan_config_static_ip"

    // MARK: - Object Level
    static let lan_1 = "lan_1"
    static let lan_2 = "lan_2"
    static let lan_3 = "lan_3"
    static let lan_4 = "lan_4"

    // MARK: - Object props
    static let use = "use"
    static let ip4_address = "ip4_address"
    static let ip4_gateway = "ip4_gateway"
    static let ip4_dns_1 = "ip4_dns_1"
    static let ip4_dns_2 = "ip4_dns_2"
}
