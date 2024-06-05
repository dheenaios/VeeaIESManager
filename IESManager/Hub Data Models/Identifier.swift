//
//  Identifier.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 5/7/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct Identifier: Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
    
    private var raw: String
    
    init(_ stringValue: String) {
        self.raw = stringValue
    }
    
    init(stringLiteral value: String) {
        raw = value
    }
    
    var description: String {
        return self.raw
    }
    
}

extension Identifier: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self.init(raw)
    }
    
    func encode(from encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.raw)
    }
}
