//
//  VLanConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 02/04/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

// MARK: - MESH

public struct MeshVLanConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    public static func == (lhs: MeshVLanConfig, rhs: MeshVLanConfig) -> Bool {
        return lhs.vLans == rhs.vLans
     }
    
    private let vlan_1: VLanModel
    private let vlan_2: VLanModel
    private let vlan_3: VLanModel
    private let vlan_4: VLanModel
    
    public var vLans: [VLanModel]
    
    private enum CodingKeys: String, CodingKey {
        case vlan_1, vlan_2, vlan_3, vlan_4
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        vlan_1 = try container.decode(VLanModel.self, forKey: .vlan_1)
        vlan_2 = try container.decode(VLanModel.self, forKey: .vlan_1)
        vlan_3 = try container.decode(VLanModel.self, forKey: .vlan_1)
        vlan_4 = try container.decode(VLanModel.self, forKey: .vlan_1)
        
        vLans = [vlan_1, vlan_2, vlan_3, vlan_4]
    }
    
    public func resetValuesToOriginal() {
        for lan in vLans {
            lan.resetFromOriginalJson()
        }
    }
}

extension MeshVLanConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbMeshVLanConfig.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbMeshVLanConfig.VLAN_1)
        keys.append(DbMeshVLanConfig.VLAN_2)
        keys.append(DbMeshVLanConfig.VLAN_3)
        keys.append(DbMeshVLanConfig.VLAN_4)
        
        return keys
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[MeshVLanConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        vals[DbMeshVLanConfig.VLAN_1] = vLans[0].getUpdateJSON()
        vals[DbMeshVLanConfig.VLAN_2] = vLans[1].getUpdateJSON()
        vals[DbMeshVLanConfig.VLAN_3] = vLans[2].getUpdateJSON()
        vals[DbMeshVLanConfig.VLAN_4] = vLans[3].getUpdateJSON()
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = MeshVLanConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
}

// MARK: - NODE
public struct NodeVLanConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    private let vlan_1: VLanModel
    private let vlan_2: VLanModel
    private let vlan_3: VLanModel
    private let vlan_4: VLanModel
    
    public var vLans: [VLanModel]
    
    private enum CodingKeys: String, CodingKey {
        case vlan_1, vlan_2, vlan_3, vlan_4
    }
    
    public static func == (lhs: NodeVLanConfig, rhs: NodeVLanConfig) -> Bool {
        return lhs.vLans == rhs.vLans
     }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        vlan_1 = try container.decode(VLanModel.self, forKey: .vlan_1)
        vlan_2 = try container.decode(VLanModel.self, forKey: .vlan_1)
        vlan_3 = try container.decode(VLanModel.self, forKey: .vlan_1)
        vlan_4 = try container.decode(VLanModel.self, forKey: .vlan_1)
        
        vLans = [vlan_1, vlan_2, vlan_3, vlan_4]
    }

    public func resetValuesToOriginal() {
        for lan in vLans {
            lan.resetFromOriginalJson()
        }
    }
}

extension NodeVLanConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbNodeVLanConfig.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeVLanConfig.VLAN_1)
        keys.append(DbNodeVLanConfig.VLAN_2)
        keys.append(DbNodeVLanConfig.VLAN_3)
        keys.append(DbNodeVLanConfig.VLAN_4)
        
        return keys
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeVLanConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        vals[DbNodeVLanConfig.VLAN_1] = vLans[0].getUpdateJSON()
        vals[DbNodeVLanConfig.VLAN_2] = vLans[1].getUpdateJSON()
        vals[DbNodeVLanConfig.VLAN_3] = vLans[2].getUpdateJSON()
        vals[DbNodeVLanConfig.VLAN_4] = vLans[3].getUpdateJSON()
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = NodeVLanConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
}

// MARK: - VLAN MODEL
public class VLanModel: Equatable, Codable {
    
    public static func == (lhs: VLanModel, rhs: VLanModel) -> Bool {
        return lhs.role == rhs.role &&
            lhs.use == rhs.use &&
            lhs.locked == rhs.locked &&
            lhs.name == rhs.name &&
            lhs.port == rhs.port &&
            lhs.tag == rhs.tag
     }

    private var originalJson: JSON = JSON()
    
    public var role: Role
    public var use: Bool
    public var locked: Bool
    public var name: String
    public var port: Int
    public var tag: Int
    
    private enum CodingKeys: String, CodingKey {
        case role, use, locked, name, port, tag
    }
    
    func resetFromOriginalJson() {
        let roleDescription = JSONValidator.valiate(key: DbMeshVLanConfig.ROLE,
                                                    json: originalJson,
                                                    expectedType:String.self,
                                                    defaultValue: "") as! String
        role = Role.roleFromDescription(description: roleDescription)
        
        use = JSONValidator.valiate(key: DbMeshVLanConfig.USE,
                                    json: originalJson,
                                    expectedType:Bool.self,
                                    defaultValue: false) as! Bool
        
        locked = JSONValidator.valiate(key: DbMeshVLanConfig.LOCKED,
                                       json: originalJson,
                                       expectedType:Bool.self,
                                       defaultValue: false) as! Bool
        
        name = JSONValidator.valiate(key: DbMeshVLanConfig.NAME,
                                     json: originalJson,
                                     expectedType:String.self,
                                     defaultValue: "") as! String
        
        port = JSONValidator.valiate(key: DbMeshVLanConfig.PORT,
                                     json: originalJson,
                                     expectedType:Int.self,
                                     defaultValue: -1) as! Int
        
        tag = JSONValidator.valiate(key: DbMeshVLanConfig.TAG,
                                    json: originalJson,
                                    expectedType:Int.self,
                                    defaultValue: -1) as! Int
    }
    
    func getUpdateJSON() -> JSON {
        var json = originalJson
        json[DbMeshVLanConfig.NAME] = name
        
        if use {
            json[DbMeshVLanConfig.ROLE] = role.rawValue
        }
        else {
            json[DbMeshVLanConfig.ROLE] = Role.UNUSED.rawValue
        }
        
        json[DbMeshVLanConfig.USE] = use
        json[DbMeshVLanConfig.LOCKED] = locked
        json[DbMeshVLanConfig.NAME] = name
        json[DbMeshVLanConfig.PORT] = port
        json[DbMeshVLanConfig.TAG] = tag
        
        return json
    }
}

