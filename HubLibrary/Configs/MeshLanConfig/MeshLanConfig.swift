//
//  MeshLanConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 07/06/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation

public struct MeshLanConfig: TopLevelJSONResponse, Equatable, Codable {
    var originalJson: JSON = JSON()
    
    public var lan_1: MeshLan
    public var lan_2: MeshLan
    public var lan_3: MeshLan
    public var lan_4: MeshLan
    
    private enum CodingKeys: String, CodingKey {
        case lan_1, lan_2, lan_3, lan_4
    }
    
    // MARK: - Original MeshLanConfig
    private let original_lan_1: MeshLan
    private let original_lan_2: MeshLan
    private let original_lan_3: MeshLan
    private let original_lan_4: MeshLan
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        lan_1 = try container.decode(MeshLan.self, forKey: .lan_1)
        lan_2 = try container.decode(MeshLan.self, forKey: .lan_2)
        lan_3 = try container.decode(MeshLan.self, forKey: .lan_3)
        lan_4 = try container.decode(MeshLan.self, forKey: .lan_4)
        
        original_lan_1 = lan_1
        original_lan_2 = lan_2
        original_lan_3 = lan_3
        original_lan_4 = lan_4
    }

    /// Check if the any of the lans are set to isolated.
    /// Call before sending changes to MAS or HUB APIs
    public mutating func setWanInterfaceToZeroIfIsolated() {
        lan_1.setWanTo0IfWanModeIsIsolated()
        lan_2.setWanTo0IfWanModeIsIsolated()
        lan_3.setWanTo0IfWanModeIsIsolated()
        lan_4.setWanTo0IfWanModeIsIsolated()
    }
    
    public var lans: [MeshLan] {
        get {
            return [lan_1, lan_2, lan_3, lan_4]
        }
    }
    
    public static func getTableName() -> String {
        return DbMeshLanConfig.TableName
    }
    
    public static func == (lhs: MeshLanConfig, rhs: MeshLanConfig) -> Bool {
        return lhs.lans == rhs.lans
    }
}

extension MeshLanConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        let vals = getUpdateJson()
        var json = SecureUpdateJSON()
        json[MeshLanConfig.getTableName()] = vals
        
        return json
    }
    
    private func getOriginalValuesAsJson() -> JSON {
        var vals = JSON()
        vals[DbMeshLanConfig.LAN_1] = original_lan_1.getJson()
        vals[DbMeshLanConfig.LAN_2] = original_lan_2.getJson()
        vals[DbMeshLanConfig.LAN_3] = original_lan_3.getJson()
        vals[DbMeshLanConfig.LAN_4] = original_lan_4.getJson()
        return vals
    }
    
    private func getUpdateJson() -> JSON {
        var vals = JSON()
        vals[DbMeshLanConfig.LAN_1] = lan_1.getJson()
        vals[DbMeshLanConfig.LAN_2] = lan_2.getJson()
        vals[DbMeshLanConfig.LAN_3] = lan_3.getJson()
        vals[DbMeshLanConfig.LAN_4] = lan_4.getJson()
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = getOriginalValuesAsJson()
        let njson = getUpdateJson()
        let tableName = MeshLanConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                      targetJson: njson,
                                                      tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
}

public struct MeshLan: Equatable, Codable {
    private enum ClientIsolated: String {
        case open = "open"
        case isolated = "isolated"
        
        static func state(clientIsolated: Bool) -> ClientIsolated {
            return clientIsolated ? .isolated : .open
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case use,
             modify,
             wan_id,
             name,
             mode_via,
             client_traffic,
             ap_set_1,
             ap_set_2,
             zone,
             port_set,
             vlan_set,
             wan_mode,
             ip4_subnet,
             ip_mode
    }
    
    @DecodableDefault.False var use: Bool
    @DecodableDefault.False var modify: Bool
    var wan_id: Int
    var name: String
    @DecodableDefault.EmptyString var mode_via: String
    private var client_traffic: String
    @DecodableDefault.EmptyList var ap_set_1: [Int]
    @DecodableDefault.EmptyList var ap_set_2: [Int]
    var zone: String
    var port_set: [Int]
    var vlan_set: [Int]
    private var wan_mode: String
    var ip4_subnet: String
    var ip_mode: String?
    
    var clientIsolationOn: Bool {
        get {
            if client_traffic.isEmpty { return false }
            return client_traffic == ClientIsolated.isolated.rawValue }
        set {
            client_traffic = ClientIsolated.state(clientIsolated: newValue).rawValue
        }
    }

    /// If LAN is isolated the wan interface should be 0
    public mutating func setWanTo0IfWanModeIsIsolated() {
        if wanMode == .ISOLATED { wan_id = 0 }
    }
    
    public var wanMode: WanMode {
        get {
            let mode = WanMode(rawValue: wan_mode)
            return mode! // Want a crash if this doesnt work
        }
        set { wan_mode = newValue.rawValue }
    }

    public var ipManagementMode: IpManagementMode? {
        get {
            guard let ip_mode,
                  let mode = IpManagementMode(rawValue: ip_mode.lowercased()) else { return nil }
            return mode
        }
        set {
            guard let newValue else {
                ip_mode = nil
                return
            }

            ip_mode = newValue.rawValue
        }
    }
    
    // See VHM 704
    public var dhcp: Bool {
        return wanMode != .BRIDGED && mode_via != "tun0" && use
    }
    
    public static func == (lhs: MeshLan, rhs: MeshLan) -> Bool {
        return lhs.use == rhs.use &&
        lhs.wan_id == rhs.wan_id &&
        lhs.name == rhs.name &&
        lhs.mode_via == rhs.mode_via &&
        lhs.wan_mode == rhs.wan_mode &&
        lhs.ip4_subnet == rhs.ip4_subnet &&
        lhs.dhcp == rhs.dhcp &&
        lhs.modify == rhs.modify &&
        lhs.ap_set_1 == rhs.ap_set_1 &&
        lhs.ap_set_2 == rhs.ap_set_2 &&
        lhs.zone == rhs.zone &&
        lhs.port_set == rhs.port_set &&
        lhs.vlan_set == rhs.vlan_set &&
        lhs.client_traffic == rhs.client_traffic &&
        lhs.ipManagementMode == rhs.ipManagementMode
    }
    
    func getJson() -> JSON {
        var vals = JSON()
        
        vals[DbMeshLanConfig.USE] = use
        vals[DbMeshLanConfig.MODIFY] = modify
        vals[DbMeshLanConfig.WAN_INTERFACE] = wan_id
        vals[DbMeshLanConfig.NAME] = name
        vals[DbMeshLanConfig.WAN] = wan_mode
        vals[DbMeshLanConfig.SUBNET] = ip4_subnet
        vals[DbMeshLanConfig.DHCP] = dhcp
        vals[DbMeshLanConfig.AP_SET_1] = ap_set_1
        vals[DbMeshLanConfig.AP_SET_2] = ap_set_2
        vals[DbMeshLanConfig.MODE_VIA] = mode_via
        vals[DbMeshLanConfig.ZONE] = zone
        vals[DbMeshLanConfig.PORT_SET] = port_set
        vals[DbMeshLanConfig.VLAN_SET] = vlan_set

        if let ip_mode {
            vals[DbMeshLanConfig.IP_Mode] = ip_mode
        }


        
        if !client_traffic.isEmpty {
            vals[DbMeshLanConfig.CLIENT_TRAFFIC] = client_traffic
        }
        
        return vals
    }
}
