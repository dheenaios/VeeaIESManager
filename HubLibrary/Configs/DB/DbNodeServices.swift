//
//  DbNodeServices.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 01/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

struct DbNodeServices: DbSchemaProtocol {
    
    // MARK: - Top level DB keys
    static let TableName = "node_services"
    static let Services = "services"
    
    // MARK: - DB Object Keys
    static let AppConfigName = "name"
    
    // MARK: Public Wifi Specific Keys
    static let PublicWifiOperator = "operator"
    
    // MARK: - Known Apps
    static let PublicWifiAppConfigKey = "public_wifi"
    
}
