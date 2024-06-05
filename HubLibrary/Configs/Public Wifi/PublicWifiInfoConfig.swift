//
//  PublicWifiInfoConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 08/04/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

public struct PublicWifiInfoConfig: TopLevelJSONResponse, Codable {
    
    var originalJson: JSON = JSON()
    
    public private(set) var hs_nasid: String
    public private(set) var unit_mac_address: String
    public private(set) var hs_uamlisten: String
    public private(set) var hs_netmask: String
    public private(set) var hs_network: String
    public private(set) var hs_nasmac: String
    public private(set) var unit_serial_number: String
    public private(set) var unit_short_serial: String
    
    private enum CodingKeys: String, CodingKey {
        case hs_nasid,
             unit_mac_address,
             hs_uamlisten,
             hs_netmask,
             hs_network,
             hs_nasmac,
             unit_serial_number,
             unit_short_serial
    }
}

extension PublicWifiInfoConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbPublicWifiInfo.TableName
    }
    
    public func getMasUpdate() -> MasUpdate? {
        // Not needed. Non updating config
        return nil
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        return SecureUpdateJSON()
    }
}
