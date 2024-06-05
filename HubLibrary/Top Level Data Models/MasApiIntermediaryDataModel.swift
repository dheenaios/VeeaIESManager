//
//  MasApiIntermediaryDataModel.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 09/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

/// Currently this is an intermediary data model. It will be used to produce the
/// Base and optional data models required
///  by the Hub API
public class MasApiIntermediaryDataModel {
    
    static let tag = "MasApiIntermediaryDataModel"
    
    var lockStatus: LockStatus?
    var nodeConfig: NodeConfig?
    var beaconConfig: BeaconConfig?
    var locationConfig: LocationConfig?
    var gatewayConfig: GatewayConfig?
    var analyticsConfig: AnalyticsConfig?
    var ipConfig: IpConfig?
    var routerConfig: RouterConfig?
    var vmeshConfig: VmeshConfig?
    var nodeWanConfig: NodeWanConfig?
    var meshLanConfig: MeshLanConfig?
    var nodeAPConfig: AccessPointsConfig?
    var meshAPConfig: AccessPointsConfig?
    var nodeCapabilities: NodeCapabilities?
    var nodeControlConfig: NodeControlConfig?
    var iesInfo: NodeInfo?
    var nodeStatus: NodeStatus?
    var installedAppsConfig: InstalledAppsConfig?
    var meshVLanConfig: MeshVLanConfig?
    var nodeVLanConfig: NodeVLanConfig?
    var publicWifiSettingsConfig: PublicWifiSettingsConfig?
    var publicWifiOperatorsConfig: PublicWifiOperatorsConfig?
    var publicWifiInfoConfig: PublicWifiInfoConfig?
    var nodePortConfig: NodePortConfig?
    var meshPortConfig: MeshPortConfig?
    var nodePortStatusConfig: NodePortStatusConfig?
    var nodeWanStaticIpConfig: NodeWanStaticIpConfig?
    var nodeLanConfigStaticIp: NodeLanConfigStaticIp?
    var nodeLanStaticIpConfig: NodeLanStaticIpConfig?
    var nodeLanConfig: NodeLanConfig?
    var nodeLanStatusConfig: NodeLanStatusConfig?
    var sdWanConfig: SdWanConfig?
    var cellularDataStatsConfig: CellularDataStatsConfig?
    var meshRadiusConfig: MeshRadiusConfig?
    var nodeApStatus: NodeApStatus?
    var nodePortInfo: NodePortInfoConfig?
    var meshWdsTopologyConfig: MeshWdsTopologyConfig?
    
    let decoder = JSONDecoder()
    
    init(responses: [MasApiCallResponse]) {
        for response in responses {
            process(response: response)
        }
    }
    
    private func process(response: MasApiCallResponse) {
        let tableName = response.tableName
        guard let json = response.json,
              let data = response.data else {
            //print("No json for \(tableName)")
            return
        }
        
        if tableName == NodeConfig.getTableName() {
            processNodeConfig(response: response)
        }
        else if tableName == NodeWanConfig.getTableName() {
            do {
                nodeWanConfig = try decoder.decode(NodeWanConfig.self, from: data)
                nodeWanConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeWanConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == MeshLanConfig.getTableName() {
            do {
                meshLanConfig = try decoder.decode(MeshLanConfig.self, from: data)
                meshLanConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "MeshLanConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodeCapabilities.getTableName() {
            nodeCapabilities = NodeCapabilities(from: json)
        }
        else if tableName == NodeControlConfig.getTableName() {
            do {
                nodeControlConfig = try decoder.decode(NodeControlConfig.self, from: data)
                nodeControlConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeControlConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodeInfo.getTableName() {
            do {
                iesInfo = try decoder.decode(NodeInfo.self, from: data)
                iesInfo?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeInfo", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodeStatus.getTableName() {
            do {
                nodeStatus = try decoder.decode(NodeStatus.self, from: data)
                nodeStatus?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeStatus", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == InstalledAppsConfig.getTableName() {
            installedAppsConfig = InstalledAppsConfig(from: json)
        }
        else if tableName == MeshVLanConfig.getTableName() {
            do {
                meshVLanConfig = try decoder.decode(MeshVLanConfig.self, from: data)
                meshVLanConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "MeshVLanConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodeVLanConfig.getTableName() {
            do {
                nodeVLanConfig = try decoder.decode(NodeVLanConfig.self, from: data)
                nodeVLanConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeVLanConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == PublicWifiSettingsConfig.getTableName() {
            do {
                publicWifiSettingsConfig = try decoder.decode(PublicWifiSettingsConfig.self, from: data)
                publicWifiSettingsConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "PublicWifiSettingsConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == PublicWifiOperatorsConfig.getTableName() {
            publicWifiOperatorsConfig = PublicWifiOperatorsConfig(from: json)
        }
        else if tableName == PublicWifiInfoConfig.getTableName() {
            do {
                publicWifiInfoConfig = try decoder.decode(PublicWifiInfoConfig.self, from: data)
                publicWifiInfoConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "PublicWifiInfoConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodePortConfig.getTableName() {
            do {
                nodePortConfig = try decoder.decode(NodePortConfig.self, from: data)
                nodePortConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodePortConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == MeshPortConfig.getTableName() {
            do {
                meshPortConfig = try decoder.decode(MeshPortConfig.self, from: data)
                meshPortConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "MeshPortConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodePortStatusConfig.getTableName() {
            do {
                nodePortStatusConfig = try decoder.decode(NodePortStatusConfig.self, from: data)
                nodePortStatusConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodePortStatusConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodeWanStaticIpConfig.getTableName() {
            do {
                nodeWanStaticIpConfig = try decoder.decode(NodeWanStaticIpConfig.self, from: data)
                nodeWanStaticIpConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeWanStaticIpConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodeLanConfigStaticIp.getTableName() {
            do {
                nodeLanConfigStaticIp = try decoder.decode(NodeLanConfigStaticIp.self, from: data)
                nodeLanConfigStaticIp?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeLanConfigStaticIp", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodeLanStaticIpConfig.getTableName() {
            do {
                nodeLanStaticIpConfig = try decoder.decode(NodeLanStaticIpConfig.self, from: data)
                nodeLanStaticIpConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeLanStaticIpConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodeLanConfig.getTableName() {
            do {
                nodeLanConfig = try decoder.decode(NodeLanConfig.self, from: data)
                nodeLanConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeLanConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodeLanStatusConfig.getTableName() {            
            do {
                nodeLanStatusConfig = try decoder.decode(NodeLanStatusConfig.self, from: data)
                nodeLanStatusConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeLanStatusConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
            
        }
        else if tableName == CellularDataStatsConfig.getTableName() {
            do {
                cellularDataStatsConfig = try decoder.decode(CellularDataStatsConfig.self, from: data)
                cellularDataStatsConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "CellularDataStatsConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == SdWanConfig.getTableName() {
            do {
                sdWanConfig = try decoder.decode(SdWanConfig.self, from: data)
                sdWanConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "SdWanConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == AccessPointsConfig.getMeshTableName() {            
            do {
                meshAPConfig = try decoder.decode(AccessPointsConfig.self, from: data)
                meshAPConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "AccessPointsConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == AccessPointsConfig.getNodeTableName() {
            do {
                nodeAPConfig = try decoder.decode(AccessPointsConfig.self, from: data)
                nodeAPConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "AccessPointsConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == MeshRadiusConfig.getTableName() {
            do {
                meshRadiusConfig = try decoder.decode(MeshRadiusConfig.self, from: data)
                meshRadiusConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "MeshRadiusConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodeApStatus.getTableName() {
            do {
                nodeApStatus = try decoder.decode(NodeApStatus.self, from: data)
                nodeApStatus?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeApStatus", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == NodePortInfoConfig.getTableName() {
            do {
                nodePortInfo = try decoder.decode(NodePortInfoConfig.self, from: data)
                nodePortInfo?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "NodeApStatus", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else if tableName == MeshWdsTopologyConfig.tableName {
            do {
                meshWdsTopologyConfig = try decoder.decode(MeshWdsTopologyConfig.self, from: data)
                meshWdsTopologyConfig?.originalJson = json
            }
            catch {
                Logger.logDecodingError(className: "MeshWdsTopologyConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
            }
        }
        else {
            //print("Unknown table: \(tableName)")
        }
    }
    
    private func processNodeConfig(response: MasApiCallResponse) {
        guard let json = response.json,
              let data = response.data else {
            //print("No Node Config Json")
            return
        }
        
        do {
            lockStatus = try decoder.decode(LockStatus.self, from: data)
            lockStatus?.originalJson = json
            
            beaconConfig = try decoder.decode(BeaconConfig.self, from: data)
            beaconConfig?.originalJson = json
            
            analyticsConfig = try decoder.decode(AnalyticsConfig.self, from: data)
            analyticsConfig?.originalJson = json
            
            nodeConfig = try decoder.decode(NodeConfig.self, from: data)
            nodeConfig?.originalJson = json
            
            ipConfig = try decoder.decode(IpConfig.self, from: data)
            ipConfig?.originalJson = json
            
            vmeshConfig = try decoder.decode(VmeshConfig.self, from: data)
            vmeshConfig?.originalJson = json
            
            routerConfig = try decoder.decode(RouterConfig.self, from: data)
            routerConfig?.originalJson = json
            
            locationConfig = try decoder.decode(LocationConfig.self, from: data)
            locationConfig?.originalJson = json
        }
        catch {
            Logger.logDecodingError(className: "NodeConfig", tag: MasApiIntermediaryDataModel.tag, error: error)
        }
        
        gatewayConfig = GatewayConfig(from: json)
    }
}

// MARK: - Create Base and Optional Models
extension MasApiIntermediaryDataModel {
    public var baseModel: HubBaseDataModel? {
        if let json = makeOriginalBaseJson() {
            return HubBaseDataModel(from: json)
        }
        
        return nil
    }
    
    // We need to add the JSON so the user can make a snapshot
    func makeOriginalBaseJson() -> JSON? {
        var json = JSON()
        
        guard let lockStatus = lockStatus,
              let nodeConfig = nodeConfig,
              let beaconConfig = beaconConfig,
              let locationConfig = locationConfig,
              let gatewayConfig = gatewayConfig,
              let analyticsConfig = analyticsConfig,
              let ipConfig = ipConfig,
              let routerConfig = routerConfig,
              let vmeshConfig = vmeshConfig,
              let nodeWanConfig = nodeWanConfig,
              let meshLanConfig = meshLanConfig,
              let nodeAPConfig = nodeAPConfig,
              let meshAPConfig = meshAPConfig,
              let nodeCapabilitiesConfig = nodeCapabilities,
              let nodeControlConfig = nodeControlConfig,
              let nodeInfoConfig = iesInfo,
              let nodeStatusConfig = nodeStatus,
              let installedAppsConfig = installedAppsConfig,
              let meshVlanConfig = meshVLanConfig,
              let nodeVlanConfig = nodeVLanConfig,
              let nodeApStatus = nodeApStatus,
              let nodePortInfo = nodePortInfo else {
            return nil
        }
        
        json[lockStatus.getTableName()] = lockStatus.originalJson
        json[NodeConfig.getTableName()] = nodeConfig.originalJson
        json[BeaconConfig.getTableName()] = beaconConfig.originalJson
        json[LocationConfig.getTableName()] = locationConfig.originalJson
        json[GatewayConfig.getTableName()] = gatewayConfig.originalJson
        json[AnalyticsConfig.getTableName()] = analyticsConfig.originalJson
        json[ipConfig.getTableName()] = ipConfig.originalJson
        json[RouterConfig.getTableName()] = routerConfig.originalJson
        json[VmeshConfig.getTableName()] = vmeshConfig.originalJson
        json[NodeWanConfig.getTableName()] = nodeWanConfig.originalJson
        json[MeshLanConfig.getTableName()] = meshLanConfig.originalJson
        json[AccessPointsConfig.getNodeTableName()] = nodeAPConfig.originalJson
        json[AccessPointsConfig.getMeshTableName()] = meshAPConfig.originalJson
        json[NodeCapabilities.getTableName()] = nodeCapabilitiesConfig.originalJson
        json[NodeControlConfig.getTableName()] = nodeControlConfig.originalJson
        json[nodeInfoConfig.getTableName()] = nodeInfoConfig.originalJson
        json[NodeStatus.getTableName()] = nodeStatusConfig.originalJson
        json[InstalledAppsConfig.getTableName()] = installedAppsConfig.originalJson
        json[MeshVLanConfig.getTableName()] = meshVlanConfig.originalJson
        json[NodeVLanConfig.getTableName()] = nodeVlanConfig.originalJson
        json[NodeApStatus.getTableName()] = nodeApStatus.originalJson
        json[NodePortInfoConfig.getTableName()] = nodePortInfo.originalJson

        return json
    }
    
    public var optionalModel: OptionalAppsDataModel {
        return OptionalAppsDataModel(from: makeOptionalDataJson())
    }
    
    // We need to add the JSON so the user can make a snapshot
    private func makeOptionalDataJson() -> JSON {
        var json = JSON()
        if let m = nodeLanStatusConfig {
            json[NodeLanStatusConfig.getTableName()] = m.originalJson
        }
        if let m = nodeWanStaticIpConfig {
            json[NodeWanStaticIpConfig.getTableName()] = m.originalJson
        }
        if let m = nodeLanStatusConfig {
            json[NodeLanStatusConfig.getTableName()] = m.originalJson
        }
        if let m = nodeLanConfigStaticIp {
            json[NodeLanConfigStaticIp.getTableName()] = m.originalJson
        }
        if let m = nodeLanStaticIpConfig {
            json[NodeLanStaticIpConfig.getTableName()] = m.originalJson
        }
        if let m = nodeLanConfig {
            json[NodeLanConfig.getTableName()] = m.originalJson
        }
        if let m = nodePortConfig {
            json[NodePortConfig.getTableName()] = m.originalJson
        }
        if let m = meshPortConfig {
            json[MeshPortConfig.getTableName()] = m.originalJson
        }
        if let m = nodePortStatusConfig {
            json[NodePortStatusConfig.getTableName()] = m.originalJson
        }
        if let m = meshRadiusConfig {
            json[MeshRadiusConfig.getTableName()] = m.originalJson
        }
        if let m = meshRadiusConfig {
            json[MeshRadiusConfig.getTableName()] = m.originalJson
        }
        if let m = meshWdsTopologyConfig {
            json[MeshWdsTopologyConfig.tableName] = m.originalJson
        }

        if let installAppKeys = baseModel?.installedAppsConfig?.installedAppKeys {
            for key in installAppKeys {
                switch key {
                case KnownApps.publicWifi.rawValue:
                    if let m = publicWifiSettingsConfig {
                        json[PublicWifiSettingsConfig.getTableName()] = m.originalJson
                    }
                    if let m = publicWifiInfoConfig {
                        json[PublicWifiInfoConfig.getTableName()] = m.originalJson
                    }
                    if let m = publicWifiOperatorsConfig {
                        json[PublicWifiOperatorsConfig.getTableName()] = m.originalJson
                    }
                case KnownApps.sdWan.rawValue:
                    if let m = sdWanConfig {
                        json[SdWanConfig.getTableName()] = m.originalJson
                    }
                    if let m = cellularDataStatsConfig {
                        json[CellularDataStatsConfig.getTableName()] = m.originalJson
                    }
                default:
                    print("Unknown App: \(key)")
                }
            }
        }
        
        return json
    }
}
