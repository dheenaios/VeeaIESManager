//
//  WifiStats.swift
//  HubLibrary
//
//  Created by Al on 20/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 Stats relating to the IES's Wi-Fi interface.
 */
public class WifiStats: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    static func getTableName() -> String {
        return DbWifiMetrics.TableName
    }
    
    static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbWifiMetrics.BackhaulQuality)
        keys.append(DbWifiMetrics.BackhaulSignal)
        keys.append(DbWifiMetrics.BackhaulSignalLevel)
        keys.append(DbWifiMetrics.VmeshQuality)
        keys.append(DbWifiMetrics.VmeshSignal)
        keys.append(DbWifiMetrics.VmeshSignalLevel)
        keys.append(DbWifiMetrics.WifiMetricsTrigger)
        
        return keys
    }
    
    static func wifiStatsFrom(response: RequestResponce) -> WifiStats? {
        guard let responseBody = response.responseBody else {
            return nil
        }
        
        if let model = responseBody[WifiStats.getTableName()] {
            do {
                let decoder = JSONDecoder()
                let jsonData = try JSONSerialization.data(withJSONObject: model, options: .prettyPrinted)
                let wifiStats = try decoder.decode(WifiStats.self, from: jsonData)
                wifiStats.originalJson = model
                
                return wifiStats
            }
            catch {
                Logger.logDecodingError(className: "wifiStats", tag: "wifiStats", error: error)
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// - backhaulQuality: backhaul quality, n/100
    public internal(set) var backhaul_quality: String
    
    /// - backhaulSignal: backhaul signal
    public internal(set) var backhaul_signal: Int
    
    public var backhaulSignal: String { "\(backhaul_signal)" }
    
    /// - backhaulSignalLevel: backhaul signal level (0-5)
    public internal(set) var backhaul_signal_level: Int
    
    /// - vmeshQuality:  mesh quality, n/100
    public internal(set) var vmesh_quality: String
    
    /// - vmeshSignal: mesh signal
    public internal(set) var vmesh_signal: String
    
    /// - vmeshSignalLevel: mesh signal level (0-5)
    public internal(set) var vmesh_signal_level: Int
    
    /// Setting this to true and sending again will cause the db to update
    public internal(set) var wifi_metrics_trigger: Bool
    
    private enum CodingKeys: String, CodingKey {
        case backhaul_quality, backhaul_signal, backhaul_signal_level, vmesh_quality, vmesh_signal, vmesh_signal_level, wifi_metrics_trigger
    }
    
    public static func == (lhs: WifiStats, rhs: WifiStats) -> Bool {
        return lhs.backhaul_quality == rhs.backhaul_quality &&
            lhs.backhaul_signal == rhs.backhaul_signal &&
            lhs.backhaul_signal_level == rhs.backhaul_signal_level &&
            lhs.vmesh_quality == rhs.vmesh_quality &&
            lhs.vmesh_signal_level == rhs.vmesh_signal_level &&
            lhs.backhaul_quality == rhs.backhaul_quality
    }
}
