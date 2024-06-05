//
//  NodeStatus.swift
//  HubLibrary
//
//  Created by Al on 02/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

struct DbNodeStatus: DbSchemaProtocol {
    static let TableName = "node_status"
    static let AccessContentOperational = "access_content_operational"
    static let AccessLmtOperational = "access_lmt_operational"
    static let AccessNetOperational = "access_net_operational"
    static let AccessPosOperational = "access_pos_operational"
    static let AuthenticationOperational = "authentication_operational"
    static let BackhaulOperational = "backhaul_operational"
    static let BeaconOperational = "beacon_operational"
    static let BorderGatewaySelected = "border_gateway_selected"
    static let CpuTemperature = "cpu_temperature"
    static let DatabaseOperational = "database_operational"
    static let DisplayOperational = "display_operational"
    static let EthernetIpv4Addr = "ethernet_ipv4_addr"
    static let GatewayCellularOperational = "gateway_cellular_operational"
    static let GatewayEthernetOperational = "gateway_ethernet_operational"
    static let GatewayWifiOperational = "gateway_wifi_operational"
    static let MediaAnalyticsOperational = "media_analytics_operational"
    static let MgwConnectionEstablished = "mgw_connection_established"
    
    static let MgwIpv4PrefixAddress = "mesh_ipv4_prefix_address"
    static let MgwIpv6PrefixAddress = "mesh_ipv6_prefix_address"
    static let MgwVirtualIpAddress = "virtual_ip_address"
    static let NetworkTimeOperational = "network_time_operational"
    static let NodeOperational = "node_operational"
    static let RetailAnalyticsOperational = "retail_analytics_operational"
    static let VmeshOperational = "vmesh_operational"
    static let ManagedIPAddress = "managed_ip_address"
    static let Lan1EthernetOperational = "lan1_ethernet_operational"
    static let Lan2EthernetOperational = "lan2_ethernet_operational"
    static let RebootRequired = "reboot_required"
    static let RebootRequiredReason = "reboot_required_reason"
    static let vmesh_operating_mode = "vmesh_operating_mode"
    
    static let gateway_cellular_connected_apn = "gateway_cellular_connected_apn"
    static let gateway_cellular_connected_mcc = "gateway_cellular_connected_mcc"
    static let gateway_cellular_connected_mnc = "gateway_cellular_connected_mnc"
    static let gateway_cellular_connected_username = "gateway_cellular_connected_username"
    static let gateway_cellular_connected_passphrase = "gateway_cellular_connected_passphrase"
    static let gateway_cellular_connected_status = "gateway_cellular_connected_status"
    
    static let access_operational = "access_operational"
    static let access2_operational = "access2_operational"
    static let ports_operational = "ports_operational"
    
    static let cellular_ipv4_addr = "cellular_ipv4_addr"
    static let wifi_ipv4_addr = "wifi_ipv4_addr"
}
