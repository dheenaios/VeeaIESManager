//
//  MasCallResponse.swift
//  MAS API
//
//  Created by Richard Stockdale on 30/08/2020.
//  Copyright © 2020 Richard Stockdale. All rights reserved.
//

import Foundation

struct MasApiCallResponse {
    var nodeId: Int
    var tableName: String
    var json: JSON?
    var data: Data?
    var error: APIError?
    
//    var tableNamedJson: JSON? {
//        get {
//            guard let json = json else {
//                return nil
//            }
//
//            var namedJson = JSON()
//            namedJson[tableName] = json
//
//            return namedJson
//        }
//    }
}
