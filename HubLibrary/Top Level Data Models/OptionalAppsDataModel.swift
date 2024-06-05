//
//  OptionalAppsDataModel.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 29/04/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

public struct OptionalAppsDataModel: TopLevelJSONResponse {
    
    public var originalJson: JSON
    
    let decoder = JSONDecoder()
    
    private static let tag = "BaseDataModelRequester"
    
    // PUBLIC WIFI
    public var publicWifiSettingsConfig: PublicWifiSettingsConfig?
    public var publicWifiOperatorsConfig: PublicWifiOperatorsConfig?
    public var publicWifiInfoConfig: PublicWifiInfoConfig?
    
    // ETHERNET
    public var nodePortConfig: NodePortConfig?
    public var meshPortConfig: MeshPortConfig?
    public var nodePortStatusConfig: NodePortStatusConfig?
    public var nodeWanStaticIpConfig: NodeWanStaticIpConfig?
    
    // LAN AND STATIC IP TABLES
    public var nodeLanStaticIpConfig: NodeLanStaticIpConfig?
    public var nodeLanConfig: NodeLanConfig?
    public var nodeLanStatus: NodeLanStatusConfig?
    
    // OTHER
    public var sdWanConfig: SdWanConfig?
    public var cellularDataStatsConfig: CellularDataStatsConfig?
    public var meshRadiusServerConfig: MeshRadiusConfig?
    public var meshWdsTopologyConfig: MeshWdsTopologyConfig?
    public var nodeLanConfigStaticIp: NodeLanConfigStaticIp?
    
     public static func newFromDict(dict: [String : Any]) -> OptionalAppsDataModel {
        let model = OptionalAppsDataModel.init(from: dict)
         return model
     }
    
    init() {
        originalJson = JSON()
    }
    
    init(from json: JSON) {
        originalJson = json
        
        for key in originalJson.keys {
            // Check for Public Wifi Tables
            if key == DbPublicWifiInfo.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    publicWifiInfoConfig = try decoder.decode(PublicWifiInfoConfig.self, from: jsonData)
                    publicWifiInfoConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "PublicWifiInfoConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbPublicWifiOperator.TableName {
                publicWifiOperatorsConfig = PublicWifiOperatorsConfig.init(from: json[key] as! JSON)
            }
            else if key == DbPublicWifiSettings.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    publicWifiSettingsConfig = try decoder.decode(PublicWifiSettingsConfig.self, from: jsonData)
                    publicWifiSettingsConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "PublicWifiSettingsConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbNodeSdWan.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    sdWanConfig = try decoder.decode(SdWanConfig.self, from: jsonData)
                    sdWanConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "SdWanConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbCellularDataCount.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    cellularDataStatsConfig = try decoder.decode(CellularDataStatsConfig.self, from: jsonData)
                    cellularDataStatsConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "CellularDataStatsConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbNodePortConfig.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    nodePortConfig = try decoder.decode(NodePortConfig.self, from: jsonData)
                    nodePortConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "NodePortConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbMeshPortConfig.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    meshPortConfig = try decoder.decode(MeshPortConfig.self, from: jsonData)
                    meshPortConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "MeshPortConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbNodePortStatus.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    nodePortStatusConfig = try decoder.decode(NodePortStatusConfig.self, from: jsonData)
                    nodePortStatusConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "NodePortStatusConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbNodeLanStaticIp.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    nodeLanStaticIpConfig = try decoder.decode(NodeLanStaticIpConfig.self, from: jsonData)
                    nodeLanStaticIpConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "NodeLanStaticIpConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbNodeLanConfig.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    nodeLanConfig = try decoder.decode(NodeLanConfig.self, from: jsonData)
                    nodeLanConfig?.originalJson = json[key] as! JSON
                    NodeLanConfig.usesLegacyTable = false
                }
                catch {
                    Logger.logDecodingError(className: "NodeLanConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbNodeWanStaticIp.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    nodeWanStaticIpConfig = try decoder.decode(NodeWanStaticIpConfig.self, from: jsonData)
                    nodeWanStaticIpConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "NodeWanStaticIpConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbNodeLanConfigStaticIp.TableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    nodeLanConfigStaticIp = try decoder.decode(NodeLanConfigStaticIp.self, from: jsonData)
                    nodeLanConfigStaticIp?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "NodeLanConfigStaticIp", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbNodeLanStatus.TableName {                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    nodeLanStatus = try decoder.decode(NodeLanStatusConfig.self, from: jsonData)
                    nodeLanStatus?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "NodeLanStatusConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == DbMeshRadiusConfig.TableName {                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    meshRadiusServerConfig = try decoder.decode(MeshRadiusConfig.self, from: jsonData)
                    meshRadiusServerConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "MeshRadiusConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else if key == MeshWdsTopologyConfig.tableName {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json[key] as Any, options: .prettyPrinted)
                    meshWdsTopologyConfig = try decoder.decode(MeshWdsTopologyConfig.self, from: jsonData)
                    meshWdsTopologyConfig?.originalJson = json[key] as! JSON
                }
                catch {
                    Logger.logDecodingError(className: "meshWdsTopologyConfig", tag: OptionalAppsDataModel.tag, error: error)
                }
            }
            else {
                Logger.log(tag: OptionalAppsDataModel.tag, message: "Unknown table: \(key)")
            }
        }
    }
}
