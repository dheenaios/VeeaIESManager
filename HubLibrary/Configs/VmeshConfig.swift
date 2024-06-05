//
//  VmeshConfig.swift
//  HubLibrary
//
//  Created by Al on 03/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 Configuration items for the Vmesh.
 */
public struct VmeshConfig: TopLevelJSONResponse, Equatable, Codable {
    
    enum WanOperationalOption: String, CaseIterable {
        case disabled = "Disabled"
        case auto = "Automatic"
        case join = "Join network"
        case start = "Start network"
        
        var apiValue: String {
            switch self {
            case .disabled:
                return "locked"
            case .auto:
                return "auto"
            case .join:
                return "join"
            case .start:
                return "start"
            }
        }
        
        static func options(wdsSupport: Bool) -> [String] {
            if !HubDataModel.shared.isMN {
                return [WanOperationalOption.disabled.rawValue,
                        WanOperationalOption.start.rawValue]
            }

            if wdsSupport {
                return [WanOperationalOption.disabled.rawValue,
                        WanOperationalOption.join.rawValue,
                        WanOperationalOption.start.rawValue]
            }
            
            return [WanOperationalOption.disabled.rawValue,
                    WanOperationalOption.auto.rawValue,
                    WanOperationalOption.join.rawValue,
                    WanOperationalOption.start.rawValue]
        }
        
        static func fromString(str: String) -> WanOperationalOption {
            switch str {
            case "locked":
                return .disabled
            case "auto":
                return .auto
            case "join":
                return .join
            case "start":
                return .start
            default:
                return .disabled
            }
        }
    }
    
    
    var originalJson: JSON = JSON()
    
    /// - vmeshChannels: the list of valid channels available for the mesh network
    public internal(set) var vmesh_wifi_channels: [Int]
    
    /// - channel: the mesh channel
    public var vmesh_channel: Int = 0
    
    /// - psk: the mesh PSK
    public var vmesh_psk: String = ""
    
    /// - swarmName: the mesh swarm name
    public var swarm_name: String = ""
    
    /// - ssid: the mesh SSID
    public var vmesh_ssid: String = "Null"
    
    /// - security: the mesh security configuration. Currently this may be either "rsn" or "" (none)
    public var vmesh_security: String = "Null"
    
    /// - bandwidth: the 802.11ac bandwidth
    public var vmesh_bandwidth: Int = 20
    
    /// - bandwidthActual: the actual 802.11ac bandwidth
    public var vmesh_bandwidth_actual: Int = 20
    
    /// - support80211ac: whether or not to support 802.11ac
    public var vmesh_80211ac_support: Bool = false
    
        
    /// VMesh power scale
    public var vmesh_power_scale: Int = 0
    
    
    /// Hide Vmesh
    public var vmesh_hidden: Bool = false
    
    /// Vmesh 2.4g Band
    public var vmesh_24g_band: Bool = false
    
    /// Allowed white list channels
    public let vmesh_allowed_whitelist_chans: [Int] = [Int]()
    
    /// The channel the hub is actually using
    public var vmesh_channel_actual: Int = 0
    
    /// Should Dfs be excluded from scans etc
    public var vmesh_acs_exclude_dfs: Bool = false
    
    /// Auto select channels
    public var vmesh_auto_select_channels: [Int] = [Int]()
    
    /// Is Vmesh ACS Supported
    public var vmesh_acs: Bool?
    
    /// The selected radio. String will be empty if nothing available
    @DecodableDefault.EmptyString var vmesh_radio_name: String
    
    /// Radio Options
    public let vmesh_radio_options: [String]
    
    // Mixed Mesh
    @DecodableDefault.False var vmesh_locked_wired: Bool
    @DecodableDefault.EmptyString var vmesh_local_control: String



    var vmeshLocalControlMode: WanOperationalOption {
        return VmeshConfig.WanOperationalOption.fromString(str: vmesh_local_control)
    }
    
    //
    // MARK: - internal
    //
    
    public static func == (lhs: VmeshConfig, rhs: VmeshConfig) -> Bool {
        return lhs.vmesh_channel == rhs.vmesh_channel &&
        lhs.vmesh_hidden == rhs.vmesh_hidden &&
        lhs.vmesh_psk == rhs.vmesh_psk &&
        lhs.swarm_name == rhs.swarm_name &&
        lhs.vmesh_ssid == rhs.vmesh_ssid &&
        lhs.vmesh_security == rhs.vmesh_security &&
        lhs.vmesh_bandwidth == rhs.vmesh_bandwidth &&
        lhs.vmesh_bandwidth_actual == rhs.vmesh_bandwidth_actual &&
        lhs.vmesh_80211ac_support == rhs.vmesh_80211ac_support &&
        lhs.vmesh_power_scale == rhs.vmesh_power_scale &&
        lhs.vmesh_24g_band == rhs.vmesh_24g_band &&
        lhs.vmesh_acs_exclude_dfs == rhs.vmesh_acs_exclude_dfs &&
        lhs.vmesh_auto_select_channels == rhs.vmesh_auto_select_channels &&
        lhs.vmesh_acs == rhs.vmesh_acs &&
        lhs.vmesh_radio_name == rhs.vmesh_radio_name &&
        lhs.vmesh_locked_wired == rhs.vmesh_locked_wired &&
        lhs.vmesh_local_control == rhs.vmesh_local_control
    }
    
    private enum CodingKeys: String, CodingKey {
        case vmesh_wifi_channels, vmesh_channel, vmesh_psk, swarm_name, vmesh_ssid, vmesh_security, vmesh_bandwidth, vmesh_bandwidth_actual, vmesh_80211ac_support, vmesh_power_scale, vmesh_hidden, vmesh_24g_band, vmesh_allowed_whitelist_chans, vmesh_channel_actual, vmesh_acs_exclude_dfs, vmesh_auto_select_channels, vmesh_acs, vmesh_radio_name, vmesh_radio_options, vmesh_locked_wired, vmesh_local_control
    }
}

extension VmeshConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[VmeshConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var json = originalJson
        json[DbNodeConfig.VmeshSsid] = vmesh_ssid
        json[DbNodeConfig.VmeshChannel] = vmesh_channel
        json[DbNodeConfig.VmeshHidden] = vmesh_hidden
        json[DbNodeConfig.VmeshPsk] = vmesh_psk
        
        // SW-3121
        json[DbNodeConfig.Vmesh80211acSupport] = vmesh_80211ac_support
        json[DbNodeConfig.VmeshBandwidth] = vmesh_bandwidth
        
        json[DbNodeConfig.VmeshPowerScale] = vmesh_power_scale
        json[DbNodeConfig.SwarmName] = swarm_name
        
        var securityConfig = vmesh_security
        if securityConfig.count > 0 {
            if securityConfig == "none" {
                securityConfig = ""
            } else {
                securityConfig = vmesh_security.lowercased()
            }
        }
        json[DbNodeConfig.VmeshSecurity] = securityConfig
        json[DbNodeConfig.Vmesh24gBand] = vmesh_24g_band;
        
        json[DbNodeConfig.vmesh_acs_exclude_dfs] = vmesh_acs_exclude_dfs
        json[DbNodeConfig.vmesh_auto_select_channels] = vmesh_auto_select_channels
        json[DbNodeConfig.vmesh_acs] = vmesh_acs
        json[DbNodeConfig.vmesh_radio_name] = vmesh_radio_name
        
        if let c = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig {
            if c.supportsVeeaHubMixedWiredWirelessDeployments {
                json[DbNodeConfig.vmesh_locked_wired] = vmesh_locked_wired
                json[DbNodeConfig.vmesh_local_control] = vmesh_local_control
            }
        }
        
        return json
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = VmeshConfig.getTableName()
        
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
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeConfig.VmeshSsid)
        keys.append(DbNodeConfig.VmeshChannel)
        keys.append(DbNodeConfig.VmeshHidden)
        keys.append(DbNodeConfig.vmesh_wifi_channels)
        keys.append(DbNodeConfig.VmeshSecurity)
        keys.append(DbNodeConfig.VmeshBandwidth)
        keys.append(DbNodeConfig.VmeshBandwidthActual)
        keys.append(DbNodeConfig.Vmesh80211acSupport)
        keys.append(DbNodeConfig.VmeshPowerScale)
        keys.append(DbNodeConfig.SwarmName)
        keys.append(DbNodeConfig.VmeshHidden)
        keys.append(DbNodeConfig.VmeshPsk)
        keys.append(DbNodeConfig.Vmesh24gBand)
        keys.append(DbNodeConfig.vmesh_allowed_whitelist_chans)
        keys.append(DbNodeConfig.vmesh_auto_select_channels)
        keys.append(DbNodeConfig.Access1AcsExcludeDfs)
        keys.append(DbNodeConfig.vmesh_channel_actual)
        keys.append(DbNodeConfig.vmesh_acs)
        keys.append(DbNodeConfig.vmesh_radio_name)
        keys.append(DbNodeConfig.vmesh_radio_options)
        keys.append(DbNodeConfig.vmesh_locked_wired)
        keys.append(DbNodeConfig.vmesh_local_control)
        
        return keys
    }
}
