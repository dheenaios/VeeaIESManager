//
//  DashModelUpdater.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 04/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class DashModelUpdater {
    
    var sections = DashLoader().getDashboardModels()
    
    var connectedHub: HubConnectionDefinition? {
        return HubDataModel.shared.connectedVeeaHub
    }
    
    public func getUpdatedModels() -> [DashSectionModel] {
        guard connectedHub != nil else {
            return disabledModels()
        }
        
        sections = DashLoader().getDashboardModels()
        update()
        
        return sections
    }
}

// MARK: - Update with info from the hub
extension DashModelUpdater {
    private func update() {
        for section in sections {
            for model in section.allItemModels {
                updateDashboardModel(model: model)
            }
        }
    }
    
    /// Update items and remove unneeded items
    private func updateDashboardModel(model: DashItemModel) {
        let dm = HubDataModel.shared
        
        if model.itemID == DashboardItemKeys.nodeItem {
            if let config = dm.baseDataModel?.nodeInfoConfig {
                model.subTitle = config.node_name
            }
        }
        if model.itemID == DashboardItemKeys.vMeshItem {
            if !(HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasVmeshCapability ?? false) {
                model.isHidden = true
                return
            }
            
            if let config = dm.baseDataModel?.vmeshConfig {
                model.subTitle = config.vmesh_ssid
            }
        }
        if model.itemID == DashboardItemKeys.iPItem {
            if let config = dm.baseDataModel?.nodeStatusConfig {
                model.subTitle = config.ethernet_ipv4_addr.isEmpty ? "" : config.ethernet_ipv4_addr
            }
        }
        if model.itemID == DashboardItemKeys.beaconItem {
            if let config = dm.baseDataModel?.beaconConfig {
                model.subTitle = config.beacon_sub_domain
            }
        }
        if model.itemID == DashboardItemKeys.cellularStatsItem {
            model.isHidden = !cellularIsAvailable()
        }
        else if model.itemID == DashboardItemKeys.physicalAp1 {
            model.isEnabledForThisHub = physicalAp1IsAvailable()
        }
        else if model.itemID == DashboardItemKeys.physicalAp2 {
            model.isHidden = !physicalAp2IsAvailable()
        }
        else if model.itemID == DashboardItemKeys.wanNode {
            model.isHidden = !wanNodeIsAvailable()
        }
        else if model.itemID == DashboardItemKeys.routerItem {
            model.isHidden = HubDataModel.shared.isMN
        }
        else if model.itemID == DashboardItemKeys.gatewayItem {
            model.isHidden = HubDataModel.shared.isMN
            model.subTitle = dm.baseDataModel?.nodeStatusConfig?.border_gateway_selected ?? "No Gateway".localized()
        }
        else if model.itemID == DashboardItemKeys.physicalPorts {
            if let nodeCap = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig {
                let en = nodeCap.numberOfEthernetPortsAvailable > 0 &&
                !nodeCap.ethernetPortRoles.isEmpty
                
                model.isEnabledForThisHub = en
            }
            else {
                model.isEnabledForThisHub = false
            }
        }
        else if model.itemID == DashboardItemKeys.vlan {
            model.isEnabledForThisHub = true
        }
        
        setIconColorFor(model: model)
    }
    
    private func setIconColorFor(model: DashItemModel) {
        let dm = HubDataModel.shared
        guard let lockStatus = dm.baseDataModel?.lockStatus,
              let nodeStatus = dm.baseDataModel?.nodeStatusConfig else {
                  model.warningIconColor = .NONE
                  
                  return
              }
        
        let modelId = model.itemID
        model.warningIconColor = .NONE
        
        if DashboardItemKeys.nodeItem == modelId {
            if dm.baseDataModel?.nodeStatusConfig?.reboot_required ?? false {
                model.warningIconColor = .RED
            }
            else {
                model.setIconColorFromLockState(isOperational: nodeStatus.node_operational,
                                                locks: [lockStatus.node_locked])
            }
        }
        else if DashboardItemKeys.vMeshItem == modelId {
            model.setIconColorFromLockState(isOperational: nodeStatus.vmesh_operational,
                                            locks: [lockStatus.node_locked])
        }
        else if DashboardItemKeys.beaconItem == modelId {
            model.setIconColorFromLockState(isOperational: nodeStatus.beacon_operational,
                                            locks: [lockStatus.beacon_locked, lockStatus.node_locked])
        }
        else if DashboardItemKeys.gatewayItem == modelId {
            model.warningIconColor = gatewayWarning()
        }
        else if DashboardItemKeys.meshGatewayItem == modelId {
            //            let meshGateway = dm.baseDataModel?.nodeConfig?.meshGatewayServer ?? ""
            //            model.setIconColorFromLockState(isOperational: nodeStatus.mgw_connection_established, locks: [meshGateway.count == 0])
        }
        else if DashboardItemKeys.databaseItem == modelId {
            model.setIconColorFromLockState(isOperational: nodeStatus.database_operational, locks: nil)
        }
        else if DashboardItemKeys.displayItem == modelId {
            model.setIconColorFromLockState(isOperational: nodeStatus.display_operational, locks: nil)
        }
        else if DashboardItemKeys.physicalAp1 == modelId {
            if let operational = HubDataModel.shared.baseDataModel?.nodeStatusConfig?.access_operational {
                model.warningIconColor = operational ? .NONE : .RED
                return
            }
            
            model.warningIconColor = .NONE
        }
        else if DashboardItemKeys.physicalAp2 == modelId {
            if let operational = HubDataModel.shared.baseDataModel?.nodeStatusConfig?.access2_operational {
                model.warningIconColor = operational ? .NONE : .RED
                return
            }
            
            model.warningIconColor = .NONE
        }
        else if DashboardItemKeys.lanConfig == modelId {
            model.warningIconColor = .NONE
        }
        else if DashboardItemKeys.wanNode  == modelId {
            model.warningIconColor = .NONE
        }
        else if DashboardItemKeys.mediaItem == modelId {
            //model.setIconColorFromLockState(isOperational: nodeStatus.media_analytics_operational, locks: [lockStatus.mediaAnalyticsLocked])
            model.isHidden = true
        }
        
        else if DashboardItemKeys.retailItem == modelId {
            //model.setIconColorFromLockState(isOperational: nodeStatus.retail_analytics_operational, locks: [lockStatus.retailAnalyticsLocked])
            model.isHidden = true
        }
        else if DashboardItemKeys.physicalPorts == modelId {
            model.warningIconColor = portWarning()
        }
        else if DashboardItemKeys.vlan  == modelId {
            model.warningIconColor = .NONE
        }
        else if DashboardItemKeys.sdWan  == modelId {
            let enabled = HubDataModel.shared.optionalAppDetails?.sdWanConfig != nil
            model.isHidden = !enabled
        }
    }
}

// MARK: - Warnings
extension DashModelUpdater {
    private func gatewayWarning() -> WarningIconState {
        let stateMananger = BackhaulStateController()
        
        let wifiState = stateMananger.getStateFor(backhaulType: .wifi)
        let ethernetState = stateMananger.getStateFor(backhaulType: .ethernet)
        let cellularState = stateMananger.getStateFor(backhaulType: .cellular)
        
        if wifiState == .nonOperational || ethernetState == .nonOperational || cellularState == .nonOperational {
            return .RED
        }
        
        if wifiState == .operationButLocked || ethernetState == .operationButLocked || cellularState == .operationButLocked {
            return .AMBER
        }
        
        return .NONE
    }
    
    private func portWarning() -> WarningIconState {
        // New way of setting the warning - VHM 1197
        if let operational = HubDataModel.shared.baseDataModel?.nodeStatusConfig?.ports_operational {
            return operational ? .NONE : .RED
        }
        
        // Legacy way of setting the warning
        if let nodeCap = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig {
            if nodeCap.numberOfEthernetPortsAvailable > 0 &&
                !nodeCap.ethernetPortRoles.isEmpty {
                return DashboardItemState.portState
            }
        }
        
        return .NONE
    }
}

// MARK: - Capability enabling
extension DashModelUpdater {
    fileprivate func cellularIsAvailable() -> Bool {
        if !HubDataModel.shared.isDataSetComplete {
            return false
        }
        
        return HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.isCellularAvailable ?? false
    }
    
    fileprivate func physicalAp1IsAvailable() -> Bool {
        if !HubDataModel.shared.isDataSetComplete {
            return false
        }
        
        return HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.isAP1Available ?? false
    }
    
    fileprivate func physicalAp2IsAvailable() -> Bool {
        if !HubDataModel.shared.isDataSetComplete {
            return false
        }
        
        return HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.isAP2Available ?? false
    }
    
    fileprivate func wanNodeIsAvailable() -> Bool {
        return HubDataModel.shared.isMN
    }
}

// MARK: - Disable
extension DashModelUpdater {
    func disabledModels() -> [DashSectionModel] {
        for section in sections {
            disableSection(section: section)
        }
        
        
        return sections
    }
    
    private func disableSection(section: DashSectionModel) {
        for model in section.allItemModels {
            model.isEnabledForThisHub = false
            model.warningIconColor = .NONE
        }
    }
}
