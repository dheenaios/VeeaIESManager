//
//  CommonResponseCodables.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 07/08/2023.
//

import Foundation

public struct ResponseMeta: Codable {
    let status: Int
    let message: String?
}
