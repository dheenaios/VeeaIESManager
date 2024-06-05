//
//  NodePortConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 10/09/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public struct NodePortConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    public var port_1: PortConfigModel
    public var port_2: PortConfigModel
    public var port_3: PortConfigModel
    public var port_4: PortConfigModel
    
    public var ports: [PortConfigModel] {
        return [port_1, port_2, port_3, port_4]
    }
    
    private enum CodingKeys: String, CodingKey {
        case port_1, port_2, port_3, port_4
    }
    
    public static func == (lhs: NodePortConfig, rhs: NodePortConfig) -> Bool {
        return lhs.ports == rhs.ports
    }
}

extension NodePortConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbNodePortConfig.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodePortConfig.PORT_1)
        keys.append(DbNodePortConfig.PORT_2)
        keys.append(DbNodePortConfig.PORT_3)
        keys.append(DbNodePortConfig.PORT_4)
        
        return keys
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        let vals = getUpdateJson()
        var json = SecureUpdateJSON()
        json[NodePortConfig.getTableName()] = vals
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        vals[DbNodePortConfig.PORT_1] = port_1.getUpdateJSON()
        vals[DbNodePortConfig.PORT_2] = port_2.getUpdateJSON()
        vals[DbNodePortConfig.PORT_3] = port_3.getUpdateJSON()
        vals[DbNodePortConfig.PORT_4] = port_4.getUpdateJSON()
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = NodePortConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
}
