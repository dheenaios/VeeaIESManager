//
//  PublicWifiOperatorsConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 18/01/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

public struct PublicWifiOperatorsConfig: TopLevelJSONResponse {
    
    var originalJson: JSON
    
    public var wifiOperators = [PublicWifiOperatorDetailsConfig]()
    
    init(from json: JSON) {
        originalJson = json
        
        for key in json.keys {
            
            // Exclude these keys
            if key == DbPublicWifiOperator.Id ||
                key == DbPublicWifiOperator.Rev ||
                key == DbPublicWifiOperator.Default ||
                key == DbPublicWifiOperator.Test ||
                key == DbPublicWifiOperator.Version {
                continue
            }
            let providerConfig = PublicWifiOperatorDetailsConfig(from: json[key] as! JSON, withName: key)
            
            wifiOperators.append(providerConfig)
        }
    }
}

extension PublicWifiOperatorsConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        // This is a read only class so we dont really need the below
        
        return SecureUpdateJSON()
    }
    
    public func getMasUpdate() -> MasUpdate? {
        // Not required
        return nil
    }
    
    public static func getTableName() -> String {
        return DbPublicWifiOperator.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbPublicWifiOperator.Purple)
        keys.append(DbPublicWifiOperator.Socifi)
        keys.append(DbPublicWifiOperator.Hotspot)
        
        return keys
    }
}

public struct PublicWifiOperatorDetailsConfig: TopLevelJSONResponse {
    
    var originalJson: JSON
    
    public var supplierName: String?
    
    public var nasId: String
    public var uamRedirectUrl: String
    public var uamSecret: String
    public var radiusServer1: String
    public var radiusServer2: String
    public var radiusSecret: String
    public var radiusAuthPort: Int
    public var radiusAcctPort: Int
    public var radiusAuthProto: String
    public var uamAllowedDomains: [String]
    public var uamAllowedSites: [String]
    public var dnsServer1: String
    public var dnsServer2: String
    public var dhcpLease: Int
    public var uamPort: Int
    public var uamUiPort: Int
    public var mode: String
    
    // See SW-6971 for rational. This is the backing value for radiusSwapOctets. The one that should be sent to the hub
    private var _radiusSwapOctets: String
    public var  radiusSwapOctets: PublicWifiSettingsConfig.NullableBool {
        get {
            if _radiusSwapOctets.isEmpty {
                return .isEmptyOrNull
            }
            
            return _radiusSwapOctets == "on" ? .isTrue : .isFalse
        }
        set {
            if newValue == .isEmptyOrNull {
                _radiusSwapOctets = ""
                
                return
            }
            
            _radiusSwapOctets = newValue == .isTrue ? "on" : "off"
        }
    }

    init(from json: JSON, withName name: String) {
        self.init(from: json)
        
        supplierName = name
    }
    
    init(from json: JSON) {
        originalJson = json
        
        nasId = JSONValidator.valiate(key: PublicWifiConfigurations.NasId,
                                      json: json,
                                      expectedType: String.self,
                                      defaultValue: "") as! String
        
        uamRedirectUrl = JSONValidator.valiate(key: PublicWifiConfigurations.UamRedirectUrl,
                                               json: json,
                                               expectedType: String.self,
                                               defaultValue: "") as! String
        
        uamSecret = JSONValidator.valiate(key: PublicWifiConfigurations.UamSecret,
                                          json: json,
                                          expectedType: String.self,
                                          defaultValue: "") as! String
        
        radiusServer1 = JSONValidator.valiate(key: PublicWifiConfigurations.RadiusServer1,
                                              json: json,
                                              expectedType: String.self,
                                              defaultValue: "") as! String
        
        radiusServer2 = JSONValidator.valiate(key: PublicWifiConfigurations.RadiusServer2,
                                              json: json,
                                              expectedType: String.self,
                                              defaultValue: "") as! String
        
        radiusSecret = JSONValidator.valiate(key: PublicWifiConfigurations.RadiusSecret,
                                             json: json,
                                             expectedType: String.self,
                                             defaultValue: "") as! String
        
        _radiusSwapOctets = JSONValidator.valiate(key: PublicWifiConfigurations.RadiusSwapOctets,
                                                 json: json,
                                                 expectedType: String.self,
                                                 defaultValue: "") as! String
        
        radiusAuthPort = JSONValidator.valiate(key: PublicWifiConfigurations.RadiusAuthPort,
                                               json: json,
                                               expectedType: Int.self,
                                               defaultValue: 0) as! Int
        
        radiusAcctPort = JSONValidator.valiate(key: PublicWifiConfigurations.RadiusAcctPort,
                                               json: json,
                                               expectedType: Int.self,
                                               defaultValue: 0) as! Int
        
        radiusAuthProto = JSONValidator.valiate(key: PublicWifiConfigurations.RadiusAuthProto,
                                                json: json,
                                                expectedType: String.self,
                                                defaultValue: false) as! String
        
        uamAllowedDomains = JSONValidator.valiate(key: PublicWifiConfigurations.UamAllowedDomains,
                                                  json: json,
                                                  expectedType: [String].self,
                                                  defaultValue: [String]()) as! [String]
        
        uamAllowedSites = JSONValidator.valiate(key: PublicWifiConfigurations.UamAllowedSites,
                                                json: json,
                                                expectedType: [String].self,
                                                defaultValue: [String]()) as! [String]
        
        dnsServer1 = JSONValidator.valiate(key: PublicWifiConfigurations.DnsServer1,
                                           json: json,
                                           expectedType: String.self,
                                           defaultValue: "") as! String
        
        dnsServer2 = JSONValidator.valiate(key: PublicWifiConfigurations.DnsServer2,
                                           json: json,
                                           expectedType: String.self,
                                           defaultValue: false) as! String

        dhcpLease = JSONValidator.valiate(key: PublicWifiConfigurations.DhcpLease,
                                          json: json,
                                          expectedType: Int.self,
                                          defaultValue: 0) as! Int
        
        uamPort = JSONValidator.valiate(key: PublicWifiConfigurations.UamPort,
                                        json: json,
                                        expectedType: Int.self,
                                        defaultValue: 0) as! Int
        
        uamUiPort = JSONValidator.valiate(key: PublicWifiConfigurations.UamUiPort,
                                          json: json,
                                          expectedType: Int.self,
                                          defaultValue: 0) as! Int
        
        mode = JSONValidator.valiate(key: PublicWifiConfigurations.Mode,
                                          json: json,
                                          expectedType: String.self,
                                          defaultValue: false) as! String
    }
}
