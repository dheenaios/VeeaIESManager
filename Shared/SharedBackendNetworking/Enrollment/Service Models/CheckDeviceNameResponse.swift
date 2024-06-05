//
//  CheckDeviceNameResponse.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 2/5/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct CheckDeviceNameResponse: Decodable {
    let owner: String!
    var meshes: [VHMesh]!
}
