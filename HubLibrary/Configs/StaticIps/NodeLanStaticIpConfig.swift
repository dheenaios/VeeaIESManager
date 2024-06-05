//
//  NodeLanStaticIpConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 24/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public struct NodeLanStaticIpConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    public var lans: [[NodeLanStaticIpModel]]
    private var lan_1: [NodeLanStaticIpModel]
    private var lan_2: [NodeLanStaticIpModel]
    private var lan_3: [NodeLanStaticIpModel]
    private var lan_4: [NodeLanStaticIpModel]
    
    public static func == (lhs: NodeLanStaticIpConfig, rhs: NodeLanStaticIpConfig) -> Bool {
        return lhs.lans == rhs.lans
    }
    
    // Changes made to the Reserved IP screen means we might have modified the model a number of times
    // To stop the MAS API getting confused we need to update the original json
    // Only call this after updating the Hub Or MAS
    public mutating func updateOriginalJson() {
        originalJson = getUpdateJson()
    }
    
    private enum CodingKeys: String, CodingKey {
        case lan_1, lan_2, lan_3, lan_4
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lan_1 = try container.decode([NodeLanStaticIpModel].self, forKey: .lan_1)
        lan_2 = try container.decode([NodeLanStaticIpModel].self, forKey: .lan_2)
        lan_3 = try container.decode([NodeLanStaticIpModel].self, forKey: .lan_3)
        lan_4 = try container.decode([NodeLanStaticIpModel].self, forKey: .lan_4)
        lans = [lan_1, lan_2, lan_3, lan_4]
    }
}

extension NodeLanStaticIpConfig: ApiRequestConfigProtocol {
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        vals[DbNodeLanStaticIp.LAN_1] = getJsonArrayFor(lanArray: lans[0])
        vals[DbNodeLanStaticIp.LAN_2] = getJsonArrayFor(lanArray: lans[1])
        vals[DbNodeLanStaticIp.LAN_3] = getJsonArrayFor(lanArray: lans[2])
        vals[DbNodeLanStaticIp.LAN_4] = getJsonArrayFor(lanArray: lans[3])
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = NodeLanStaticIpConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                      targetJson: njson,
                                                      tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public static func getTableName() -> String {
        return DbNodeLanStaticIp.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeLanStaticIp.LAN_1)
        keys.append(DbNodeLanStaticIp.LAN_2)
        keys.append(DbNodeLanStaticIp.LAN_3)
        keys.append(DbNodeLanStaticIp.LAN_4)
        
        return keys
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeLanStaticIpConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getJsonArrayFor(lanArray :[NodeLanStaticIpModel]) -> [JSON] {
        var jsonArray = [JSON]()
        
        for model in lanArray {
            let json = model.getUpdateJSON()
            jsonArray.append(json)
        }
        
        return jsonArray
    }
}

// MARK: - NodeLanStaticIpModel
public struct NodeLanStaticIpModel: Equatable, Codable {
    
    public static func == (lhs: NodeLanStaticIpModel, rhs: NodeLanStaticIpModel) -> Bool {
        return lhs.host == rhs.host &&
            lhs.ip == rhs.ip &&
            lhs.mac == rhs.mac &&
            lhs.name == rhs.name &&
            lhs.use == rhs.use &&
            lhs.host == rhs.host
    }
    
    public var host: String
    public var ip: String
    public var mac: String
    public var name: String // The comments field
    public var use: Bool
    
    private var originalJson: JSON = JSON()
    
    private enum CodingKeys: String, CodingKey {
        case host, ip, mac, name, use
    }
    
    /// Create an empty Model
    init() {
        originalJson = JSON()
        
        host = ""
        ip = ""
        mac = ""
        name = ""
        use = false
        
        originalJson = JSON()
    }
    
    func getUpdateJSON() -> JSON {
        var json = originalJson
        
        json[DbNodeLanStaticIp.HOST] = host
        json[DbNodeLanStaticIp.IP] = ip
        json[DbNodeLanStaticIp.MAC] = mac
        json[DbNodeLanStaticIp.NAME] = name
        json[DbNodeLanStaticIp.USE] = use
        
        return json
    }
}
