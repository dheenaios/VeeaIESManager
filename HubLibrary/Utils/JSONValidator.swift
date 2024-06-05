//
//  JSONValidator.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 28/08/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation

struct JSONValidator {
    
    static let tag = "JSON Validator"
    
    
    /// Takes a json object, a key, an expected type and a default value.
    /// If the value is present and of the correct type the value is returned
    /// If not then the default value is returned
    ///
    /// - Parameters:
    ///   - key: The key for the value
    ///   - json: The json object
    ///   - expectedType: The expected type of the resultant value
    ///   - defaultValue: A default value to be returned if all is not as expected
    /// - Returns: A value or a default value
    static func valiate<T>(key: String, json: JSON, expectedType: T.Type, defaultValue: Any) -> Any {
        guard let value = json[key] else {
            Logger.log(tag: tag, message: "No value found for key: \(key). Returning default value")
            return defaultValue
        }
        
        if value is T {
            return value
        }
        
        Logger.log(tag: tag, message: "Value for \(key) is of an unexpected \(type(of: value)) type. Was expecting \(type(of: expectedType)). Returning default value")
        
        if defaultValue is T {
            return defaultValue
        }
        
        let message = "The Default Value for \(key) is of an unexpected \(type(of: value)) type. Was expecting \(type(of: expectedType)). Returning default value. This may cause a crash"
        
        Logger.log(tag: tag, message: message)
        
        return defaultValue
    }
}
