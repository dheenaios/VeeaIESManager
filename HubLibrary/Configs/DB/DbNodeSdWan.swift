//
//  DbNodeSdWan.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 07/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

struct DbNodeSdWan: DbSchemaProtocol {
    // MARK: - Top level DB keys
    static let TableName = "node_sdwan"
    static let BackHauls = "backhauls"
    
    // MARK: - Top Level DB Object Keys
    struct BackhaulKeys {
        static let WifiBackhaulKey = "WiFi"
        static let EthernetBackhaulKey = "Ethernet"
        static let CellularBackhaulKey = "Cellular"
    }
    
    //====================================================
    
    /// Backhaul Object Keys
    struct BackhaulPropertyKeys {
        static let alive = "alive"
        static let backhaul_state = "backhaul_state"
        static let disable_timeout = "disable_timeout"
        static let interface = "interface"
        static let is_ppp = "is_ppp"
        static let last_state_change = "last_state_change"
        static let last_successful_test = "last_successful_test"
        static let last_test_result = "last_test_result"
        static let last_test_time = "last_test_time"
        static let last_unsuccessful_test = "last_unsuccessful_test"
        static let locked = "locked"
        static let priority = "priority"
        static let reenable_timeout = "reenable_timeout"
        static let restricted = "restricted"
        
        /// Test Object Keys
        static let TestObjectKey = "test"
        struct TestObject {
            static let interval = "interval"
            static let method = "method"
            static let remote = "remote"
            static let test_inactive = "test_inactive"
            static let timeout = "timeout"
        }
    }
}
