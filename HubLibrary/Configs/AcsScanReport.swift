//
//  AcsScanReport.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 27/04/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

public struct AcsScanReport: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    public let scan_time_2g4: String
    public let scan_time_5g: String
    public let scan_time_mesh: String
    
    public private (set) var channel_report_2g4: [ChannelScanReport]?
    public private (set) var channel_report_5g: [ChannelScanReport]?
    public private (set) var channel_report_mesh: [ChannelScanReport]?
    
    public private (set) var neighbour_report_mesh: [NeighbourScanReport]?
    public private (set) var neighbour_report_2g4: [NeighbourScanReport]?
    public private (set) var neighbour_report_5g: [NeighbourScanReport]?
    
    public static func == (lhs: AcsScanReport, rhs: AcsScanReport) -> Bool {
        return lhs.scan_time_2g4 == rhs.scan_time_2g4 &&
        lhs.scan_time_5g == rhs.scan_time_5g &&
        lhs.scan_time_mesh == rhs.scan_time_mesh
    }
    
    private enum CodingKeys: String, CodingKey {
        case scan_time_2g4, scan_time_5g, scan_time_mesh, channel_report_2g4, channel_report_5g, channel_report_mesh, neighbour_report_mesh, neighbour_report_2g4, neighbour_report_5g
    }
}

public struct ChannelScanReport: Equatable, Codable {
    public let bss: String
    public let channel: String
    public let chload: String
    public let freq: String
    public let maxrssi: String
    public let minrssi: String
    public let nf: String
    public let rank: String
}

public struct NeighbourScanReport: Equatable, Codable {
    public let bw: String?
    public let bssid: String?
    public let mode: String?
    public let rssi: String?
    public let ssid: String?
    public let channel: String?
}
