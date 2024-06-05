//
//  IesStatus.swift
//  HubLibrary
//
//  Created by Al on 02/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 General IES subsystem status information
 */
public struct NodeStatus: TopLevelJSONResponse, Codable {
    var originalJson: JSON = JSON()
    
    static let tableName = "node_status"
    
    enum VmeshOperatingMode: String, CaseIterable {

        /// wireless networking is disabled by a manual or automatic configuration
        case wiredOnly = "wired-only"

        /// the VeeaHub has started a new wireless network for other VeeaHubs to join
        case wirelessStart = "wireless-start"

        /// the VeeaHub has joined or is trying to join an existing wireless network
        case wirelessJoin = "wireless-join"

        // Nil = Disabled the wireless networking state has not yet been determined, see VmeshMonitor
        static func fromString(str: String) -> VmeshOperatingMode? {
            switch str {
            case wiredOnly.rawValue:
                return .wiredOnly
            case wirelessStart.rawValue:
                return .wirelessStart
            case wirelessJoin.rawValue:
                return .wirelessJoin
            default:
                return nil
            }
        }
    }
    
    var vmeshOperatingMode: VmeshOperatingMode? {
        return VmeshOperatingMode.fromString(str: vmesh_operating_mode)
    }
    
    @DecodableDefault.False internal var authentication_operational: Bool = false
    @DecodableDefault.False var backhaul_operational: Bool = false
    @DecodableDefault.False var beacon_operational: Bool = false
    @DecodableDefault.EmptyString var border_gateway_selected: String = ""
    @DecodableDefault.False var database_operational: Bool = false
    @DecodableDefault.False var display_operational: Bool = false
    @DecodableDefault.EmptyString var ethernet_ipv4_addr: String = ""
    @DecodableDefault.False var gateway_cellular_operational: Bool = false
    @DecodableDefault.False var gateway_ethernet_operational: Bool = false
    @DecodableDefault.False var gateway_wifi_operational: Bool = false
    @DecodableDefault.False var network_time_operational: Bool = false
    @DecodableDefault.False var node_operational: Bool = false
    @DecodableDefault.False var vmesh_operational: Bool = false
    @DecodableDefault.EmptyString var vmesh_operating_mode: String = ""
    @DecodableDefault.False var reboot_required: Bool = false
    @DecodableDefault.EmptyString var reboot_required_reason: String = ""
    @DecodableDefault.EmptyString var wifi_ipv4_addr: String = ""
    @DecodableDefault.EmptyString var cellular_ipv4_addr: String = ""
    
    // VHM 1123 - Cellular additions
    @DecodableDefault.EmptyString var gateway_cellular_connected_apn: String
    @DecodableDefault.EmptyString var gateway_cellular_connected_mcc: String
    @DecodableDefault.EmptyString var gateway_cellular_connected_mnc: String
    @DecodableDefault.EmptyString var gateway_cellular_connected_username: String
    @DecodableDefault.EmptyString var gateway_cellular_connected_passphrase: String
    @DecodableDefault.EmptyString var gateway_cellular_connected_status: String
    
    // VHM 1197 - Dashboard warnings.
    var access_operational: Bool?
    var access2_operational: Bool?
    var ports_operational: Bool?

    // VHM 1501 - WDS
    @DecodableDefault.False var vmesh_wds_scanning: Bool
    var vmesh_wds_upstream_bssid: String?
    
    private enum CodingKeys: String, CodingKey {
        case authentication_operational,
             backhaul_operational,
             beacon_operational,
             border_gateway_selected,
             database_operational,
             display_operational,
             ethernet_ipv4_addr,
             gateway_cellular_operational,
             gateway_ethernet_operational,
             gateway_wifi_operational,
             network_time_operational,
             node_operational,
             vmesh_operational,
             reboot_required,
             reboot_required_reason,
             gateway_cellular_connected_apn,
             gateway_cellular_connected_mcc,
             gateway_cellular_connected_mnc,
             gateway_cellular_connected_username,
             gateway_cellular_connected_passphrase,
             gateway_cellular_connected_status,
             access_operational,
             access2_operational,
             ports_operational,
             vmesh_operating_mode,
             vmesh_wds_upstream_bssid,
             wifi_ipv4_addr,
             cellular_ipv4_addr
    }
}

extension NodeStatus: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeStatus.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        vals[DbNodeStatus.EthernetIpv4Addr] = ethernet_ipv4_addr
        vals[DbNodeStatus.BorderGatewaySelected] = border_gateway_selected
        vals[DbNodeStatus.AuthenticationOperational] = authentication_operational
        vals[DbNodeStatus.BackhaulOperational] = backhaul_operational
        vals[DbNodeStatus.BeaconOperational] = beacon_operational
        vals[DbNodeStatus.DatabaseOperational] = database_operational
        vals[DbNodeStatus.DisplayOperational] = display_operational
        vals[DbNodeStatus.NodeOperational] = node_operational
        vals[DbNodeStatus.VmeshOperational] = vmesh_operational
        vals[DbNodeStatus.GatewayCellularOperational] = gateway_cellular_operational
        vals[DbNodeStatus.GatewayEthernetOperational] = gateway_ethernet_operational
        vals[DbNodeStatus.GatewayWifiOperational] = gateway_wifi_operational
        vals[DbNodeStatus.NetworkTimeOperational] = network_time_operational
        vals[DbNodeStatus.RebootRequired] = reboot_required
        vals[DbNodeStatus.RebootRequiredReason] = reboot_required_reason
        vals[DbNodeStatus.gateway_cellular_connected_apn] = gateway_cellular_connected_apn
        vals[DbNodeStatus.gateway_cellular_connected_mcc] = gateway_cellular_connected_mcc
        vals[DbNodeStatus.gateway_cellular_connected_mnc] = gateway_cellular_connected_mnc
        vals[DbNodeStatus.gateway_cellular_connected_username] = gateway_cellular_connected_username
        vals[DbNodeStatus.gateway_cellular_connected_passphrase] = gateway_cellular_connected_passphrase
        vals[DbNodeStatus.gateway_cellular_connected_status] = gateway_cellular_connected_status
        vals[DbNodeStatus.wifi_ipv4_addr] = wifi_ipv4_addr
        vals[DbNodeStatus.cellular_ipv4_addr] = cellular_ipv4_addr
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = NodeStatus.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                      targetJson: njson,
                                                      tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public static func getTableName() -> String {
        return DbNodeStatus.TableName
    }
    
    public static func getAllKeys() -> [String] {
        [String]()
    }
}
