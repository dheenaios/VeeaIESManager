//
//  VHUser.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 16/06/2022.
//

import Foundation

public struct VHUser: Codable, Equatable {
    public let id: Int64!
    public let username: String!
    public let firstName: String!
    public let lastName: String?
    public let photoURL = ""
    public let email: String!
    public let firstTimeLogin = false
    public let individualId: String? // Optional as the user may have this stored in the keychain
    public let sub: String?

    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username = "preferred_username"
        case firstName = "given_name"
        case lastName = "family_name"
        case photoURL
        case email
        case firstTimeLogin
        case individualId = "individual_id"
        case sub
    }
}

extension VHUser {
    static func mockUser() -> VHUser {
        return VHUser(id: 123456,
                      username: "tommy12345",
                      firstName: "Tommy",
                      lastName: "OneTwo",
                      email: "one@two.com",
                      individualId: "Some ID",
                      sub: "Sub")
    }
}
