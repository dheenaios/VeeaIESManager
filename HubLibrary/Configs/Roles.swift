//
//  Roles.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 02/04/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

public enum Role: String, Codable {
    case WAN = "wan"
    case LAN = "lan"
    case MESH = "mesh"
    case DEBUG = "debug"
    case UNUSED = ""
    
    public static func roleFromDescription(description: String) -> Role {
        switch description {
        case "wan":
            return Role.WAN
        case "lan":
            return Role.LAN
        case "mesh":
            return Role.MESH
        case "debug":
            return Role.DEBUG
        case "":
            return Role.UNUSED
        default:
            return Role.UNUSED
        }
    }
}
