//
//  DbPublicWifiOperator.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 17/01/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

/*
 
 Public Wifi uses two databases...
 
 - public_wifi_operator
 - public_wifi_settings
 
 public_wifi_operator contains a complex object that is represented by the PublicWifiConfigurations strut
 public_wifi_settings contains the same keys as PublicWifiConfigurations but is flat
 
 */

/// Public Wifi Database
struct DbPublicWifiOperator: DbSchemaProtocol {
    
    static let TableName = "public_wifi_operators"
    
    // Should be Excluded
    static let Id = "_id"
    static let Rev = "_rev"
    static let Version = "$version"
    static let Default = "default"
    static let Test = "test"
    
    // Known Suppliers

    static let Purple = "purple"
    static let Socifi = "socifi"
    static let Hotspot = "hotspot"
}

/// The Confucuration Fields Required to set up public wifi
struct PublicWifiConfigurations {
    static let DhcpLease = "dhcp_lease"
    static let DnsServer1 = "dns_server_1"
    static let DnsServer2 = "dns_server_2"
    static let Mode = "mode"
    static let NasId = "nas_id"
    static let RadiusAcctPort = "radius_acct_port"
    static let RadiusAuthPort = "radius_auth_port"
    static let RadiusAuthProto = "radius_auth_proto"
    static let RadiusSecret = "radius_secret"
    static let RadiusServer1 = "radius_server_1"
    static let RadiusServer2 = "radius_server_2"
    static let RadiusSwapOctets = "radius_swap_octets"
    static let UamAllowedDomains = "uam_allowed_domains"
    static let UamAllowedSites = "uam_allowed_sites"
    static let UamPort = "uam_port"
    static let UamRedirectUrl = "uam_redirect_url"
    static let UamSecret = "uam_secret"
    static let UamUiPort = "uam_ui_port"
    static let LanId = "lan_id"
    static let WanId = "wan_id"
}

/// Sub Class of Public wifi PublicWifiConfigurations containing extra items
/// for identification of of allowed / selected operators
struct DbPublicWifiSettings {
    
    static let TableName = "public_wifi_settings"
    
    static let AllowedOperators = "allowed_operators"
    static let SelectedOperator = "selected_operator"
}
