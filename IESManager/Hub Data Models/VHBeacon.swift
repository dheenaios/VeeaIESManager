//
//  VHBeacon.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 4/3/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct VHBeacon: Codable, Identifiable {
    var id = UUID() // Identifiable conformance

    let subdomain: String!
    let instanceID: String!
    let encryptKey: String!

    // Group ID and mesh added after init to permit matching of the beacon to
    // the group / mesh
    var groupId: String = ""
    var meshId: String = ""
    var meshName: String = ""

    var asDict: [String : String] {
        ["subdomain" : subdomain,
         "instanceID" : instanceID,
         "encryptKey"  : encryptKey,
         "groupId" : groupId,
         "meshId" : meshId,
         "meshName" : meshName]
    }

    init?(dict: [String : String]) {
        if let subdomain = dict["subdomain"],
           let instanceID = dict["instanceID"],
           let encryptKey = dict["encryptKey"],
           let groupId = dict["groupId"],
           let meshId = dict["meshId"],
           let meshName = dict["meshName"] {
            self.subdomain = subdomain
            self.instanceID = instanceID
            self.encryptKey = encryptKey
            self.groupId = groupId
            self.meshId = meshId
            self.meshName = meshName
        }
        else { return nil }
    }

    enum CodingKeys: CodingKey {
        case subdomain
        case instanceID
        case encryptKey
    }
}
