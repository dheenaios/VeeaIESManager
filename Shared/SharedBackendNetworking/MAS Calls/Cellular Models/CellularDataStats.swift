//
//  CellularDataStats.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 11/07/2022.
//

import Foundation

//m Cellular data usage stats for the widget
public struct CellularDataStats: Codable {
    public var bytes_sent: UInt64

    public var bytes_sent_current_day: UInt64
    public var bytes_recv_current_day: UInt64

    public var bytes_sent_previous_day: UInt64
    public var bytes_recv_previous_day: UInt64

    public var bytes_sent_current_month: UInt64
    public var bytes_recv_current_month: UInt64

    public var bytes_sent_previous_month: UInt64
    public var bytes_recv_previous_month: UInt64

    public var bytes_sent_previous: UInt64
    public var bytes_recv_previous: UInt64
}
