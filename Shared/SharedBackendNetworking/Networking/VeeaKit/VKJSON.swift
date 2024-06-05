//
//  VKJSON.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/23/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

//
//  VKJSON.swift
//  VeeaKit
//
//  Created by Atesh Yurdakul on 12/6/17.
//  Copyright © 2017 Max2. All rights reserved.
//
import Foundation

/**
 
 VKJSON is essentially a typealias for [String: Any] with dedicated functions.
 
 - important:
 It is highly recommended that you use VKJSON instead of [String: Any?] or any
 variations of any Swift dictionary.
 
 For more information, see the
 [documentation](https://max2team.atlassian.net/wiki/spaces/VeeaKitiOS/pages/111411243/VKJSON)
 
 */
public typealias VKJSON = [String: Any?]

public extension Dictionary where Key == String, Value == Any? {
    
    /// Creates a JSON object from Data.
    /// - parameter data: The JSON string.
    init(data: Data) throws {
        
        self.init()
        
        if returnJSONObject(fromData: data) != nil {
            self = returnJSONObject(fromData: data)!
        } else {
            let e = VKJSONInitializeError("Invalid data.")
            throw e
        }
        
    }
    
    /// Creates a JSON object from String.
    /// - parameter data: The JSON string.
    init(data: String) throws {
        
        self.init()
        if returnJSONObject(fromData: data.data(using: String.Encoding.utf8) ?? Data()) != nil {
            self = returnJSONObject(fromData: data.data(using: String.Encoding.utf8) ?? Data())!
        } else {
            let e = VKJSONInitializeError("Invalid data.")
            throw e
        }
        
    }
    
    /// Returns data in pretty printed format
    func serializedData() -> Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return data
        } catch let e {
            VKLog("VKJSON failed to serialize : \(e.localizedDescription)")
            return nil
        }
    }
    
    /// Helper function for creating a JSON from Data.
    fileprivate func returnJSONObject(fromData data: Data)->VKJSON? {
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? VKJSON
            return json ?? nil
        } catch {
            return nil
        }
        
    }
    
}

