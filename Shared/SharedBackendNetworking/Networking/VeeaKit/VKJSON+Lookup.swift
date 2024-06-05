//
//  VKJSON+Lookup.swift
//  VeeaKit
//
//  Created by Atesh Yurdakul on 12/6/17.
//  Copyright © 2017 Max2. All rights reserved.
//
import Foundation

public extension Dictionary where Key == String, Value == Any? {
    
    /// Returns the value if it can be read as the same type as
    /// the defaultValue. Otherwise, returns nil.
    /// - parameter key:    The key to look for (ie: `name`)
    /// - parameter type:   The type the value *should be* in. For example, `String.self`. If the type of the value is different, this function will return ``nil``.
    /// - returns:          The value if it is found and is in the type provided, otherwise nil.
    ///
    ///  For more information, see the [documentation](https://max2team.atlassian.net/wiki/spaces/VeeaKitiOS/pages/111411243/VKJSON)
    func lookup<T>(key: String, type: T.Type) -> T? {
        return (self[key] as? T) ?? nil
    }
    
    /// Returns the value if it can be read as the same type as
    /// the defaultValue. Otherwise, returns defaultValue.
    /// - parameter key:    The key to look for, for example, `name`
    /// - parameter defaultValue:   The type the value *should be* in. For example, to get a String value, pass a String as default.
    /// - returns:          The value if it is found and is in the type provided, otherwise the ``defaultValue`` provided.
    ///
    ///  For more information, see the [documentation](https://max2team.atlassian.net/wiki/spaces/VeeaKitiOS/pages/111411243/VKJSON)
    func lookup<T>(key: String, defaultValue: T) -> T {
        return (self[key] as? T) ?? defaultValue
    }
    
    /// Returns the value from a path (ie: "users.information.name")
    /// if it can be read as the same type as
    /// the defaultValue. Otherwise, returns nil.
    /// - parameter path:    The path to look for, for example, `owner.name`
    /// - parameter type:   The type the value *should be* in. For example, `String.self`. If the type of the value is different, this function will return ``nil``.
    /// - returns:          The value if it is found and is in the type provided, otherwise nil.
    ///
    ///  For more information, see the [documentation](https://max2team.atlassian.net/wiki/spaces/VeeaKitiOS/pages/111411243/VKJSON)
    func lookup<T>(path: String, type: T.Type)-> T? {
        
        let pathArray = path.components(separatedBy: ".")
        
        var currentObject = self
        var result: Any?
        
        for (index, element) in pathArray.enumerated() {
            
            if (index == pathArray.count - 1) {
                // We are at the last element.
                // We don't need to read them as VKJSON anymore.
                result = currentObject.lookup(key: element, type: T.self)
                break
            }
            
            let lookupResult = (currentObject.lookup(key: element, type: VKJSON.self))
            if lookupResult == nil {
                return nil
            } else {
                currentObject = lookupResult!
            }
            
        }
        
        return (result as? T) ?? nil
        
    }
    
    /// Returns the value from a path (ie: "users.information.name")
    /// if it can be read as the same type as
    /// the defaultValue. Otherwise, returns defaultValue.
    /// - parameter path:    The path to look for, for example, `owner.name`
    /// - parameter defaultValue:   The type the value *should be* in. For example, to get a String value, pass a String as default.
    /// - returns:          The value if it is found and is in the type provided, otherwise the ``defaultValue`` provided.
    ///
    ///  For more information, see the [documentation](https://max2team.atlassian.net/wiki/spaces/VeeaKitiOS/pages/111411243/VKJSON)
    func lookup<T>(path: String, defaultValue: T)-> T {
        
        let pathArray = path.components(separatedBy: ".")
        
        var currentObject = self
        var result: Any?
        
        for (index, element) in pathArray.enumerated() {
            
            if (index == pathArray.count - 1) {
                // We are at the last element.
                // We don't need to read them as VKJSON anymore.
                result = currentObject.lookup(key: element, type: T.self)
                break
            }
            
            let lookupResult = (currentObject.lookup(key: element, type: VKJSON.self))
            if lookupResult == nil {
                return defaultValue
            } else {
                currentObject = lookupResult!
            }
            
        }
        
        return (result as? T) ?? defaultValue
        
    }
    
    /// Tries to read a long int or string key and return it as a string.
    /// - parameter key: The key to look for.
    /// - returns:  The value if it can be read, else, nil.
    func longLookupAsString(key: String)->String? {
        
        if let readData = self[key] as? String {
            return readData
        }
        
        if let readData = self[key] as? NSNumber {
            return readData.stringValue
        }
        
        if let readData = self[key] as? NSDecimalNumber {
            return readData.stringValue
        }
        
        if let readData = self[key] as? Int64 {
            return NSDecimalNumber(value: readData as Int64).stringValue
        }
        
        return nil
        
    }
    
}
