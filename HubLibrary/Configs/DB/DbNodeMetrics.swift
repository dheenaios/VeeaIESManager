//
//  DbNodeMetrics.swift
//  HubLibrary
//
//  Created by Al on 17/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

struct DbNodeMetrics: DbSchemaProtocol {
    
    static let TableName = "node_metrics"
    
    static let CellId = "cell_id"
    static let CellularMetricsTrigger = "cellular_metrics_trigger"
    static let ConnectionStatus = "connection_status"
    static let CurrentConnectTime = "current_connect_time"
    static let ECIO = "ecio"
    static let IMEI = "imei"
    static let IMSI = "imsi"
    static let NetworkMode = "network_mode"
    static let PLMN = "plmn"
    static let RSCP = "rscp"
    static let RSRP = "rsrp"
    static let RSRQ = "rsrq"
    static let RSSI = "rssi"
    static let SignalLevel = "signal_level"
    static let SINR = "sinr"
    static let ICCID = "iccid"
    
    static let SIM_STATUS = "sim_status"
    static let SIM_NETWORK_REG_STATUS = "network_reg_status"
    
    static let ARFCN = "arfcn"
    static let BANDWIDTH_DL = "bandwidth_dl"
    static let BANDWIDTH_UL = "bandwidth_ul"
    static let NETWORK_OPERATOR = "network_operator"
    static let SRXLEV = "srxlev"
    static let TAC = "tac"
}
