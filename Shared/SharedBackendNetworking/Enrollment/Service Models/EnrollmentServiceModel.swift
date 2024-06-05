//
//  EnrollmentServiceModel.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/29/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct EnrollStatusModel: Decodable,Equatable {
    static func == (lhs: EnrollStatusModel, rhs: EnrollStatusModel) -> Bool {
        return lhs.percentage == rhs.percentage && lhs.approxTimeRemaining == rhs.approxTimeRemaining && lhs.items == rhs.items && lhs.device == rhs.device && lhs.mesh == rhs.mesh
    }
    
    let percentage: Double!
    let approxTimeRemaining: Double!
    
    struct StatusItem: Decodable, Equatable {
        let name: String!
        let percentage: Double?
    }
    
    let items: [StatusItem]!
    let device: VHNode!
    let mesh: VHMesh!
}


struct EnrollStartResponse: Decodable {
    let device: VHNode!
    let mesh: VHMesh!
    let connection: String!
}
