//
//  DbPublicWifiInfo.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 08/04/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

struct DbPublicWifiInfo: DbSchemaProtocol {
    
    static let TableName = "public_wifi_info"
    
    static let HS_NAS_ID = "hs_nasid"
    static let UNIT_SHORT_SERIAL = "unit_short_serial"
    static let UNIT_SERIAL_NUMBER = "unit_serial_number"
    static let UNIT_MAC_ADDRESS = "unit_mac_address"
    static let HS_UAMLISTEN = "hs_uamlisten"
    static let HS_NETMASK = "hs_netmask"
    static let HS_NETWORK = "hs_network"
    static let HS_NASMAC = "hs_nasmac"

}
