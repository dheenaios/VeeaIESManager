//
//  CellularStats.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 11/07/2022.
//

import Foundation

//m Cellular status usage stats for the widget
public struct CellularStats: Codable {
    /// - cellId: the cell ID
    public internal(set) var cell_id: Int

    /// - connectionStatus: the connection status
    public internal(set) var connection_status: String

    /// - currentConnectTime: how long the IES cellular interface has been connected to its network
    public internal(set) var current_connect_time: String

    /// - ecio: the ECIO
    public internal(set) var ecio: Int

    /// - imei: the IMEI
    public internal(set) var imei: String

    /// - imsi: the IMSI
    public internal(set) var imsi: String

    /// - networkMode: the network mode (2G, 3G, 4G)
    public internal(set) var network_mode: String

    /// - plmn: the PLMN
    public internal(set) var plmn: String

    /// - rscp: the RSCP
    public internal(set) var rscp: Int

    /// - rsrp: the RSRP
    public internal(set) var rsrp: Int

    /// - rsrq: the RSRQ
    public internal(set) var rsrq: Int

    /// - rssi: the RSSI
    public internal(set) var rssi: Int

    /// - signalLevel: the signal level (0-5)
    public internal(set) var signal_level: Int

    /// - sinr: the SINR
    public internal(set) var sinr: Double

    /// Quectel cellular only
    public internal(set) var sim_status: String

    /// Quectel cellular only
    public internal(set) var network_reg_status: String

    /// ICCID
    public internal(set) var iccid: String

    public internal(set) var arfcn: Int

    public internal(set) var bandwidth_dl: String

    public internal(set) var bandwidth_ul: String

    public internal(set) var network_operator: String

    public internal(set) var srxlev: String

    public internal(set) var tac: String

}
