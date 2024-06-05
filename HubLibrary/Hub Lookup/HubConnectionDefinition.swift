//
//  HubConnectionDefinition.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 07/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

/// How the Veea Hub should connect
///
/// - CURRENT_GATEWAY: Returns the default gateway for whatever AP is currently connected
/// - DNS: Use the DNS address if present
/// - MDNS: Use the mDNS address if present
public enum ConnectionRoute {
    case CURRENT_GATEWAY // This could be the Beacon AP
    case DNS
    case MAS_API
    
    public func getDescription() -> String {
        switch self {
        case .DNS:
            return "LAN"
        case .MAS_API:
            return "VeeaCloud"
        default:
            return "VeeaHub Wi-Fi"
        }
    }
}


/// Defines a connection to a veea Hub, be that via AP, LAN or MAS API
public protocol HubConnectionDefinition {
    
    /// How the connection is being made
    var connectionRoute: ConnectionRoute { get set }
    
    /// The base URL for the type of connection
    func getBaseURL() -> String
}
