//
//  NodeLanConfigStaticIp.swift
//  IESManager
//
//  Created by Richard Stockdale on 31/03/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation

public struct NodeLanConfigStaticIp: TopLevelJSONResponse, Equatable, Codable {

    var originalJson: JSON = JSON()

    private(set) var lan_1: LanWanStaticIpConfig
    private(set) var lan_2: LanWanStaticIpConfig
    private(set) var lan_3: LanWanStaticIpConfig
    private(set) var lan_4: LanWanStaticIpConfig
    public private(set) var lanStaticIpConfig: [LanWanStaticIpConfig]
    
    public mutating func update(lan: LanWanStaticIpConfig, lanIndex: Int) {
        lanStaticIpConfig[lanIndex] = lan
        switch lanIndex {
        case 0:
            lan_1 = lan
            lanStaticIpConfig[0] = lan
        case 1:
            lan_2 = lan
            lanStaticIpConfig[1] = lan
        case 2:
            lan_3 = lan
            lanStaticIpConfig[2] = lan
        case 3:
            lan_4 = lan
            lanStaticIpConfig[3] = lan
        default: break
        }
    }
    
    public static func == (lhs: NodeLanConfigStaticIp,
                           rhs: NodeLanConfigStaticIp) -> Bool {
        return lhs.lanStaticIpConfig == rhs.lanStaticIpConfig
    }

    private enum CodingKeys: String, CodingKey {
        case lan_1, lan_2, lan_3, lan_4
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lan_1 = try container.decode(LanWanStaticIpConfig.self, forKey: .lan_1)
        lan_2 = try container.decode(LanWanStaticIpConfig.self, forKey: .lan_2)
        lan_3 = try container.decode(LanWanStaticIpConfig.self, forKey: .lan_3)
        lan_4 = try container.decode(LanWanStaticIpConfig.self, forKey: .lan_4)

        lanStaticIpConfig = [lan_1, lan_2, lan_3, lan_4]
    }
}

extension NodeLanConfigStaticIp: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbNodeLanConfigStaticIp.TableName
    }

    public static func getAllKeys() -> [String] {
        var keys = [String]()

        keys.append(DbNodeLanConfigStaticIp.lan_1)
        keys.append(DbNodeLanConfigStaticIp.lan_2)
        keys.append(DbNodeLanConfigStaticIp.lan_3)
        keys.append(DbNodeLanConfigStaticIp.lan_4)

        return keys
    }

    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeLanConfigStaticIp.getTableName()] = getUpdateJson()

        return json
    }

    private func getUpdateJson() -> JSON {
        var vals = originalJson
        vals[DbNodeLanConfigStaticIp.lan_1] = lanStaticIpConfig[0].getUpdateJSON()
        vals[DbNodeLanConfigStaticIp.lan_2] = lanStaticIpConfig[1].getUpdateJSON()
        vals[DbNodeLanConfigStaticIp.lan_3] = lanStaticIpConfig[2].getUpdateJSON()
        vals[DbNodeLanConfigStaticIp.lan_4] = lanStaticIpConfig[3].getUpdateJSON()

        return vals
    }

    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = NodeLanConfigStaticIp.getTableName()

        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }

        return MasUpdate(tableName: tableName, data: patch)
    }
}
