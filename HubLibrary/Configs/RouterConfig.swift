//
//  RouterConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 23/04/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation

public struct RouterConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()

    // MARK: - Properties
    // MARK: WLAN settings
    public var access_control_list: String
    public var access_accept_mac_list: [String]
    public var access_deny_mac_list: [String]
    
    
    // MARK: LAN settings
    private enum CodingKeys: String, CodingKey {
        case access_accept_mac_list,
             access_deny_mac_list,
             access_control_list
    }
    
    public static func == (lhs: RouterConfig, rhs: RouterConfig) -> Bool {
        return lhs.access_control_list == rhs.access_control_list &&
            lhs.access_accept_mac_list == rhs.access_accept_mac_list &&
            lhs.access_deny_mac_list == rhs.access_deny_mac_list
    }
}

extension RouterConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[RouterConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        
        vals[DbNodeConfig.AccessControlList] = access_control_list
        vals[DbNodeConfig.AccessAcceptMacList] = access_accept_mac_list
        vals[DbNodeConfig.AccessDenyMacList] = access_deny_mac_list
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = RouterConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public static func getTableName() -> String {
        return DbNodeConfig.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeConfig.AccessControlList)
        keys.append(DbNodeConfig.AccessAcceptMacList)
        keys.append(DbNodeConfig.AccessDenyMacList)
        
        return keys
    }
}
