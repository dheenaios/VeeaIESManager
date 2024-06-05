//
//  ApiFactory.swift
//  HubLibrary
//
//  Created by Al on 21/02/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 This class is used to access the IES `API` instance.
 
 You send requests to an IES via an `API` singleton. This factory object provides access to that singletion.
 
 In addition to `instance`, you may use the shorter synonyms `get` or `api` - all of these perform the same operation.
 */
public class ApiFactory {
    /// - parameter instance: the API instance
    public static let instance = createImplementation()
    
    /// - parameter api: the API instance
    public static let api = instance

    /// - parameter get: the API instance
    public static let get = instance
        
    private static func createImplementation() -> API {
        return APIImpl()
    }
}
