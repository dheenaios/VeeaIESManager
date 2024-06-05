//
//  BundleExtension.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 6/18/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

extension Bundle {
    /// Loads data from given file name from main Bundle
    public func jsonData(fromFile name: String, format: String) throws -> Data? {
        if let filepath = Bundle.main.path(forResource: name, ofType: format) {
            let contents = try String(contentsOfFile: filepath)
            return contents.data(using: .utf8)
        }
        return nil
    }
}
