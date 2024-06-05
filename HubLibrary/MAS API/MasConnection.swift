//
//  MasConnection.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 08/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


/// Describes the connection to the MAS over the internet
public class MasConnection: HubConnectionDefinition {
    
    /// Hub was available to the MAS at time of query
    public var wasAvailable = true
    
//    /// Populated when the token gets updated by AuthorisationManager
//    public var currentAuthToken: String
    
    /// The nodeId of the hub to connect too
    public let nodeId: Int
    
    private let base: String
    private let doc = "/doc/"
    
    public var connectionRoute: ConnectionRoute = .MAS_API
    
    public func getBaseURL() -> String {
        let url = base + "\(nodeId)" + doc
        
        return url
    }
    
    func urlFor(tableName: String) -> String {
        if getBaseURL().isEmpty {
            //print("No base url could be created")
            return ""
        }
        
        let url = getBaseURL() + tableName
        
        return url
    }
    
    
    /// A connection to the mas API
    /// - Parameters:
    ///   - nodeId: The node you want to interact with
    ///   - authToken: The authorisation token
    ///   - baseUrl: The base url for the endpoint (by environment QA /Prod)
    public init(nodeId: Int, baseUrl: String) {
        self.base = "https://\(baseUrl)/api/v2/nodes/"
        self.nodeId = nodeId
    }
}
