//
//  VHMesh.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/17/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct VHMesh: Codable, Equatable {
    static func == (lhs: VHMesh, rhs: VHMesh) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.devices == rhs.devices && lhs.timezoneArea == rhs.timezoneArea && lhs.timezoneRegion == rhs.timezoneRegion && lhs.country == rhs.country
    }
    
    let id: String!
    let name: String!
    var devices: [VHMeshNode]?
    let timezoneArea: String!
    let timezoneRegion: String!
    let country: String!

    var beacon: VHBeacon?
}

extension VHMesh {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case devices
        case timezoneArea = "nc_node_timezone_area"
        case timezoneRegion = "nc_node_timezone_region"
        case country = "nc_node_country"
    }
}
