//
//  NodeLanConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 29/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public struct NodeLanConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON() {
        didSet {
            guard let lan1 = originalJson[DbNodeLanConfig.LAN_1] as? JSON,
                  let lan2 = originalJson[DbNodeLanConfig.LAN_2] as? JSON,
                  let lan3 = originalJson[DbNodeLanConfig.LAN_3] as? JSON,
                  let lan4 = originalJson[DbNodeLanConfig.LAN_4] as? JSON else {
                      return
                  }
            
            lan_1.originalJson = lan1
            lan_2.originalJson = lan2
            lan_3.originalJson = lan3
            lan_4.originalJson = lan4
        }
    }
    
    public static func == (lhs: NodeLanConfig, rhs: NodeLanConfig) -> Bool {
        return lhs.lans == rhs.lans
    }
    
    private let lan_1: NodeLanConfigModel
    private let lan_2: NodeLanConfigModel
    private let lan_3: NodeLanConfigModel
    private let lan_4: NodeLanConfigModel
    
    public var lans: [NodeLanConfigModel]
    public static var usesLegacyTable = true // VHM-141
    
    private enum CodingKeys: String, CodingKey {
        case lan_1, lan_2, lan_3, lan_4
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lan_1 = try container.decode(NodeLanConfigModel.self, forKey: .lan_1)
        lan_2 = try container.decode(NodeLanConfigModel.self, forKey: .lan_2)
        lan_3 = try container.decode(NodeLanConfigModel.self, forKey: .lan_3)
        lan_4 = try container.decode(NodeLanConfigModel.self, forKey: .lan_4)
        lans = [lan_1, lan_2, lan_3, lan_4]
    }
}

extension NodeLanConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbNodeLanConfig.TableName
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        vals[DbNodeLanConfig.LAN_1] = lans[0].getUpdateJSON()
        vals[DbNodeLanConfig.LAN_2] = lans[1].getUpdateJSON()
        vals[DbNodeLanConfig.LAN_3] = lans[2].getUpdateJSON()
        vals[DbNodeLanConfig.LAN_4] = lans[3].getUpdateJSON()
                
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = NodeLanConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeLanConfig.LAN_1)
        keys.append(DbNodeLanConfig.LAN_2)
        keys.append(DbNodeLanConfig.LAN_3)
        keys.append(DbNodeLanConfig.LAN_4)
        
        return keys
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeLanConfig.getTableName()] = getUpdateJson()
        
        return json
    }
}

public class NodeLanConfigModel: Equatable, Codable {
    
    public static func == (lhs: NodeLanConfigModel, rhs: NodeLanConfigModel) -> Bool {
        return lhs.allow_mac == rhs.allow_mac &&
        lhs.dns_1 == rhs.dns_1 &&
        lhs.dns_2 == rhs.dns_2 &&
        lhs.start_ip == rhs.start_ip &&
        lhs.end_ip == rhs.end_ip &&
        lhs.lease_time == rhs.lease_time
    }
    
    public var allow_mac: Bool
    public var dns_1: String
    public var dns_2: String
    public var start_ip: String
    public var end_ip: String
    public var lease_time: Int
    
    var originalJson: JSON = JSON()
    
    private enum CodingKeys: String, CodingKey {
        case allow_mac, dns_1, dns_2, start_ip, end_ip, lease_time
    }
    
    func getUpdateJSON() -> JSON {
        var json = originalJson
        
        json[DbNodeLanConfig.ALLOW_MAC] = allow_mac
        json[DbNodeLanConfig.DNS_1] = dns_1
        json[DbNodeLanConfig.DNS_2] = dns_2
        json[DbNodeLanConfig.START_IP] = start_ip
        json[DbNodeLanConfig.END_IP] = end_ip
        json[DbNodeLanConfig.LEASE_TIME] = lease_time
        
        return json
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        allow_mac = try container.decode(Bool.self, forKey: .allow_mac)
        dns_1 = try container.decode(String.self, forKey: .dns_1)
        dns_2 = try container.decode(String.self, forKey: .dns_2)
        start_ip = try container.decode(String.self, forKey: .start_ip)
        end_ip = try container.decode(String.self, forKey: .end_ip)
        
        if let leaseTime = try? container.decode(Int.self, forKey: .lease_time) {
            self.lease_time = leaseTime
        }
        else {
            self.lease_time = 0
        }
        
    }
    
}
