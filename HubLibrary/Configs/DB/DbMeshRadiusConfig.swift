//
//  DbMeshRadiusConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 30/11/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

struct DbMeshRadiusConfig: DbSchemaProtocol {
    static var TableName = "mesh_radius_config"
    
    static let RADIUSAUTH_1 = "auth_server_1" // Object
    static let RADIUSAUTH_2 = "auth_server_2" // Object
    static let RADIUSAUTH_3 = "auth_server_3" // Object
    static let RADIUSAUTH_4 = "auth_server_4" // Object
    
    static let RADIUSACCT_1 = "acct_server_1" // Object
    static let RADIUSACCT_2 = "acct_server_2" // Object
    static let RADIUSACCT_3 = "acct_server_3" // Object
    static let RADIUSACCT_4 = "acct_server_4" // Object
    
    static let radiusAuthKeysArray = [RADIUSAUTH_1,
                                      RADIUSAUTH_2,
                                      RADIUSAUTH_3,
                                      RADIUSAUTH_4]
    
    static let radiusAcctKeysArray = [RADIUSACCT_1,
                                      RADIUSACCT_2,
                                      RADIUSACCT_3,
                                      RADIUSACCT_4]
    
    // MARK: - Object keys
    static let ADDRESS = "address"
    static let SECRET = "secret"
    static let PORT = "port"
}
