//
//  NodeConfig.swift
//  HubLibrary
//
//  Created by Al on 03/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 Configuration items for the IES ("node").
 */
public struct NodeConfig: TopLevelJSONResponse, Codable {
    var originalJson: JSON = JSON()
    
    /// -beaconDecryptKey: The encryption key used by the IES to encrypt its SSID and PSK
    public var beaconDecryptKey: String? {
        didSet {
            if beaconDecryptKey?.count == 0 {
                beaconDecryptKey = VeeaBeacon.beaconEncryptKeyDefault
            }
        }
    }
    
    /// -actualBandwidth; the actual bandwidth setting
    //public internal(set) var actualBandwidth: Int
    
    /// -accessBandwidthOptions: Bandwidth Options the user can select from
    public let accessBandwidthOptionsAll: [String] = ["20", "20/40", "20/40/80"]
    public let accessBandwidthOptionsOnly20: [String] = ["20"]
    
    
    public let accessModeOptions2Ghz: [String] = ["mixed (b/g/n)", "n only"]
    public let accessModeOptions5Ghz: [String] = ["mixed (a/n/ac)", "n/ac only"]
    
    public static let accessModeMixedVal = "mixed"
    public static let accessModeNACVal = "nac_only"
    
    public internal(set) var node_locked: Bool
    public var node_name: String
    public var node_locale: String
    public var node_type: String /// - nodeType: Mesh Edge Node (MEN) or Mesh Node (MN)\
    
    public var beacon_encrypt_key: String?
    
    public var access1_local_control: String?
    public var access2_local_control: String?
    
    public var access1_bandwidth: Int
    public var access1_bandwidth_actual: Int
    public var access1_channel: Int
    public var access1_max_inactivity: Int
    public var access1_max_num_sta: Int
    public var access1_mode: String
    public var access1_power_scale: Int
    public var access1_wifi_channels: [Int]
    
    public var access2_bandwidth: Int
    public var access2_bandwidth_actual: Int
    public var access2_channel: Int
    public var access2_max_inactivity: Int
    public var access2_max_num_sta: Int
    public var access2_mode: String
    public var access2_power_scale: Int
    public var access2_wifi_channels: [Int]
    
    public var access1_auto_select_channels: [Int]
    public var access2_auto_select_channels: [Int]
    
    // APN
    @DecodableDefault.EmptyString var gateway_cellular_apn: String
    @DecodableDefault.EmptyString var gateway_cellular_username: String
    @DecodableDefault.EmptyString var gateway_cellular_passphrase: String
    public var access2_band_lower: Bool
    public let vmesh_24g_band: Bool
    
    // Automatic Channel Selection
    
    public var access1_acs: Bool
    public var access1_acs_exclude_dfs: Bool
    public var access1_channel_actual: Int
    
    public var access2_acs: Bool
    public var access2_acs_exclude_dfs: Bool
    public var access2_channel_actual: Int
    
    public var access_restart_trigger: Bool // ?????
    public var acs_dwell_time_ms: Int //???
    
    public let access1_allowed_whitelist_chans: [Int]
    public let access2_allowed_whitelist_chans: [Int]
    
    // VHM 1123 - Cellular additions
    @DecodableDefault.EmptyString var gateway_cellular_mcc: String
    @DecodableDefault.EmptyString var gateway_cellular_mnc: String
    
    // VHM 1123 - 802.11ax additions
    var access1_80211ax: Bool?
    var access2_80211ax: Bool?

    // VHM 1501 - WDS Support
    @DecodableDefault.False var vmesh_wds_selected: Bool
    @DecodableDefault.Zero var vmesh_wds_reqd_config: Int
    @DecodableDefault.EmptyString var vmesh_wds_manual_bssid: String
    var vmesh_wds_scan_trigger: Bool?
    @DecodableDefault.Zero var vmesh_wds_max_scan_time: Int
    @DecodableDefault.Zero var vmesh_wds_min_scan_time: Int
    @DecodableDefault.Zero var vmesh_wds_weak_ap_thresh: Int
    @DecodableDefault.Zero var vmesh_wds_assoc_fail_time: Int
    @DecodableDefault.Zero var vmesh_wds_manual_assoc_fail_time: Int

    
    enum CodingKeys: String, CodingKey {
        case node_locked, node_name, node_locale, node_type, beacon_encrypt_key, access1_bandwidth, access1_bandwidth_actual, access1_channel, access1_max_inactivity, access1_max_num_sta, access1_mode, access1_power_scale, access1_wifi_channels, access2_bandwidth, access2_bandwidth_actual, access2_channel, access2_max_inactivity, access2_max_num_sta, access2_mode, access2_power_scale, access2_wifi_channels, access1_auto_select_channels, access2_auto_select_channels, gateway_cellular_apn, gateway_cellular_username, gateway_cellular_passphrase, access2_band_lower, vmesh_24g_band, access1_acs, access1_acs_exclude_dfs, access1_channel_actual, access2_acs, access2_acs_exclude_dfs, access2_channel_actual, access_restart_trigger, acs_dwell_time_ms, access1_allowed_whitelist_chans, access2_allowed_whitelist_chans, gateway_cellular_mcc, gateway_cellular_mnc, access1_80211ax, access2_80211ax, vmesh_wds_selected, vmesh_wds_reqd_config, vmesh_wds_manual_bssid, vmesh_wds_scan_trigger, vmesh_wds_max_scan_time, vmesh_wds_min_scan_time, vmesh_wds_weak_ap_thresh, vmesh_wds_assoc_fail_time, vmesh_wds_manual_assoc_fail_time, access1_local_control, access2_local_control
    }
    
    // JSON dictionary for values that could have been edited
    func getUpdateJSON() -> JSON {
        var json = originalJson
        json[DbNodeConfig.NodeName] = node_name
        json[DbNodeConfig.NodeLocked] = node_locked
        json[DbNodeConfig.NodeLocale] = node_locale
        json[DbNodeConfig.NodeType] = node_type
        
        json[DbNodeConfig.Access1Bandwidth] = access1_bandwidth
        json[DbNodeConfig.Access1Channel] = access1_channel
        json[DbNodeConfig.Access1MaxInactivity] = access1_max_inactivity
        json[DbNodeConfig.Access1MaxNumSta] = access1_max_num_sta
        json[DbNodeConfig.Access1Mode] = access1_mode
        json[DbNodeConfig.Access1PowerScale] = access1_power_scale
        json[DbNodeConfig.Access1WifiChannels] = access1_wifi_channels
        
        json[DbNodeConfig.Access2Bandwidth] = access2_bandwidth
        json[DbNodeConfig.Access2Channel] = access2_channel
        json[DbNodeConfig.Access2MaxInactivity] = access2_max_inactivity
        json[DbNodeConfig.Access2MaxNumSta] =         access2_max_num_sta
        json[DbNodeConfig.Access2Mode] = access2_mode
        json[DbNodeConfig.Access2PowerScale] = access2_power_scale
        json[DbNodeConfig.Access2WifiChannels] = access2_wifi_channels
        
        json[DbNodeConfig.access1_local_control] = access1_local_control
        json[DbNodeConfig.access2_local_control] = access2_local_control
        
        json[DbNodeConfig.Access1AutoSelectChannels] = access1_auto_select_channels;
        json[DbNodeConfig.Access2AutoSelectChannels] = access2_auto_select_channels;
        
        if let beaconDecryptKey = beaconDecryptKey {
            json[DbNodeConfig.BeaconEncryptionKey] = beaconDecryptKey
        }
        
        json[DbNodeConfig.GatewayCellularApn] = gateway_cellular_apn;
        json[DbNodeConfig.GatewayCellularUsername] = gateway_cellular_username;
        json[DbNodeConfig.GatewayCellularPassphrase] = gateway_cellular_passphrase;
        json[DbNodeConfig.Access2BandLower] = access2_band_lower;
        json[DbNodeConfig.Vmesh24gBand] = vmesh_24g_band;
        
        // ACS
        json[DbNodeConfig.Access1Acs] = access1_acs
        json[DbNodeConfig.Access2Acs] = access2_acs
        
        json[DbNodeConfig.AccessRestartTrigger] = access_restart_trigger
        json[DbNodeConfig.Access2AcsExcludeDfs] = access2_acs_exclude_dfs
        
        json[DbNodeConfig.gateway_cellular_mcc] = gateway_cellular_mcc
        json[DbNodeConfig.gateway_cellular_mnc] = gateway_cellular_mnc
        
        json[DbNodeConfig.access1_80211ax] = access1_80211ax
        json[DbNodeConfig.access2_80211ax] = access2_80211ax

        if let vmesh_wds_scan_trigger {
            json[DbNodeConfig.vmesh_wds_scan_trigger] = vmesh_wds_scan_trigger
        }

        json[DbNodeConfig.vmesh_wds_manual_bssid] = vmesh_wds_manual_bssid
        
        return json
    }
}

extension NodeConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeConfig.getTableName()] = getUpdateJSON()
        
        return json
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJSON()
        let tableName = NodeConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                      targetJson: njson,
                                                      tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public static func getTableName() -> String {
        return DbNodeConfig.TableName
    }
}

extension NodeConfig: Equatable {
    public static func == (lhs: NodeConfig, rhs: NodeConfig) -> Bool {
        return lhs.node_name == rhs.node_name &&
        lhs.node_locale == rhs.node_locale &&
        lhs.node_type == rhs.node_type &&
        lhs.beaconDecryptKey == rhs.beaconDecryptKey &&
        lhs.beacon_encrypt_key == rhs.beacon_encrypt_key &&
        lhs.access1_bandwidth == rhs.access1_bandwidth &&
        lhs.access1_bandwidth_actual == rhs.access1_bandwidth_actual &&
        lhs.access1_channel == rhs.access1_channel &&
        lhs.access1_max_inactivity == rhs.access1_max_inactivity &&
        lhs.access1_max_num_sta == rhs.access1_max_num_sta &&
        lhs.access1_mode == rhs.access1_mode &&
        lhs.access1_power_scale == rhs.access1_power_scale &&
        lhs.access1_wifi_channels == rhs.access1_wifi_channels &&
        lhs.access2_bandwidth == rhs.access2_bandwidth &&
        lhs.access2_bandwidth_actual == rhs.access2_bandwidth_actual &&
        lhs.access2_channel == rhs.access2_channel &&
        lhs.access2_max_inactivity == rhs.access2_max_inactivity &&
        lhs.access2_max_num_sta == rhs.access2_max_num_sta &&
        lhs.access2_mode == rhs.access2_mode &&
        lhs.access2_power_scale == rhs.access2_power_scale &&
        lhs.access2_wifi_channels == rhs.access2_wifi_channels &&
        lhs.access1_auto_select_channels == rhs.access1_auto_select_channels &&
        lhs.access2_auto_select_channels == rhs.access2_auto_select_channels &&
        lhs.gateway_cellular_apn == rhs.gateway_cellular_apn &&
        lhs.gateway_cellular_username == rhs.gateway_cellular_username &&
        lhs.gateway_cellular_passphrase == rhs.gateway_cellular_passphrase &&
        lhs.access2_band_lower == rhs.access2_band_lower &&
        lhs.vmesh_24g_band == rhs.vmesh_24g_band &&
        lhs.access1_acs == rhs.access1_acs &&
        lhs.access1_acs_exclude_dfs == rhs.access1_acs_exclude_dfs &&
        lhs.access1_channel_actual == rhs.access1_channel_actual &&
        lhs.access2_acs == rhs.access2_acs &&
        lhs.access2_acs_exclude_dfs == rhs.access2_acs_exclude_dfs &&
        lhs.access2_channel_actual == rhs.access2_channel_actual &&
        lhs.access_restart_trigger == rhs.access_restart_trigger &&
        lhs.acs_dwell_time_ms == rhs.acs_dwell_time_ms &&
        lhs.access1_allowed_whitelist_chans == rhs.access1_allowed_whitelist_chans &&
        lhs.access2_allowed_whitelist_chans == rhs.access2_allowed_whitelist_chans &&
        lhs.gateway_cellular_mcc == rhs.gateway_cellular_mcc &&
        lhs.gateway_cellular_mnc == rhs.gateway_cellular_mnc &&
        lhs.access1_80211ax == rhs.access1_80211ax &&
        lhs.access2_80211ax == rhs.access2_80211ax &&
        lhs.access1_local_control == rhs.access1_local_control &&
        lhs.access2_local_control == rhs.access2_local_control
    }
}

// Subsets
extension NodeConfig {
    public func getWifiScanConfig() -> NodeConfigWifiScan {
        return NodeConfigWifiScan(from: originalJson)
    }
}
