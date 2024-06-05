//
//  NodeWanStaticIpConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 17/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

public struct NodeWanStaticIpConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    private let wan_1: LanWanStaticIpConfig
    private let wan_2: LanWanStaticIpConfig
    private let wan_3: LanWanStaticIpConfig
    private let wan_4: LanWanStaticIpConfig
    public var wanStaticIpConfig: [LanWanStaticIpConfig]
    
    public static func == (lhs: NodeWanStaticIpConfig,
                           rhs: NodeWanStaticIpConfig) -> Bool {
        return lhs.wanStaticIpConfig == rhs.wanStaticIpConfig
    }
    
    private enum CodingKeys: String, CodingKey {
        case wan_1, wan_2, wan_3, wan_4
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wan_1 = try container.decode(LanWanStaticIpConfig.self, forKey: .wan_1)
        wan_2 = try container.decode(LanWanStaticIpConfig.self, forKey: .wan_2)
        wan_3 = try container.decode(LanWanStaticIpConfig.self, forKey: .wan_3)
        wan_4 = try container.decode(LanWanStaticIpConfig.self, forKey: .wan_4)
        
        wanStaticIpConfig = [wan_1, wan_2, wan_3, wan_4]
    }
}

extension NodeWanStaticIpConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbNodeWanStaticIp.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeWanStaticIp.wan_1)
        keys.append(DbNodeWanStaticIp.wan_2)
        keys.append(DbNodeWanStaticIp.wan_3)
        keys.append(DbNodeWanStaticIp.wan_4)
        
        return keys
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeWanStaticIpConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        vals[DbNodeWanStaticIp.wan_1] = wanStaticIpConfig[0].getUpdateJSON()
        vals[DbNodeWanStaticIp.wan_2] = wanStaticIpConfig[1].getUpdateJSON()
        vals[DbNodeWanStaticIp.wan_3] = wanStaticIpConfig[2].getUpdateJSON()
        vals[DbNodeWanStaticIp.wan_4] = wanStaticIpConfig[3].getUpdateJSON()
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = NodeWanStaticIpConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
}
