//
//  VHNode.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/29/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

enum VHNodeSignalStrength: Int {
    case poor
    case ok
    case good
    case noSignal
}

protocol IESNode: Codable, Equatable, Copying {
    var id: String! {get}
    var name: String! {get}
}

struct VHNode: IESNode {
    init(original: VHNode) {
        self.id = original.id
        self.name = original.name
        self.code = original.code
    }
    
    var id: String!
    var name: String!
    var code: String?
}

struct VHMeshNode: IESNode {
    var id: String!
    var name: String!
    var status: VHNodeStatus!
    var progress: Double?
    var error: VHMeshNode.Error?
    var isMEN: Bool?
    var packages: [VHMeshNodePackage]?

    var hardwareModel: VeeaHubHardwareModel {
        VeeaHubHardwareModel(serial: id)
    }
    
    init(original: VHMeshNode) {
        self.id = original.id
        self.name = original.name
        self.status = original.status
        self.progress = original.progress
        self.error = original.error
        self.isMEN = original.isMEN
        self.packages = original.packages
    }
    
    static func == (lhs: VHMeshNode, rhs: VHMeshNode) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.status == rhs.status && lhs.progress == rhs.progress && lhs.error == rhs.error && lhs.isMEN == rhs.isMEN
    }
    
    
    struct Error: Codable, Equatable {
        let code: Int?
        let message: String?
    }
}

extension VHMeshNode {
    var formattedDeviceName: String {
        return name.replacingOccurrences(of: "_", with: " ")
    }
}

struct VHMeshNodePackage: Codable {
    let title: String?
    let type: String?
    let description: String?
    let pricing: String?
    let features: [String]?
    let packageName: String?
    let active: Bool?
    var commercialApplication: CommercialApplication? // May not exist

    var displayTitle: String? {
        guard let commercialApplication = commercialApplication else {
            return title
        }

        return commercialApplication.name
    }
}

struct CommercialApplication: Codable {
    let commercialId: String
    let name: String //": "Veea Hub Base",
    let description: String? //": "Base package for Veea Hub enrollment",

    /*

     Full JSON

     "commercialApplication": {
         "commercialId": "00000000-BA5E-5A1E-DEA1-000000000001",
         "name": "Veea Hub Base",
         "description": "Base package for Veea Hub enrollment",
         "image": null,
         "partnerId": "00000000",
         "aclId": null,
         "updatedBy": "13df37bb-7a20-4c19-ade5-6b7ff10b7eac",
         "createdAt": 1644906742000,
         "updatedAt": 1644906742000
     }


     */
}
