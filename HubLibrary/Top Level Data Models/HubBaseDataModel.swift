//
//  HubBaseDataModel.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 26/04/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

public struct HubBaseDataModel: TopLevelJSONResponse {
    private static let tag = "HubBaseDataModel"
    
    public var originalJson: JSON
    
    let decoder = JSONDecoder()
    
    // NODE CONFIG TABLE
    public var lockStatus: LockStatus?
    public var nodeConfig: NodeConfig?
    public var beaconConfig: BeaconConfig?
    public var locationConfig: LocationConfig?
    public var gatewayConfig: GatewayConfig?
    public var analyticsConfig: AnalyticsConfig?
    public var ipConfig: IpConfig?
    public var routerConfig: RouterConfig?
    public var vmeshConfig: VmeshConfig?
    
    // OTHER TABLES
    public var nodeWanConfig: NodeWanConfig?
    public var meshLanConfig: MeshLanConfig?
    public var nodeAPConfig: AccessPointsConfig?
    public var meshAPConfig: AccessPointsConfig?
    public var nodeCapabilitiesConfig: NodeCapabilities?
    public var nodeControlConfig: NodeControlConfig?
    public var nodeInfoConfig: NodeInfo?
    public var nodeStatusConfig: NodeStatus?
    
    public var installedAppsConfig: InstalledAppsConfig?
    
    public var meshVlanConfig: MeshVLanConfig?
    public var nodeVlanConfig: NodeVLanConfig?
    
    public var nodeApStatus: NodeApStatus?
    public var nodePortInfo: NodePortInfoConfig?
    
    public static func newFromDict(dict: [String : Any]) -> HubBaseDataModel {
        let model = HubBaseDataModel(from: dict)
        
        return model
    }
    
    var isComplete: Bool {
        return lockStatus != nil &&
        nodeConfig != nil &&
        beaconConfig != nil &&
        locationConfig != nil &&
        gatewayConfig != nil &&
        analyticsConfig != nil &&
        ipConfig != nil &&
        routerConfig != nil &&
        vmeshConfig != nil &&
        nodeWanConfig != nil &&
        meshLanConfig != nil &&
        nodeAPConfig != nil &&
        meshAPConfig != nil &&
        nodeCapabilitiesConfig != nil &&
        nodeControlConfig != nil &&
        nodeInfoConfig != nil &&
        nodeStatusConfig != nil &&
        installedAppsConfig != nil &&
        meshVlanConfig != nil &&
        nodeVlanConfig != nil &&
        nodeApStatus != nil &&
        nodePortInfo != nil
    }
    
    /// Init from the Hub API
    init(from json: JSON) {
        originalJson = json
        
        for tableName in BaseDataModelRequester.tableNames {
            if let tableJSON = json[tableName] {
                processResponsesToConfigs(tableName: tableName, contentsJSON: tableJSON as! JSON)
            }
            else {
                Logger.log(tag: HubBaseDataModel.tag, message: "No content for \(tableName)")
            }
        }
    }
    
    private mutating func processResponsesToConfigs(tableName: String, contentsJSON: JSON) {
        switch tableName {
        case DbNodeConfig.TableName:
            createNodeConfigDerivedConfigs(json: contentsJSON)
        case DbNodeWanConfig.TableName:
            createNodeWanConfig(json: contentsJSON)
        case DbMeshLanConfig.TableName:
            createMeshLanConfig(json: contentsJSON)
        case DbApConfig.TableNameMesh:
            createMeshAPConfig(json: contentsJSON)
        case DbApConfig.TableNameNode:
            createNodeAPConfig(json: contentsJSON)
        case DbNodeCapabilities.TableName:
            createNodeCapabilitiesConfig(json: contentsJSON)
        case DbNodeControl.TableName:
            createNodeControlConfig(json: contentsJSON)
        case DbNodeInfo.TableName:
            createNodeInfoConfig(json: contentsJSON)
        case DbNodeStatus.TableName:
            createNodeStatusConfig(json: contentsJSON)
        case DbNodeServices.TableName:
            createInstalledAppsConfig(json: contentsJSON)
        case DbNodeVLanConfig.TableName:
            createNodeVLanConfig(json: contentsJSON)
        case DbMeshVLanConfig.TableName:
            createMeshVLanConfig(json: contentsJSON)
        case DbNodeApStatus.TableName:
            createNodeApStatus(json: contentsJSON)
        case NodePortInfoConfig.getTableName():
            createNodePortInfo(json: contentsJSON)
        case DbNodeVLanConfig.TableName:
            createNodeVLanConfig(json: contentsJSON)
        case DbMeshVLanConfig.TableName:
            createMeshVLanConfig(json: contentsJSON)
        default:
            Logger.log(tag: HubBaseDataModel.tag, message: "Unknown DB table named \(tableName)")
        }
    }
}

// MARK: - Config Creation
extension HubBaseDataModel {
    fileprivate mutating func createNodeConfigDerivedConfigs(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            lockStatus = try decoder.decode(LockStatus.self, from: jsonData)
            lockStatus?.originalJson = json
            
            nodeConfig = try decoder.decode(NodeConfig.self, from: jsonData)
            nodeConfig?.originalJson = json
            
            analyticsConfig = try decoder.decode(AnalyticsConfig.self, from: jsonData)
            analyticsConfig?.originalJson = json
            
            beaconConfig = try decoder.decode(BeaconConfig.self, from: jsonData)
            beaconConfig?.originalJson = json
            
            ipConfig = try decoder.decode(IpConfig.self, from: jsonData)
            ipConfig?.originalJson = json
            
            vmeshConfig = try decoder.decode(VmeshConfig.self, from: jsonData)
            vmeshConfig?.originalJson = json
            
            routerConfig = try decoder.decode(RouterConfig.self, from: jsonData)
            routerConfig?.originalJson = json
            
            locationConfig = try decoder.decode(LocationConfig.self, from: jsonData)
            locationConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "NodeConfig", tag: HubBaseDataModel.tag, error: error)
        }
        
        gatewayConfig = GatewayConfig.init(from: json)
    }
    
    fileprivate mutating func createNodeWanConfig(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            nodeWanConfig = try decoder.decode(NodeWanConfig.self, from: jsonData)
            nodeWanConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "NodeWanConfig", tag: HubBaseDataModel.tag, error: error)
        }
    }
    
    fileprivate mutating func createMeshLanConfig(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            meshLanConfig = try decoder.decode(MeshLanConfig.self, from: jsonData)
            meshLanConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "MeshLanConfig", tag: HubBaseDataModel.tag, error: error)
        }
    }
    
    fileprivate mutating func createMeshAPConfig(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            meshAPConfig = try decoder.decode(AccessPointsConfig.self, from: jsonData)
            meshAPConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "MeshLanConfig", tag: HubBaseDataModel.tag, error: error)
        }
    }
    
    fileprivate mutating func createNodeAPConfig(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            nodeAPConfig = try decoder.decode(AccessPointsConfig.self, from: jsonData)
            nodeAPConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "AccessPointsConfig - NodeApConfig", tag: HubBaseDataModel.tag, error: error)
        }
    }
    
    fileprivate mutating func createNodeCapabilitiesConfig(json: JSON) {
        nodeCapabilitiesConfig = NodeCapabilities.init(from: json)
    }
    
    fileprivate mutating func createNodeControlConfig(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            nodeControlConfig = try decoder.decode(NodeControlConfig.self, from: jsonData)
            nodeControlConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "NodeControlConfig", tag: HubBaseDataModel.tag, error: error)
        }
    }
    
    fileprivate mutating func createNodeInfoConfig(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            nodeInfoConfig = try decoder.decode(NodeInfo.self, from: jsonData)
            nodeInfoConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "NodeInfo", tag: HubBaseDataModel.tag, error: error)
        }
    }
    
    fileprivate mutating func createNodeStatusConfig(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            nodeStatusConfig = try decoder.decode(NodeStatus.self, from: jsonData)
            nodeStatusConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "NodeStatus", tag: HubBaseDataModel.tag, error: error)
        }
    }
    
    fileprivate mutating func createInstalledAppsConfig(json: JSON) {
        installedAppsConfig = InstalledAppsConfig.init(from: json)
    }
    
    fileprivate mutating func createMeshVLanConfig(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            meshVlanConfig = try decoder.decode(MeshVLanConfig.self, from: jsonData)
            meshVlanConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "MeshVLanConfig", tag: HubBaseDataModel.tag, error: error)
        }
    }
    
    fileprivate mutating func createNodeVLanConfig(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            nodeVlanConfig = try decoder.decode(NodeVLanConfig.self, from: jsonData)
            nodeVlanConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "NodeVLanConfig", tag: HubBaseDataModel.tag, error: error)
        }
    }
    
    fileprivate mutating func createNodeApStatus(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            nodeApStatus = try decoder.decode(NodeApStatus.self, from: jsonData)
            nodeApStatus?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "NodeApStatus", tag: HubBaseDataModel.tag, error: error)
        }
    }
    
    fileprivate mutating func createNodePortInfo(json: JSON) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            nodePortInfo = try decoder.decode(NodePortInfoConfig.self, from: jsonData)
            nodePortInfo?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "NodePortInfoConfig", tag: HubBaseDataModel.tag, error: error)
        }
    }
}
