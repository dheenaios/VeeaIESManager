//
//  PhysicalPortRoles.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 19/09/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public struct PhysicalPortRoles: Equatable {
    
    public var roles: [Role]
    
    init(description: [String]) {
        roles = [Role]()
        
        for item in description {
            roles.append(Role.roleFromDescription(description: item))
        }
    }
    
    static func physicalPortRolesFromDescriptions(descriptions: [[String]]) -> [PhysicalPortRoles] {
        var portRoles = [PhysicalPortRoles]()
        
        for description in descriptions {
            let portRole = PhysicalPortRoles(description: description)
            portRoles.append(portRole)
        }
        
        return portRoles
    }
}
