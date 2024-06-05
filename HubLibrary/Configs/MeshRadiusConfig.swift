//
//  MeshRadiusConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 30/11/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

public struct MeshRadiusConfig: TopLevelJSONResponse, Codable {
    
    var originalJson: JSON = JSON()
    public var radiusAuthServers: [RadiusServer]
    public var radiusAcctServers: [RadiusServer]
    
    private let auth_server_1: RadiusServer
    private let auth_server_2: RadiusServer
    private let auth_server_3: RadiusServer
    private let auth_server_4: RadiusServer
    
    private let acct_server_1: RadiusServer
    private let acct_server_2: RadiusServer
    private let acct_server_3: RadiusServer
    private let acct_server_4: RadiusServer
    
    private enum CodingKeys: String, CodingKey {

    case auth_server_1, auth_server_2, auth_server_3, auth_server_4, acct_server_1, acct_server_2, acct_server_3, acct_server_4
    }
    
    public init(from decoder: Decoder) throws {

    let container = try decoder.container(keyedBy: CodingKeys.self)
        auth_server_1 = try container.decode(RadiusServer.self, forKey: .auth_server_1)
        auth_server_2 = try container.decode(RadiusServer.self, forKey: .auth_server_2)
        auth_server_3 = try container.decode(RadiusServer.self, forKey: .auth_server_3)
        auth_server_4 = try container.decode(RadiusServer.self, forKey: .auth_server_4)
        
        acct_server_1 = try container.decode(RadiusServer.self, forKey: .acct_server_1)
        acct_server_2 = try container.decode(RadiusServer.self, forKey: .acct_server_2)
        acct_server_3 = try container.decode(RadiusServer.self, forKey: .acct_server_3)
        acct_server_4 = try container.decode(RadiusServer.self, forKey: .acct_server_4)

        radiusAuthServers = [auth_server_1, auth_server_2, auth_server_3, auth_server_4]
        radiusAcctServers = [acct_server_1, acct_server_2, acct_server_3, acct_server_4]
    }
}

extension MeshRadiusConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        let vals = getUpdateJson()
        var secureJson = SecureUpdateJSON()
        secureJson[DbMeshRadiusConfig.TableName] = vals
        
        return secureJson
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()

        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                      targetJson: njson,
                                                      tableName: DbMeshRadiusConfig.TableName) else {
            return nil
        }

        return MasUpdate(tableName: DbMeshRadiusConfig.TableName, data: patch)
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        
        for (index, key) in DbMeshRadiusConfig.radiusAuthKeysArray.enumerated() {
            let model = radiusAuthServers[index]
            vals[key] = model.currentStateJson
        }
        
        for (index, key) in DbMeshRadiusConfig.radiusAcctKeysArray.enumerated() {
            let model = radiusAcctServers[index]
            vals[key] = model.currentStateJson
        }
        
        return vals
    }
    
    public static func getTableName() -> String {
        return DbMeshRadiusConfig.TableName
    }
}

public struct RadiusServer: Codable {
    
    public var address: String
    public var secret: String
    public var port: Int
    
    let originalJson: JSON = JSON()
    
    private enum CodingKeys: String, CodingKey {
        case address, secret, port
    }
    
    var isConfigured: Bool {
        if !AddressAndPortValidation.isIPValid(string: address) { return false }
        let l = secret.count
        if l < 1 || l > 31 { return false }

        return true
    }
    
    var currentStateJson: JSON {
        var updatedJSON = originalJson
        updatedJSON[DbMeshRadiusConfig.ADDRESS] = address
        updatedJSON[DbMeshRadiusConfig.SECRET] = secret
        updatedJSON[DbMeshRadiusConfig.PORT] = port
        
        return updatedJSON
    }
}
