//
//  MasCallResponse.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 11/07/2022.
//

import Foundation

public struct MasApiCallResponse {
    public var nodeId: Int
    public var tableName: String
    public var json: JSON?
    public var data: Data?
    public var error: APIError?
}
