//
//  NodePortStatusConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 06/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public struct NodePortStatusConfig: TopLevelJSONResponse, Equatable, Codable {
    
    public static func == (lhs: NodePortStatusConfig, rhs: NodePortStatusConfig) -> Bool {
        return lhs.port_1 == rhs.port_1 &&
            lhs.port_2 == rhs.port_2 &&
            lhs.port_3 == rhs.port_3 &&
            lhs.port_4 == rhs.port_4
    }
    
    // MARK: - Port models
    public let port_1: PortStatusModel
    public let port_2: PortStatusModel
    public let port_3: PortStatusModel
    public let port_4: PortStatusModel
    public let ports: [PortStatusModel]
    
    // MARK: - Configuration info (see VHM 1197)
    public var conf_lan: ConfLan?
    public var conf_role: ConfRole?
    public var conf_l2: ConfL2?
    public var conf_state: ConfState?
    public var info_dhcp: InfoDhcp?
    
    
    // MARK: - House keeping
    
    var originalJson: JSON = JSON()
    
    private enum CodingKeys: String, CodingKey {
        case port_1,
             port_2,
             port_3,
             port_4,
             conf_lan,
             conf_role,
             conf_l2,
             conf_state,
             info_dhcp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        port_1 = try container.decode(PortStatusModel.self, forKey: .port_1)
        port_2 = try container.decode(PortStatusModel.self, forKey: .port_2)
        port_3 = try container.decode(PortStatusModel.self, forKey: .port_3)
        port_4 = try container.decode(PortStatusModel.self, forKey: .port_4)
        ports = [port_1, port_2, port_3, port_4]
        
        conf_lan = try container.decode(ConfLan.self, forKey: .conf_lan)
        conf_role = try container.decode(ConfRole.self, forKey: .conf_role)
        conf_l2 = try container.decode(ConfL2.self, forKey: .conf_l2)
        conf_state = try container.decode(ConfState.self, forKey: .conf_state)
        info_dhcp = try container.decode(InfoDhcp.self, forKey: .info_dhcp)
    }
}

extension NodePortStatusConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbNodePortStatus.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodePortStatus.PORT_1)
        keys.append(DbNodePortStatus.PORT_2)
        keys.append(DbNodePortStatus.PORT_3)
        keys.append(DbNodePortStatus.PORT_4)
        
        return keys
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        
        // This will never be called as this class is read only
        let json = SecureUpdateJSON()
        
        return json
    }
    
    public func getMasUpdate() -> MasUpdate? {
        // This will never be called as this class is read only
        
        return nil
    }
}
