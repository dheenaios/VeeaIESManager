//
//  WdsScanReportConfig.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/10/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

public struct WdsScanReport: TopLevelJSONResponse, Codable, Equatable {
    public static func == (lhs: WdsScanReport, rhs: WdsScanReport) -> Bool {
        lhs.scan_time == rhs.scan_time &&
        lhs.bssid_report == rhs.bssid_report
    }

    public struct BssidReport: Codable, Equatable {
        let hops: Int
        let rank: Int
        let rate: Int
        let rssi: String
        let stas: Int
        let ul_nodes_list: [String]
    }

    static let tableName = "wds_scan_report"
    var originalJson: JSON = JSON()

    let scan_time: String
    let bssid_report: [String : BssidReport]

    private enum CodingKeys: String, CodingKey {
        case scan_time, bssid_report
    }
}

extension WdsScanReport {
    var hasScanValues: Bool {
        !scan_time.isEmpty
    }
}
