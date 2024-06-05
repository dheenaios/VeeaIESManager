//
//  APIError.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 11/07/2022.
//

import Foundation

public enum APIError: Error {
    case Failed(message: String)
    case NoData(reason: Error)
    case NoConnection

    public func errorDescription() -> String {
        switch self {
        case .NoConnection:
            return "No IES Connected"
        case .Failed(message: let reason):
            return reason
        case .NoData(reason: let error):
            return "API call returned no data: \(error.localizedDescription)"
        }
    }
}
