//
//  UpdateResponseTypes.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 24/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

/// Errors relating to requests for mesh updates
public enum MeshUpdateError: Error {
    case notAuthorised
    case noData(message: String)
    case errorInResponse(error: Error)
    case unsuccessfulHttpResponse(httpCode: Int, message: String)
    case badlyFormedJson(message: String)
    case notFound
    case partialResponse(message: String)
    
}

// This is used in a couple of places
public struct ResponseMeta: Codable {
    let status: Int
    let message: String?
}

public struct MeshStatusResponse: Codable {
    let meta: ResponseMeta
    let response: ResponseItem
    
    }

public struct ResponseItem: Codable {
    let status: String
}


