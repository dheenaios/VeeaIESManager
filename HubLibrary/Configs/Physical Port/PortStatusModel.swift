//
//  PortStatusModel.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 06/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

/// Models relating to NodePortStatusConfig

public class PortStatusModel: Equatable, Codable {
    
    public static func == (lhs: PortStatusModel, rhs: PortStatusModel) -> Bool {
        return lhs.ipv4_addr == rhs.ipv4_addr &&
        lhs.operational == rhs.operational &&
        lhs.reason == rhs.reason &&
        lhs.reason == rhs.link_state
    }
    
    
    // is_in_used
    public var is_used: Bool?
    public let ipv4_addr: String
    public var operational: Bool
    public let reason: String
    public var link_state: String?
}

// MARK: - Additional models added as part of VHM 1197. These will not exist on older hubs

// conf_lan
public struct ConfLan: Codable {
    let port_1: Int
    let port_2: Int
    let port_3: Int
    let port_4: Int
}

// conf_role
public struct ConfRole: Codable {
    let port_1: String
    let port_2: String
    let port_3: String
    let port_4: String
}

// conf_l2
public struct ConfL2: Codable {
    let port_1: Bool
    let port_2: Bool
    let port_3: Bool
    let port_4: Bool
}

// conf_state
public struct ConfState: Codable {
    let port_1: Int
    let port_2: Int
    let port_3: Int
    let port_4: Int
}

// info_dhcp
public struct InfoDhcp: Codable {
    let lan_1: [String]
    let lan_2: [String]
    let lan_3: [String]
    let lan_4: [String]
}
