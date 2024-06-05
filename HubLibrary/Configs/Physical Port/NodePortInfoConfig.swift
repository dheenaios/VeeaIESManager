//
//  NodePortInfoConfig.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 21/09/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

public struct NodePortInfoConfig: Equatable, Codable {
    
    var originalJson: JSON?
    
    public let port_1: NodePortInfoModel
    public let port_2: NodePortInfoModel
    public let port_3: NodePortInfoModel
    public let port_4: NodePortInfoModel
    
    public var ports: [NodePortInfoModel] {
        return [port_1, port_2, port_3, port_4]
    }
    
    public static func == (lhs: NodePortInfoConfig, rhs: NodePortInfoConfig) -> Bool {
        return lhs.port_1 == rhs.port_1 &&
        lhs.port_2 == rhs.port_2 &&
        lhs.port_3 == rhs.port_3 &&
        lhs.port_4 == rhs.port_4
    }
    
    private enum CodingKeys: String, CodingKey {
        case port_1, port_2, port_3, port_4
    }
    
}

extension NodePortInfoConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return "node_port_info"
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        return SecureUpdateJSON.init()
    }
    
    public func getMasUpdate() -> MasUpdate? {
        return nil
    }
}

public struct NodePortInfoModel: Equatable, Codable {
    public let mac_addr: String
    public let interface: String
    public let device_type: String?
}

