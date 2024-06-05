//
//  SecureURLRequestFactory.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 12/04/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit

class SecureURLRequestFactory {
    private static let tag = "SecureURLRequestFactory"
    
    /// Creates a login request to be sent as part of the login
    ///
    /// - Parameter connection: The connection to use
    /// - Returns: the URLRequest created (optional)
    static func createLoginURLRequest(connection: VeeaHubConnection) -> URLRequest? {
        let base = connection.getBaseURL()
        let urlString = "\(base)login"
        
        guard let loginURL = URL(string: urlString) else {
            return nil
        }
        
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        
        request.addValue(BasicAuth.basicAuthID, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }
    
    /// Creates a PUT request for a call to node
    ///
    /// - Parameters:
    ///   - connection: The connection to use
    ///   - configs: Configurations for the payload
    /// - Returns: The URLRequest optional
    static func createPutRequest(connection :VeeaHubConnection,
                                 configs :[HubApiGetConfigRequest]) -> URLRequest? {
        guard var request = getBasePutRequest(connection: connection) else {
            return nil
        }
        
        if let data = requestConfigsToJSON(configs: configs) {
            request.httpBody = data
        }
        else {
            Logger.log(tag: tag, message: "Config could not be converted to JSON")
            
            return nil
        }
        
        return request
    }
    
    /// Returns a put request with no body
    ///
    /// - Parameter connection: The connection in use
    /// - Returns: The URLRequest optional
    static func getBasePutRequest(connection :VeeaHubConnection) -> URLRequest? {
        let base = connection.getBaseURL()
        let urlString = "\(base)node"
        
        guard let loginURL = URL(string: urlString) else {
            return nil
        }
        
        guard let token = SecureAPIAuthorisation.shared.getCachedToken() else {
            return nil
        }
        
        var request = URLRequest(url: loginURL)
        
        request.httpMethod = "PUT"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    static func createPatchRequest(connection :VeeaHubConnection, config :HubApiUpdateConfigRequest) -> URLRequest? {
        let base = connection.getBaseURL()
        let urlString = "\(base)node"
        
        guard let loginURL = URL(string: urlString) else {
            return nil
        }
        
        guard let token = SecureAPIAuthorisation.shared.getCachedToken() else {
            return nil
        }
        
        var request = URLRequest(url: loginURL)
        
        request.httpMethod = "PATCH"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let data = updateConfigToJSONData(config: config) {
            request.httpBody = data
        }
        else {
            return nil
        }
        
        return request
    }
    
    // MARK: - Helpers
    
    private static func requestConfigsToJSON(configs :[HubApiGetConfigRequest]) -> Data? {
        var hash = [String : [String]]()
        
        for config in configs {
            hash[config.getTableName()] = config.getKeys()
        }
        
        do {
            let json = try JSONSerialization.data(withJSONObject: hash, options:.prettyPrinted)
            
            return json
        }
        catch {
            Logger.log(tag: tag, message: "Error converting Secure Request config to data")
            return nil
        }
    }
    
    private static func updateConfigToJSONData(config :HubApiUpdateConfigRequest) -> Data? {
        guard var configsJSON = config.getUpdateJSON() else {
            return nil
        }
        
        // Remove _id and _rev keys and values (VHM-860)
        for (key, value) in configsJSON {
            var innerJson = value
            innerJson.removeValue(forKey: "_rev")
            innerJson.removeValue(forKey: "_id")
            
            configsJSON[key] = innerJson
        }
        
        do {
            let json = try JSONSerialization.data(withJSONObject: configsJSON, options:.prettyPrinted)
            
            return json
        }
        catch {
            return nil
        }
    }
}

