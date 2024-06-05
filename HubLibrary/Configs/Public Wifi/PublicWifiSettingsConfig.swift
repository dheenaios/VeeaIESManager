
//
//  PublicWifiSettingsConfig.swift
//  HubLibrary
//
//  Created by IES Model Factory
//  Copyright © 2019 Virtuosys. All rights reserved.
//


// This struct represents a Request to the IES. It can be used to fetch and post data to the IES

/// This is the database that implements the Public WiFi settable parameters. The 'operator_selected' field lets you choose which public WiFi operator you want to configure the system for. The 'allowed_operators' identifies which operators in the DbPublicWifiOperators table can be selected. This is so we can deploy a container that is specific to a single operator. In this case, the mobile application should identify the public wifi icon in the apps folder as being specific to that operator. Likewise, the main dialog should only reference this one operator. This means that the mobile app, when configuring the 'selected_operator' field, should only offer entries in the 'allowed_operators' list.
 public struct PublicWifiSettingsConfig: TopLevelJSONResponse, Codable {

    var originalJson: JSON = JSON()
    
    // See SW-6971 for rational - For use on the Octet swap value.
    public enum NullableBool {
        case isEmptyOrNull
        case isTrue
        case isFalse
        
        public func getBoolValue() -> Bool {
            switch self {
            case .isTrue:
                return true
            default:
                return false
            }
        }
        
        public mutating func setBoolValue(bool: Bool) {
            if bool == true {
                self = .isTrue
            }
            else {
                self = .isFalse
            }
        }
        
        public static func nullableBoolFromBool(bool : Bool) -> NullableBool {
            if bool == true {
                return .isTrue
            }
            else {
                return .isFalse
            }
        }
    }
    
    public var  allowed_operators: [String]
    public var  selected_operator: String
    public var  nas_id: String
    public var  uam_redirect_url: String
    public var  uam_secret: String
    public var  radius_server_1: String
    public var  radius_server_2: String
    public var  radius_secret: String
    public var  radius_auth_port: Int
    public var  radius_acct_port: Int
    public var  radius_auth_proto: String
    public var  uam_allowed_domains: [String]
    public var  uam_allowed_sites: [String]
    public var  dns_server_1: String
    public var  dns_server_2: String
    public var  dhcp_lease: Int
    public var  uam_port: Int
    public var  uam_ui_port: Int
    public var  lan_id: Int
    
    // See SW-6971 for rational. This is the backing value for radiusSwapOctets. The one that should be sent to the hub
    private var radius_swap_octets: String
    public var  radiusSwapOctets: NullableBool {
        get {
            if radius_swap_octets.isEmpty {
                return .isEmptyOrNull
            }
            
            return radius_swap_octets == "on" ? .isTrue : .isFalse
        }
        set {
            if newValue == .isEmptyOrNull {
                radius_swap_octets = ""
                
                return
            }
            
            radius_swap_octets = newValue == .isTrue ? "on" : "off"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case allowed_operators,
             selected_operator,
             nas_id,
             uam_redirect_url,
             uam_secret,
             radius_server_1,
             radius_server_2,
             radius_secret,
             radius_auth_port,
             radius_acct_port,
             radius_auth_proto,
             uam_allowed_domains,
             uam_allowed_sites,
             dns_server_1,
             dns_server_2,
             dhcp_lease,
             uam_port,
             uam_ui_port,
             lan_id,
             radius_swap_octets
    }

    func getUpdateJSON() -> JSON {
        var json = JSON()
        
        json[DbPublicWifiSettings.AllowedOperators] = allowed_operators
        json[DbPublicWifiSettings.SelectedOperator] = selected_operator
        
        json[PublicWifiConfigurations.NasId] = nas_id
        json[PublicWifiConfigurations.UamRedirectUrl] = uam_redirect_url
        json[PublicWifiConfigurations.UamSecret] = uam_secret
        json[PublicWifiConfigurations.RadiusServer1] = radius_server_1
        json[PublicWifiConfigurations.RadiusServer2] = radius_server_2
        json[PublicWifiConfigurations.RadiusSecret] = radius_secret
        json[PublicWifiConfigurations.RadiusSwapOctets] = radius_swap_octets
        json[PublicWifiConfigurations.RadiusAuthPort] = radius_auth_port
        json[PublicWifiConfigurations.RadiusAcctPort] = radius_acct_port
        json[PublicWifiConfigurations.RadiusAuthProto] = radius_auth_proto
        json[PublicWifiConfigurations.UamAllowedDomains] = uam_allowed_domains
        json[PublicWifiConfigurations.UamAllowedSites] = uam_allowed_sites
        json[PublicWifiConfigurations.DnsServer1] = dns_server_1
        json[PublicWifiConfigurations.DnsServer2] = dns_server_2
        json[PublicWifiConfigurations.DhcpLease] = dhcp_lease
        json[PublicWifiConfigurations.UamPort] = uam_port
        json[PublicWifiConfigurations.UamUiPort] = uam_ui_port
        json[PublicWifiConfigurations.LanId] = lan_id
        
        return json
    }
}

extension PublicWifiSettingsConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbPublicWifiSettings.TableName
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[PublicWifiSettingsConfig.getTableName()] = getUpdateJSON()
        
        return json
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJSON()
        let tableName = PublicWifiSettingsConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
}

