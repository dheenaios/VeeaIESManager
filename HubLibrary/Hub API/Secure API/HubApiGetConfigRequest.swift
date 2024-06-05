//
//  SecureRequestConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 12/04/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation


/// Use to create DB requests to GET data out of the DB via the secure apis node method (/api/v1/node)
public class HubApiGetConfigRequest {
    private var mTableName: String
    private var mKeys: [String]
    
    func getTableName() -> String {
        return mTableName
    }
    
    func getKeys() -> [String] {
        return mKeys;
    }
    
    // MARK: - Init Methods
    
    /// Default init method. Private to defeat attempts to use
    fileprivate init() {
        mTableName = ""
        mKeys = [String]()
    }
    
    /// Create a configuration with the table name and a set of keys
    ///
    /// - Parameters:
    ///   - tableName: The name of the db table
    ///   - keys: The keys for the DB table that you would like to retreive
    init(tableName: String, keys: [String]) {
        mTableName = tableName
        mKeys = keys
    }
}

/// Subclass of SecureRequestConfig used for making updates
/// You can specify keys manually using init(tableName: String, keys: [String], values: [Any])
/// Or you can simply pass in the json from a struct conforming to the SecureAPIRequestConfigProtocol
public class HubApiUpdateConfigRequest: HubApiGetConfigRequest {
    private var mValues: [Any]
    private var mPreCannedJson: SecureUpdateJSON?
    
    /// Manually specify the items to be updated
    ///
    /// - Parameters:
    ///   - tableName: The name of the table to be updated
    ///   - keys: the keys to be updated
    ///   - values: the values to be updated
    init(tableName: String, keys: [String], values: [Any]) {
        mValues = values
        mPreCannedJson = nil
        super.init(tableName: tableName, keys: keys)
    }
    
    /// Initialise the config using the JSON from the SecureAPIRequestConfigProtocol conforming struct
    ///
    /// - Parameter json: JSON from the SecureAPIRequestConfig struct
    init(json :SecureUpdateJSON) {
        mPreCannedJson = json
        mValues = [Any]()
        super.init()
    }
    
    /// Return the manually specified values
    ///
    /// - Returns: Array of values. These can be any object
    func getValues() -> [Any] {
        return mValues
    }
    
    /// If the SecureAPIRequestConfigProtocol conforming struct has provided the json then we just need to return it
    ///
    /// - Returns: SecureUpdateJSON provided by the config
    func getUpdateJSON() -> SecureUpdateJSON? {
        if let json = mPreCannedJson {
            return json
        }
        
        return compileJSON()
    }
    
    private func compileJSON() -> SecureUpdateJSON? {
        var hash = [String : [String : Any]]()
        
        var keyAndValues = [String : Any]()
        
        for (index, key) in getKeys().enumerated() {
            keyAndValues[key] = getValues()[index]
        }
        
        hash[getTableName()] = keyAndValues
        
        return hash
    }
}
