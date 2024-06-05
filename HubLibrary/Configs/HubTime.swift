//
//  IesTime.swift
//  HubLibrary
//
//  Created by Al on 10/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 IES time information.
 */
public struct HubTime: Equatable, Codable {
    public static func == (lhs: HubTime, rhs: HubTime) -> Bool {
        return lhs.node_time == rhs.node_time
    }
    
    private var originalJson: JSON = JSON()
    
    /// - nodeTime: Returns the IES's time, as last refreshed by `API.refreshTime`
    
    public internal(set) var node_time: String
    
    private enum CodingKeys: String, CodingKey {
        case node_time
    }
    
    init(from json: JSON) {
        originalJson = json
        node_time = JSONValidator.valiate(key: DbNodeInfo.NodeTime,
                                         json: json,
                                         expectedType:String.self,
                                         defaultValue: "") as! String
    }
}

extension HubTime: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[HubTime.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson

        // The class does not update the task, it sends a trigger
        vals[DbNodeInfo.NodeTimeTrigger] = true
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = HubTime.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public static func getTableName() -> String {
        return DbNodeInfo.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        keys.append(DbNodeInfo.NodeTime)
        
        return keys
    }
    
    public init?(response: RequestResponce) {
        guard let responseBody = response.responseBody else {
            return nil
        }
        
        if let model = responseBody[HubTime.getTableName()] {
            self.init(from: model)
        }
        else {
            return nil
        }
    }
    
    
}
