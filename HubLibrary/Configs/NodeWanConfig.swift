//
//  NodeWanConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 07/06/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation

public struct NodeWanConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    public var wan_1: WanConfig
    public var wan_2: WanConfig
    public var wan_3: WanConfig
    public var wan_4: WanConfig
    
    public static func == (lhs: NodeWanConfig, rhs: NodeWanConfig) -> Bool {
        return lhs.wan_1 == rhs.wan_1 &&
            lhs.wan_2 == rhs.wan_2 &&
            lhs.wan_3 == rhs.wan_3 &&
            lhs.wan_4 == rhs.wan_4
    }
    
    private enum CodingKeys: String, CodingKey {
        case wan_1, wan_2, wan_3, wan_4
    }
    
    // Hard coded at the moment. Do something more dynamic later
    public var wanNames = ["No WAN Association (WAN 0)", "WAN 1", "WAN 2" ,"WAN 3", "WAN 4"]
}

extension NodeWanConfig: ApiRequestConfigProtocol {
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeWanConfig.WAN_1)
        keys.append(DbNodeWanConfig.WAN_2)
        keys.append(DbNodeWanConfig.WAN_3)
        keys.append(DbNodeWanConfig.WAN_4)
        
        return keys
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        
        vals[DbNodeWanConfig.WAN_1] = wan_1.getJson()
        vals[DbNodeWanConfig.WAN_2] = wan_2.getJson()
        vals[DbNodeWanConfig.WAN_3] = wan_3.getJson()
        vals[DbNodeWanConfig.WAN_4] = wan_4.getJson()
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = NodeWanConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                      targetJson: njson,
                                                      tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public static func getTableName() -> String {
        return DbNodeWanConfig.TableName
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeWanConfig.getTableName()] = getUpdateJson()
        
        return json
    }
}

public struct WanConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    public enum ActiveInterface {
        case ETH0
        case ETH1
        case NONE
    }
    
    public var position: Int?
    
    public var use: Bool
    public var port: Int
    public var name: String
    public var vlan_tag: Int
    public var zone: String
    
    private var interface: String
    public var activeInterface: ActiveInterface {
        get {
            if interface == "eth0" {
                return .ETH0
            }
            else if interface == "eth1" {
                return .ETH1
            }
            
            return .NONE
        }
        set { interface = newValue == .ETH0 ? "eth0" : "eth1" }
    }
    
    public static func == (lhs: WanConfig, rhs: WanConfig) -> Bool {
        return lhs.use == rhs.use &&
            lhs.port == rhs.port &&
            lhs.name == rhs.name &&
            lhs.vlan_tag == rhs.vlan_tag &&
            lhs.zone == rhs.zone &&
            lhs.interface == rhs.interface
    }
    
    private enum CodingKeys: String, CodingKey {
        case use, port, name, vlan_tag, zone, interface
    }
    
    func getJson() -> JSON {
        var vals = [String : Any]()
        
        vals[DbNodeWanConfig.USE] = use
        vals[DbNodeWanConfig.INTERFACE] = interface
        vals[DbNodeWanConfig.PORT] = port
        vals[DbNodeWanConfig.NAME] = name
        vals[DbNodeWanConfig.VLANTAG] = vlan_tag
        vals[DbNodeWanConfig.ZONE] = zone
        
        return vals
    }
}
