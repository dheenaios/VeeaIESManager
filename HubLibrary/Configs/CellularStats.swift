//
//  CellularStats.swift
//  HubLibrary
//
//  Created by Al on 17/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 Stats relating to the IES's cellular interface.
 */

public class CellularStats: TopLevelJSONResponse, Equatable, Codable {

    var originalJson: JSON = JSON()
    
    static func getTableName() -> String {
        return DbNodeMetrics.TableName
    }
    
    static func cellularStatsFrom(response: RequestResponce) -> CellularStats? {
        guard let responseBody = response.responseBody else {
            return nil
        }
        
        if let model = responseBody[CellularStats.getTableName()] {
            do {
                let decoder = JSONDecoder()
                let jsonData = try JSONSerialization.data(withJSONObject: model, options: .prettyPrinted)
                let cellStats = try decoder.decode(CellularStats.self, from: jsonData)
                cellStats.originalJson = model
                
                return cellStats
            }
            catch {
                Logger.logDecodingError(className: "CellularStats", tag: "CellularStats", error: error)
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case cell_id,
             connection_status,
             current_connect_time,
             ecio,
             imei,
             network_mode,
             plmn,
             rscp,
             rsrp,
             rssi,
             signal_level,
             sinr,
             sim_status,
             network_reg_status,
             iccid,
             arfcn,
             bandwidth_dl,
             bandwidth_ul,
             network_operator,
             srxlev,
             tac,
             imsi,
             rsrq
    }
    
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
    
    public static func == (lhs: CellularStats, rhs: CellularStats) -> Bool {
        return lhs.cell_id == rhs.cell_id &&
            lhs.connection_status == rhs.connection_status &&
            lhs.current_connect_time == rhs.current_connect_time &&
            lhs.ecio == rhs.ecio &&
            lhs.imei == rhs.imei &&
            lhs.network_mode == rhs.network_mode &&
            lhs.plmn == rhs.plmn &&
            lhs.rscp == rhs.rscp &&
            lhs.rsrp == rhs.rsrp &&
            lhs.rssi == rhs.rssi &&
            lhs.signal_level == rhs.signal_level &&
            lhs.sinr == rhs.sinr &&
            lhs.sim_status == rhs.sim_status &&
            lhs.network_reg_status == rhs.network_reg_status &&
            lhs.iccid == rhs.iccid &&
            lhs.arfcn == rhs.arfcn &&
            lhs.bandwidth_dl == rhs.bandwidth_dl &&
            lhs.bandwidth_ul == rhs.bandwidth_ul &&
            lhs.network_operator == rhs.network_operator &&
            lhs.srxlev == rhs.srxlev &&
            lhs.tac == rhs.tac &&
            lhs.imsi == rhs.imsi &&
            lhs.rsrq == rhs.rsrq
    }

    // MARK: - Inits

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cell_id = try container.decode(Int.self, forKey: .cell_id)
        connection_status = try container.decode(String.self, forKey: .connection_status)
        current_connect_time = try container.decode(String.self, forKey: .current_connect_time)

        ecio = try container.decode(Int.self, forKey: .ecio)
        imei = try container.decode(String.self, forKey: .imei)
        imsi = try container.decode(String.self, forKey: .imsi)
        network_mode = try container.decode(String.self, forKey: .network_mode)
        plmn = try container.decode(String.self, forKey: .plmn)
        rscp = try container.decode(Int.self, forKey: .rscp)
        rsrp = try container.decode(Int.self, forKey: .rsrp)
        rsrq = try container.decode(Int.self, forKey: .rsrq)
        rssi = try container.decode(Int.self, forKey: .rssi)
        signal_level = try container.decode(Int.self, forKey: .signal_level)
        sinr = try container.decode(Double.self, forKey: .sinr)
        sim_status = try container.decode(String.self, forKey: .sim_status)
        network_reg_status = try container.decode(String.self, forKey: .network_reg_status)
        iccid = try container.decode(String.self, forKey: .iccid)
        arfcn = try container.decode(Int.self, forKey: .arfcn)
        bandwidth_dl = try container.decode(String.self, forKey: .bandwidth_dl)
        bandwidth_ul = try container.decode(String.self, forKey: .bandwidth_ul)
        network_operator = try container.decode(String.self, forKey: .network_operator)

        do {
            srxlev = try String(container.decode(Int.self, forKey: .srxlev))
        } catch DecodingError.typeMismatch {
            srxlev = try container.decode(String.self, forKey: .srxlev)
        }
        do {
            tac = try String(container.decode(Int.self, forKey: .srxlev))
        } catch DecodingError.typeMismatch {
            tac = try container.decode(String.self, forKey: .srxlev)
        }
    }

    public init(originalJson: JSON = JSON(), cell_id: Int, connection_status: String, current_connect_time: String, ecio: Int, imei: String, imsi: String, network_mode: String, plmn: String, rscp: Int, rsrp: Int, rsrq: Int, rssi: Int, signal_level: Int, sinr: Double, sim_status: String, network_reg_status: String, iccid: String, arfcn: Int, bandwidth_dl: String, bandwidth_ul: String, network_operator: String, srxlev: String, tac: String) {
        self.originalJson = originalJson
        self.cell_id = cell_id
        self.connection_status = connection_status
        self.current_connect_time = current_connect_time
        self.ecio = ecio
        self.imei = imei
        self.imsi = imsi
        self.network_mode = network_mode
        self.plmn = plmn
        self.rscp = rscp
        self.rsrp = rsrp
        self.rsrq = rsrq
        self.rssi = rssi
        self.signal_level = signal_level
        self.sinr = sinr
        self.sim_status = sim_status
        self.network_reg_status = network_reg_status
        self.iccid = iccid
        self.arfcn = arfcn
        self.bandwidth_dl = bandwidth_dl
        self.bandwidth_ul = bandwidth_ul
        self.network_operator = network_operator
        self.srxlev = srxlev
        self.tac = tac
    }
}

extension CellularStats {
    public static func mock() -> CellularStats {
        return CellularStats(cell_id: 26086780,
                             connection_status: "Connected",
                             current_connect_time: "123",
                             ecio: 0,
                             imei: "866758042200341",
                             imsi: "206018818830827",
                             network_mode: "4G",
                             plmn: "23410",
                             rscp: 0,
                             rsrp: -102,
                             rsrq: -11,
                             rssi: -74,
                             signal_level: 25,
                             sinr: -19,
                             sim_status: "Inserted [CPIN READY + SMS DONE + PB DONE]",
                             network_reg_status: "Registered. Roaming",
                             iccid: "89852201812071033016",
                             arfcn: 199,
                             bandwidth_dl: "10MHz",
                             bandwidth_ul: "10MHz",
                             network_operator: "O2 - UK (O2 - UK iFREE) ",
                             srxlev: "-",
                             tac: "40A0")
    }
}
