//
//  VKJSONInitializeError.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/23/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public struct VKJSONInitializeError: Error {
    
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
    
}
