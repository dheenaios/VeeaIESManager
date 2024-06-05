//
//  PortConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 10/09/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public struct PortConfigModel: Codable {
    
    private var originalJson: JSON = JSON()
    
    public var name: String
    public var role: Role
    public var use: Bool
    public var locked: Bool
    public var lan_id: Int
    @DecodableDefault.False var mdns: Bool
    @DecodableDefault.False var mesh: Bool
    public var reset_trigger: Bool? // VHM 1206
    
    private enum CodingKeys: String, CodingKey {
        case name, role, use, locked, lan_id, mdns, mesh, reset_trigger
    }
    
    var isEmpty: Bool {
        use == false
    }
    
    func getUpdateJSON() -> JSON {
        var json = originalJson
        json[DbNodePortConfig.PORTNAME] = name
        
        if use {
            json[DbNodePortConfig.ROLE] = role.rawValue
        }
        else {
            json[DbNodePortConfig.ROLE] = Role.UNUSED.rawValue
        }
        
        json[DbNodePortConfig.USE] = use
        json[DbNodePortConfig.LOCKED] = locked
        json[DbNodePortConfig.LANID] = lan_id
        json[DbNodePortConfig.MDNS] = mdns
        json[DbNodePortConfig.MESH] = mesh
        json[DbNodePortConfig.RESET_TRIGGER] = reset_trigger
        
        return json
    }
}

extension PortConfigModel: Equatable {
    public static func == (lhs: PortConfigModel, rhs: PortConfigModel) -> Bool {
        return lhs.name == rhs.name &&
            lhs.role == rhs.role &&
            lhs.use == rhs.use &&
            lhs.locked == rhs.locked &&
            lhs.mdns == rhs.mdns &&
            lhs.mesh == rhs.mesh
    }
}
