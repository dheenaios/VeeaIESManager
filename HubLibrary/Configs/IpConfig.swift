//
//  IpConfig.swift
//  HubLibrary
//
//  Created by Al on 03/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 Configuration items relating to the IES IP functionality.
 */
public struct IpConfig: TopLevelJSONResponse, Equatable, Codable {
    var originalJson: JSON = JSON()
    
    /// - extDelegatedPrefix: the delegated prefix
    public var hncp_ext_delegated_prefix: String
    
    /// - menMeshAddress: MEN mesh address
    public var hncp_men_mesh_address: String
    
    /// - masServer: MAS server address (deprecated)
    public var mas_server: String
    
    /// - internalPrefix: internal prefix
    public var hncp_lmt_delegated_prefix: String
    
    public static func == (lhs: IpConfig, rhs: IpConfig) -> Bool {
        return
            lhs.hncp_ext_delegated_prefix == rhs.hncp_ext_delegated_prefix &&
            lhs.hncp_men_mesh_address == rhs.hncp_men_mesh_address &&
            lhs.mas_server == rhs.mas_server &&
            lhs.hncp_lmt_delegated_prefix == rhs.hncp_lmt_delegated_prefix
    }
    
    private enum CodingKeys: String, CodingKey {
        case
             hncp_ext_delegated_prefix,
             hncp_men_mesh_address,
             mas_server,
             hncp_lmt_delegated_prefix
    }
    
    // JSON dictionary for values that could have been edited
    func getUpdateJSON() -> JSON {
        var json = JSON()
        json[DbNodeConfig.HncpExtDelegatedPrefix] = hncp_ext_delegated_prefix
        json[DbNodeConfig.HncpMenMeshAddress] = hncp_men_mesh_address
        json[DbNodeConfig.MasServer] = mas_server
        json[DbNodeConfig.InternalPrefix] = hncp_lmt_delegated_prefix
        return json
    }
}

extension IpConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[IpConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        for (index, element) in IpConfig.getAllKeys().enumerated() {
            vals[element] = getAllValues()[index]
        }
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = IpConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public func getTableName() -> String {
        return IpConfig.getTableName()
    }
    
    public func getAllKeys() -> [String] {
        return IpConfig.getAllKeys()
    }
    
    public func getAllValues() -> [Any] {
        var values = [Any]()
        
        values.append(hncp_ext_delegated_prefix)
        values.append(hncp_men_mesh_address)
        values.append(mas_server)
        values.append(hncp_lmt_delegated_prefix)
        
        return values
    }
    
    public static func getTableName() -> String {
        return DbNodeConfig.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeConfig.HncpExtDelegatedPrefix)
        keys.append(DbNodeConfig.HncpMenMeshAddress)
        keys.append(DbNodeConfig.MasServer)
        keys.append(DbNodeConfig.InternalPrefix)
        
        return keys
    }
}
