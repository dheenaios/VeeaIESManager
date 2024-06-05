//
//  JwtExtensions.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 04/05/2023.
//

import Foundation
import JWTDecode

extension JWT {
    var userId: Int? {
        return body["user_id"] as? Int
    }

    var jti: String? {
        return body["jti"] as? String
    }

    /// Key cloak user ID
    var sub: String? {
        return body["sub"] as? String
    }
}
