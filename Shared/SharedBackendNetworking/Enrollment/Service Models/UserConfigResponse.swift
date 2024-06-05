//
//  UserConfigResponse.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 2/21/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct UserConfigResponse: Codable {
    
    let ownerId: String!
    let meshes: [VHMesh]?
    let mas: [VHmas]?
    let beacons: [VHBeacon]?
}
