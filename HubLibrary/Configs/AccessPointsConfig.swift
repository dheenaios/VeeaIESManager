//
//
//  HubLibrary
//
//  Created by Richard Stockdale on 07/06/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation

public struct AccessPointsConfig: TopLevelJSONResponse, Equatable, Codable {
    var originalJson: JSON = JSON()
    
    public enum AccessPointType {
        case NODE
        case MESH
    }
    
    public var enhancedSecuritySupported: Bool {
        return ap_1_1.enhancedSecuritySupported
    }
    
    public var ap_1_1: AccessPointConfig
    public var ap_1_2: AccessPointConfig
    public var ap_1_3: AccessPointConfig
    public var ap_1_4: AccessPointConfig
    public var ap_1_5: AccessPointConfig
    public var ap_1_6: AccessPointConfig
    
    public var allAP2s: [AccessPointConfig] {
        get {
            let aps = [ap_2_1,
                       ap_2_2,
                       ap_2_3,
                       ap_2_4,
                       ap_2_5,
                       ap_2_6]
            
            return aps
        }
    }
    
    public var ap_2_1: AccessPointConfig
    public var ap_2_2: AccessPointConfig
    public var ap_2_3: AccessPointConfig
    public var ap_2_4: AccessPointConfig
    public var ap_2_5: AccessPointConfig
    public var ap_2_6: AccessPointConfig
    
    public var allAP1s: [AccessPointConfig] {
        get {
            let aps = [ap_1_1,
                       ap_1_2,
                       ap_1_3,
                       ap_1_4,
                       ap_1_5,
                       ap_1_6]
            
            return aps
        }
    }
    
    /// Returns all AP Configs
    public var allAPs: [AccessPointConfig] {
        get {
            let aps = [ap_1_1,
                       ap_1_2,
                       ap_1_3,
                       ap_1_4,
                       ap_1_5,
                       ap_1_6,
                       ap_2_1,
                       ap_2_2,
                       ap_2_3,
                       ap_2_4,
                       ap_2_5,
                       ap_2_6]
            
            return aps
        }
    }
    
    /// All 2.4Ghz APs
    public var aps2ghz: [AccessPointConfig] {
        get {
            let aps = [ap_1_1,
                       ap_1_2,
                       ap_1_3,
                       ap_1_4,
                       ap_1_5,
                       ap_1_6]
            
            return aps
        }
    }
    
    /// All 5Ghz APs
    public var aps5ghz: [AccessPointConfig] {
        get {
            let aps = [ap_2_1,
                       ap_2_2,
                       ap_2_3,
                       ap_2_4,
                       ap_2_5,
                       ap_2_6]
            
            return aps
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case ap_1_1, ap_1_2, ap_1_3, ap_1_4, ap_1_5, ap_1_6, ap_2_1, ap_2_2, ap_2_3, ap_2_4, ap_2_5, ap_2_6
    }
    
    public var accessPointType: AccessPointType?
    
    public static func getNodeTableName() -> String {
        return DbApConfig.TableNameNode
    }
    
    public static func getMeshTableName() -> String {
        return DbApConfig.TableNameMesh
    }
    
    public static func == (lhs: AccessPointsConfig, rhs: AccessPointsConfig) -> Bool {
        return lhs.allAP2s == rhs.allAP2s &&
            lhs.allAP1s == rhs.allAP1s
    }
    
    // MARK: - Original AccessPointConfigs
    private let original_ap_1_1: AccessPointConfig
    private let original_ap_1_2: AccessPointConfig
    private let original_ap_1_3: AccessPointConfig
    private let original_ap_1_4: AccessPointConfig
    private let original_ap_1_5: AccessPointConfig
    private let original_ap_1_6: AccessPointConfig
    private let original_ap_2_1: AccessPointConfig
    private let original_ap_2_2: AccessPointConfig
    private let original_ap_2_3: AccessPointConfig
    private let original_ap_2_4: AccessPointConfig
    private let original_ap_2_5: AccessPointConfig
    private let original_ap_2_6: AccessPointConfig
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        ap_1_1 = try container.decode(AccessPointConfig.self, forKey: .ap_1_1)
        ap_1_2 = try container.decode(AccessPointConfig.self, forKey: .ap_1_2)
        ap_1_3 = try container.decode(AccessPointConfig.self, forKey: .ap_1_3)
        ap_1_4 = try container.decode(AccessPointConfig.self, forKey: .ap_1_4)
        ap_1_5 = try container.decode(AccessPointConfig.self, forKey: .ap_1_5)
        ap_1_6 = try container.decode(AccessPointConfig.self, forKey: .ap_1_6)
        
        ap_2_1 = try container.decode(AccessPointConfig.self, forKey: .ap_2_1)
        ap_2_2 = try container.decode(AccessPointConfig.self, forKey: .ap_2_2)
        ap_2_3 = try container.decode(AccessPointConfig.self, forKey: .ap_2_3)
        ap_2_4 = try container.decode(AccessPointConfig.self, forKey: .ap_2_4)
        ap_2_5 = try container.decode(AccessPointConfig.self, forKey: .ap_2_5)
        ap_2_6 = try container.decode(AccessPointConfig.self, forKey: .ap_2_6)
        
        original_ap_1_1 = ap_1_1
        original_ap_1_2 = ap_1_2
        original_ap_1_3 = ap_1_3
        original_ap_1_4 = ap_1_4
        original_ap_1_5 = ap_1_5
        original_ap_1_6 = ap_1_6
        original_ap_2_1 = ap_2_1
        original_ap_2_2 = ap_2_2
        original_ap_2_3 = ap_2_3
        original_ap_2_4 = ap_2_4
        original_ap_2_5 = ap_2_5
        original_ap_2_6 = ap_2_6
    }
}

extension AccessPointsConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return "" // NOT NEEDED
    }
    
    private func getUpdateJson() -> JSON {
        var vals = JSON()
        
        vals[DbApConfig.AP_1_1] = ap_1_1.getJson()
        vals[DbApConfig.AP_1_2] = ap_1_2.getJson()
        vals[DbApConfig.AP_1_3] = ap_1_3.getJson()
        vals[DbApConfig.AP_1_4] = ap_1_4.getJson()
        vals[DbApConfig.AP_1_5] = ap_1_5.getJson()
        vals[DbApConfig.AP_1_6] = ap_1_6.getJson()
        
        vals[DbApConfig.AP_2_1] = ap_2_1.getJson()
        vals[DbApConfig.AP_2_2] = ap_2_2.getJson()
        vals[DbApConfig.AP_2_3] = ap_2_3.getJson()
        vals[DbApConfig.AP_2_4] = ap_2_4.getJson()
        vals[DbApConfig.AP_2_5] = ap_2_5.getJson()
        vals[DbApConfig.AP_2_6] = ap_2_6.getJson()
        
        return vals
    }
    
    private func getOriginalValuesAsJson() -> JSON {
        var vals = JSON()
        
        vals[DbApConfig.AP_1_1] = original_ap_1_1.getJson()
        vals[DbApConfig.AP_1_2] = original_ap_1_2.getJson()
        vals[DbApConfig.AP_1_3] = original_ap_1_3.getJson()
        vals[DbApConfig.AP_1_4] = original_ap_1_4.getJson()
        vals[DbApConfig.AP_1_5] = original_ap_1_5.getJson()
        vals[DbApConfig.AP_1_6] = original_ap_1_6.getJson()
        
        vals[DbApConfig.AP_2_1] = original_ap_2_1.getJson()
        vals[DbApConfig.AP_2_2] = original_ap_2_2.getJson()
        vals[DbApConfig.AP_2_3] = original_ap_2_3.getJson()
        vals[DbApConfig.AP_2_4] = original_ap_2_4.getJson()
        vals[DbApConfig.AP_2_5] = original_ap_2_5.getJson()
        vals[DbApConfig.AP_2_6] = original_ap_2_6.getJson()
        
        return vals
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        let tableName = accessPointType == .NODE ? AccessPointsConfig.getNodeTableName() : AccessPointsConfig.getMeshTableName()
        json[tableName] = getUpdateJson()
        
        return json
    }
    
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = getOriginalValuesAsJson()
        let njson = getUpdateJson()
        let tableName = accessPointType == .NODE ? AccessPointsConfig.getNodeTableName() : AccessPointsConfig.getMeshTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson, targetJson: njson, tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
}

// MARK: -
public struct AccessPointConfig: TopLevelJSONResponse, Equatable, Codable {
    var originalJson: JSON = JSON()
    
    public static func == (lhs: AccessPointConfig, rhs: AccessPointConfig) -> Bool {
        return (lhs.pass == rhs.pass &&
                    lhs.use == rhs.use &&
                    lhs.locked == rhs.locked &&
                    lhs.ssid == rhs.ssid &&
                    lhs.mdns == rhs.mdns &&
                    lhs.hidden == rhs.hidden &&
                    lhs.lan_id == rhs.lan_id &&
                    lhs.system_only == rhs.system_only &&
                    lhs.secure_mode == rhs.secure_mode &&
                    lhs.wpaMode == rhs.wpaMode &&
                    lhs.radius1_auth_id == rhs.radius1_auth_id &&
                    lhs.radius2_auth_id == rhs.radius2_auth_id &&
                    lhs.radius1_acct_id == rhs.radius1_acct_id &&
                    lhs.radius2_acct_id == rhs.radius2_acct_id &&
                    lhs.enable80211w == rhs.enable80211w &&
                    lhs.enable80211r == rhs.enable80211r)
    }
    
    var isEmpty: Bool {
        return pass.isEmpty && ssid.isEmpty
    }
    
    public enum SecureMode: Int, Codable {
        case open = 0
        case preSharedPsk = 1
        case enterprise = 2
    }
    
    public enum EncryptMode: Int {
        case wpa2Only = 0
        case wpa3Only = 1
        case wpa2AndWpa3 = 2
    }
    
    public enum Enable80211w: Int, Codable {
        case disabled = 0
        case enabled = 1
        case required = 2
    }
    
    public var pass: String
    public var use: Bool
    public var locked: Bool
    public var ssid: String
    public var mdns: Bool
    public var hidden: Bool
    public var lan_id: Int
    public var system_only: Bool
    
    // SECURITY FEATURES
    
    public var wpa_mode: Int
    public var wpaMode: EncryptMode? // None if not supported by hub
    public var radius1_auth_id: Int // Empty if not supported by hub. 0 if not set
    public var radius2_auth_id: Int // Empty if not supported by hub. 0 if not set
    public var radius1_acct_id: Int // Empty if not supported by hub. 0 if not set
    public var radius2_acct_id: Int // Empty if not supported by hub. 0 if not set
    public var enable80211r: Bool // False by default
    public var enable80211w: Enable80211w
    
    public var secure_mode: Int
    public var secureMode: SecureMode? {
        didSet {
            if let sm = secureMode {
                secure_mode = sm.rawValue
            }
        }
    }
    public var enhancedSecuritySupported: Bool
    
    public var systemOnlyAndInUse: Bool {
        return use && system_only
    }
        
    /// Locked value flipped
    public var enabled: Bool {
        get { return !locked }
        set { locked = !newValue}
    }
    
    private enum CodingKeys: String, CodingKey {
        case pass, use, locked, ssid, mdns, hidden, lan_id, system_only, enhancedSecuritySupported, secure_mode, wpa_mode, radius1_auth_id, radius2_auth_id, radius1_acct_id, radius2_acct_id
        case enable80211r = "80211r"
        case enable80211w = "80211w"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        use = try container.decode(Bool.self, forKey: .use)
        pass = try container.decode(String.self, forKey: .pass)
        
        locked =  try container.decode(Bool.self, forKey: .locked)
        ssid =  try container.decode(String.self, forKey: .ssid)
        mdns =  try container.decode(Bool.self, forKey: .mdns)
        hidden =  try container.decode(Bool.self, forKey: .hidden)
        lan_id =  try container.decode(Int.self, forKey: .lan_id)
        system_only =  try container.decode(Bool.self, forKey: .system_only)
        
        if let sm = try container.decodeIfPresent(Int.self, forKey: .secure_mode) {
            self.secure_mode = sm
            self.secureMode = SecureMode(rawValue: sm)
            self.enhancedSecuritySupported = true
        }
        else {
            self.secure_mode = -1
            self.enhancedSecuritySupported = false
        }
        
        wpa_mode = try container.decode(Int.self, forKey: .wpa_mode)
        self.wpaMode = EncryptMode(rawValue: wpa_mode)
    
        enable80211r = try container.decode(Bool.self, forKey: .enable80211r)
        enable80211w = try container.decode(Enable80211w.self, forKey: .enable80211w)
        
        radius1_auth_id = try container.decode(Int.self, forKey: .radius1_auth_id)
        radius2_auth_id = try container.decode(Int.self, forKey: .radius2_auth_id)
        radius1_acct_id = try container.decode(Int.self, forKey: .radius1_acct_id)
        radius2_acct_id = try container.decode(Int.self, forKey: .radius2_acct_id)
    }
    
    func getJson() -> JSON {
        var vals = originalJson
        
        vals[DbApConfig.PASSWORD] = pass
        vals[DbApConfig.USE] = use
        vals[DbApConfig.LOCKED] = locked
        vals[DbApConfig.SSID] = ssid
        vals[DbApConfig.MDNS] = mdns
        vals[DbApConfig.HIDDEN] = hidden
        vals[DbApConfig.LAN_ID] = lan_id
        vals[DbApConfig.SYSTEM_ONLY] = system_only
        
        if enhancedSecuritySupported {
            vals[DbApConfig.SECUREMODE] = secureMode?.rawValue ?? 2 // Use 1 for backwards compatability
            vals[DbApConfig.ENCRYPTMODE] = wpaMode?.rawValue ?? 2 // Use 1 for backwards compatability
            vals[DbApConfig.RADIUS1AUTHID] = radius1_auth_id
            vals[DbApConfig.RADIUS2AUTHID] = radius2_auth_id
            vals[DbApConfig.RADIUS1ACCTID] = radius1_acct_id
            vals[DbApConfig.RADIUS2ACCTID] = radius2_acct_id
            vals[DbApConfig.ENABLE80211R] = enable80211r
            vals[DbApConfig.ENABLE80211W] = enable80211w.rawValue
        }
        
        return vals
    }
}

// MARK: - Helper vars and methods
extension AccessPointConfig {
    var configIsValid: Bool {
        if secureMode != .open {
            if !pskIsValid && !radiusAuthSet { return false }
        }
        
        if !ssidIsValid { return false }
        
        return true
    }
    
    var ssidIsValid: Bool {
        return SSIDNamePasswordValidation.ssidNameValid(str: ssid).0
    }
    
    var pskIsValid: Bool {
        return SSIDNamePasswordValidation.passwordValid(passString: pass, ssid: ssid).0
    }
    
    var radiusAuthSet: Bool {
        return radius1_auth_id != 0 || radius2_auth_id != 0
    }
    
    var isBlank: Bool {
        let blank = !enabled && !hidden && ssid.isEmpty && pass.isEmpty && !radiusAuthSet
        
        return blank
    }
}
