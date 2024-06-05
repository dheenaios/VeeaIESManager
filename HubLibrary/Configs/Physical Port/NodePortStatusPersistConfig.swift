//
//  NodePortStatusPersistConfig.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 24/09/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

// This table was added, but later removed. Leaving it in for a while just in case. 15 October 2021
// Remove if it remains unused
public struct NodePortStatusPersistConfigTemp: Equatable, Codable {
    
    var originalJson: JSON = JSON()
    static let TableName = "node_port_status_persist"
    
    public var ports: [NodePortStatusPersistPortModel] {
        return [port_1, port_2, port_3, port_4]
    }
    
    private enum CodingKeys: String, CodingKey {
        case port_1, port_2, port_3, port_4
    }
    
    public let port_1: NodePortStatusPersistPortModel
    public let port_2: NodePortStatusPersistPortModel
    public let port_3: NodePortStatusPersistPortModel
    public let port_4: NodePortStatusPersistPortModel
    
    public static func == (lhs: NodePortStatusPersistConfigTemp,
                           rhs: NodePortStatusPersistConfigTemp) -> Bool {
        return lhs.port_1 == rhs.port_1 &&
        lhs.port_2 == rhs.port_2 &&
        lhs.port_3 == rhs.port_3 &&
        lhs.port_4 == rhs.port_4
    }
}

public struct NodePortStatusPersistPortModel: Equatable, Codable {
    public let dhcp_is_in_conflict: Bool
    public let device_has_been_in: Bool
    public let link_has_been_up: Bool
}

/*
 
 {
   "node_port_status_persist" : {
     "_id" : "01c00091031df31e0706",
     "port_3" : {
       "dhcp_is_in_conflict" : false,
       "device_has_been_in" : false,
       "link_has_been_up" : false
     },
     "_rev" : "1-OPmFa6frg04V9b+TOuY4yX393rg=",
     "port_4" : {
       "dhcp_is_in_conflict" : false,
       "device_has_been_in" : false,
       "link_has_been_up" : false
     },
     "port_2" : {
       "dhcp_is_in_conflict" : false,
       "device_has_been_in" : false,
       "link_has_been_up" : false
     },
     "port_1" : {
       "dhcp_is_in_conflict" : false,
       "device_has_been_in" : false,
       "link_has_been_up" : false
     }
   }
 }
 
 */
