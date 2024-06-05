//
//  DbNodeConfig.swift
//  HubLibrary
//
//  Created by Al on 02/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

struct DbNodeConfig: DbSchemaProtocol {
    static let TableName = "node_config"
    
    static let AccessAcceptMacList = "access_accept_mac_list"
    static let AccessControlList = "access_control_list"
    static let AccessDenyMacList = "access_deny_mac_list"
    static let BeaconInstanceId = "beacon_instance_id"
    static let BeaconLocked = "beacon_locked"
    static let BeaconSubDomain = "beacon_sub_domain"
    static let GatewayCellularLocked = "gateway_cellular_locked"
    static let GatewayCellularRestricted = "gateway_cellular_restricted"
    static let GatewayEthernetLocked = "gateway_ethernet_locked"
    static let GatewayEthernetRestricted = "gateway_ethernet_restricted"
    static let GatewayLockOrder = "gateway_lock_order"
    static let GatewayPsk = "gateway_psk"
    static let GatewayServiceDiscovery = "gateway_mdns_enable"
    static let GatewaySsid = "gateway_ssid"
    static let GatewayWifiLocked = "gateway_wifi_locked"
    static let GatewayWifiRestricted = "gateway_wifi_restricted"
    static let HncpExtDelegatedPrefix = "hncp_ext_delegated_prefix"
    static let HncpMenMeshAddress = "hncp_men_mesh_address"
    static let InternalPrefix = "hncp_lmt_delegated_prefix"
    static let MasServer = "mas_server"
    static let MediaAnalyticsLocked = "media_analytics_locked"
    static let NodeCountry = "node_country"
    static let NodeLocale = "node_locale"
    static let NodeLocked = "node_locked"
    static let NodeName = "node_name"
    static let NodeTimezoneArea = "node_timezone_area"
    static let NodeTimezoneRegion = "node_timezone_region"
    static let NodeType = "node_type"
    static let RetailAnalyticsLocked = "retail_analytics_locked"
    static let Vmesh80211acSupport = "vmesh_80211ac_support"
    static let VmeshBandwidth = "vmesh_bandwidth"
    static let VmeshBandwidthActual = "vmesh_bandwidth_actual"
    static let VmeshChannel = "vmesh_channel"
    static let VmeshHidden = "vmesh_hidden"
    static let VmeshPowerScale = "vmesh_power_scale"
    static let VmeshPsk = "vmesh_psk"
    static let VmeshSecurity = "vmesh_security"
    static let VmeshSsid = "vmesh_ssid"
    static let SwarmName = "swarm_name"
    static let BeaconEncryptionKey = "beacon_encrypt_key"
    static let Vmesh24gBand = "vmesh_24g_band"
    
    static let Access1Bandwidth = "access1_bandwidth"
    static let Access1BandwidthActual = "access1_bandwidth_actual"
    static let Access1Channel = "access1_channel"
    static let Access1ControlList = "access1_control_list"
    static let Access1MaxInactivity = "access1_max_inactivity"
    static let Access1MaxNumSta = "access1_max_num_sta"
    static let Access1Mode = "access1_mode"
    static let Access1PowerScale = "access1_power_scale"
    static let Access1WifiChannels = "access1_wifi_channels"
    static let Access2Bandwidth = "access2_bandwidth"
    static let Access2BandwidthActual = "access2_bandwidth_actual"
    static let Access2Channel = "access2_channel"
    static let Access2ControlList = "access2_control_list"
    static let Access2MaxInactivity = "access2_max_inactivity"
    static let Access2MaxNumSta = "access2_max_num_sta"
    static let Access2Mode = "access2_mode"
    static let Access2PowerScale = "access2_power_scale"
    static let Access2WifiChannels = "access2_wifi_channels"
    static let Access1AutoSelectChannels = "access1_auto_select_channels"
    static let Access2AutoSelectChannels = "access2_auto_select_channels"
    
    static let access1_local_control = "access1_local_control"
    static let access2_local_control = "access2_local_control"
    
    // APN
    static let GatewayCellularApn = "gateway_cellular_apn"
    static let GatewayCellularUsername = "gateway_cellular_username"
    static let GatewayCellularPassphrase = "gateway_cellular_passphrase"
    static let Access2BandLower = "access2_band_lower"
    static let gateway_cellular_mnc = "gateway_cellular_mnc"
    static let gateway_cellular_mcc = "gateway_cellular_mcc"

    // Automatic channel selection
    static let Access1Acs = "access1_acs"
    static let Access1AcsExcludeDfs = "access1_acs_exclude_dfs"
    static let Access1ChannelActual = "access1_channel_actual"

    static let Access2Acs = "access2_acs"
    static let Access2AcsExcludeDfs = "access2_acs_exclude_dfs"
    static let Access2ChannelActual = "access2_channel_actual"

    static let AccessRestartTrigger = "access_restart_trigger"
    static let AcsDwellTimeMs = "acs_dwell_time_ms"
    
    static let access1_acs_rescan = "access1_acs_rescan"
    static let access2_acs_rescan = "access2_acs_rescan"
    static let vmesh_acs_rescan = "vmesh_acs_rescan"
    
    static let access1_bkgnd_scan = "access1_bkgnd_scan"
    static let access2_bkgnd_scan = "access2_bkgnd_scan"
    static let vmesh_bkgnd_scan = "vmesh_bkgnd_scan"   
    
    static let access1_allowed_whitelist_chans = "access1_allowed_whitelist_chans"
    static let access2_allowed_whitelist_chans = "access2_allowed_whitelist_chans"
    
    // VMESH
    static let vmesh_allowed_whitelist_chans = "vmesh_allowed_whitelist_chans"
    static let vmesh_wifi_channels = "vmesh_wifi_channels"
    static let vmesh_channel_actual = "vmesh_channel_actual"
    static let vmesh_acs = "vmesh_acs"
    static let vmesh_acs_exclude_dfs = "vmesh_acs_exclude_dfs"
    static let vmesh_auto_select_channels = "vmesh_auto_select_channels"
    
    static let vmesh_radio_name = "vmesh_radio_name"
    static let vmesh_radio_options = "vmesh_radio_options"
    static let vmesh_restart_trigger = "vmesh_restart_trigger"
    
    // Mixed Mesh
    static let vmesh_locked_wired = "vmesh_locked_wired"
    static let vmesh_local_control = "vmesh_local_control"
    static let vmesh_wds_upstream_bssid = "vmesh_wds_upstream_bssid"
    
    // VHM-1234 - 802.11ax changes
    static let access1_80211ax = "access1_80211ax"
    static let access2_80211ax = "access2_80211ax"

    // VHM-1501 - WDS
    static let vmesh_wds_scan_trigger = "vmesh_wds_scan_trigger"
    static let vmesh_wds_manual_bssid = "vmesh_wds_manual_bssid"
    
}

