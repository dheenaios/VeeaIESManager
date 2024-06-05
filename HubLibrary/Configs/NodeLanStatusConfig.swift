//
//  NodeLanStatusConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 02/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

public struct NodeLanStatusConfig: TopLevelJSONResponse, Equatable, Codable {
    
    public static func == (lhs: NodeLanStatusConfig, rhs: NodeLanStatusConfig) -> Bool {
        return lhs.lan_1 == rhs.lan_1 &&
            lhs.lan_2 == rhs.lan_2 &&
            lhs.lan_3 == rhs.lan_3 &&
            lhs.lan_4 == rhs.lan_4
    }
    
    var originalJson: JSON = JSON()
    
    let lan_1: NodeLanStatus
    let lan_2: NodeLanStatus
    let lan_3: NodeLanStatus
    let lan_4: NodeLanStatus
    
    let nodeLanStatuss: [NodeLanStatus]
    
    private enum CodingKeys: String, CodingKey {
        case lan_1, lan_2, lan_3, lan_4
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lan_1 = try container.decode(NodeLanStatus.self, forKey: .lan_1)
        lan_2 = try container.decode(NodeLanStatus.self, forKey: .lan_2)
        lan_3 = try container.decode(NodeLanStatus.self, forKey: .lan_3)
        lan_4 = try container.decode(NodeLanStatus.self, forKey: .lan_4)
        
        nodeLanStatuss = [lan_1, lan_2, lan_3, lan_4]
    }
    
    static func getTableName() -> String {
        return DbNodeLanStatus.TableName
    }
}

public struct NodeLanStatus: Equatable, Codable {
    public static func == (lhs: NodeLanStatus, rhs: NodeLanStatus) -> Bool {
        let same = lhs.reason == rhs.reason &&
            lhs.ip4_subnet == rhs.ip4_subnet &&
            lhs.operational == rhs.operational
        
        return same
    }
    
    public let reason: String
    public let ip4_subnet: String
    public let operational: Bool
    
    private var originalJson: JSON = JSON()
    
    private enum CodingKeys: String, CodingKey {
        case reason, ip4_subnet, operational
    }
}
