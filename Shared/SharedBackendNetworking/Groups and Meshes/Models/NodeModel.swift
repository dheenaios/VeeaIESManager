//
//  NodeModel.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 20/06/2022.
//

import Foundation

public enum VHNodeStatus: String, Codable {
    case ready
    case bootstrapping
    case onboarding
    case waitingBootstrap = "waiting.bootstrapping"
    case error = "errors"


    var description: String {
        switch self {
        case .ready:
            return "Available"
        case .bootstrapping, .onboarding, .waitingBootstrap :
            return "Preparing for first use .."
        default:
            return "Unavailable"
        }
    }
}

// Simplified version of VHNode / VHMeshNode
public struct NodeModel: Codable, Equatable {
    public var id: String!
    public var name: String!
    public var status: VHNodeStatus!
    public var isMEN: Bool?
    public var error: NodeModel.Error?

    public struct Error: Codable, Equatable {
        let code: Int?
        let message: String?
    }

    public static func == (lhs: NodeModel, rhs: NodeModel) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.status == rhs.status &&
        lhs.error == rhs.error &&
        lhs.isMEN == rhs.isMEN
    }
}
