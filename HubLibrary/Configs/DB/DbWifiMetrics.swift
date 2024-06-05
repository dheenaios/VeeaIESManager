//
//  DbWifiMetrics.swift
//  HubLibrary
//
//  Created by Al on 20/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

struct DbWifiMetrics: DbSchemaProtocol {
    static let TableName = "wifi_metrics"
    
    static let BackhaulQuality = "backhaul_quality"
    static let BackhaulSignal = "backhaul_signal"
    static let BackhaulSignalLevel = "backhaul_signal_level"
    static let VmeshQuality = "vmesh_quality"
    static let VmeshSignal = "vmesh_signal"
    static let VmeshSignalLevel = "vmesh_signal_level"
    static let WifiMetricsTrigger = "wifi_metrics_trigger"
}
