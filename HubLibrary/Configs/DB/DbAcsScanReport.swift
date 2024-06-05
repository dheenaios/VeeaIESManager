//
//  DbAcsScanReport.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 27/04/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

struct  DbAcsScanReport: DbSchemaProtocol {
    static var TableName = "acs_scan_report"
     
    // Top level Objects
    static let channel_report_2g4 = "channel_report_2g4"
    static let channel_report_5g = "channel_report_5g"
    static let channel_report_mesh = "channel_report_mesh"
    
    // Object Properties
    static let bss = "bss"
    static let channel = "channel"
    static let chload = "chload"
    static let freq = "freq"
    static let maxrssi = "maxrssi"
    static let minrssi = "minrssi"
    static let nf = "nf"
    static let rank = "rank"
    
    
    // Scan times
    static let scan_time_2g4 = "scan_time_2g4"
    static let scan_time_5g = "scan_time_5g"
    static let scan_time_mesh = "scan_time_mesh"
    

}
