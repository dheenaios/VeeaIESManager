//
//  DataExtensions.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 17/06/2022.
//

import Foundation

public extension Data {
    var prettyPrintedString: String? {
        if let json = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            return String(decoding: jsonData, as: UTF8.self)
        }

        return nil
    }
}
