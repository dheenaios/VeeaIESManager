//
//  PhysicalPortsCellModel.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 29/01/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit

class PortConfigCellViewModel {
    let index: Int
    var nodePorts: PortConfigModel
    var meshPorts: PortConfigModel
    private var portRoles: PhysicalPortRoles
    private var netPortRoles: PhysicalPortRoles?
    var portStatus: PortStatusModel
    var portInfo: NodePortInfoModel
    
    var originalNodePorts: PortConfigModel
    var originalMeshPorts: PortConfigModel
    var hubIsSelected: Bool = false { // To maintain settings across dequeues. Network is the default
        didSet {
            if hubIsSelected {
                /*
                 VHM-1133
                 
                 From Danny...
                 
                 "you can enable the hub's inuse but the mesh inuse doesn't change) -
                 I'm assuming the hubs work this out internally if the hubs inuse is active then
                 it'll take precendence over the mesh even if the mesh's inuse is active.
                 So for the final solution when I switch between the hub and mesh I only disable inuse for hub"
                 
                 So we do not set meshAp Config to false.
                 Similar with AP
                 
                 */
                nodePorts.use = true
            }
            else { // its network
                meshPorts.use = true
                nodePorts.use = false
            }
        }
    }
    
    var portNeverUsed: Bool = false
    
    init(nodePorts: PortConfigModel,
         meshPorts: PortConfigModel,
         portRoles: PhysicalPortRoles,
         netPortRoles: PhysicalPortRoles?,
         portStatus: PortStatusModel,
         portInfo: NodePortInfoModel,
         index: Int) {
        self.index = index
        self.nodePorts = nodePorts
        self.meshPorts = meshPorts
        self.portRoles = portRoles
        self.netPortRoles = netPortRoles
        self.portStatus = portStatus
        self.portInfo = portInfo
        
        self.originalNodePorts = nodePorts
        self.originalMeshPorts = meshPorts
        
        setInitiallySelectedNodeMeshOption()
    }
    
    /// Port roles / net port roles depending on hub type / mode
    var portRolesForSelection: PhysicalPortRoles {
        
        // Return port roles if we dont have net port roles
        guard let netPortRoles = netPortRoles else {
            return portRoles
        }
        
        // If is men and network is selected
        if !HubDataModel.shared.isMN && !hubIsSelected {
            return netPortRoles
        }
        
        return portRoles
    }
    
    var currentlySelectedConfig: PortConfigModel {
        if hubIsSelected {
            return nodePorts
        }
        
        return meshPorts
    }
    
    var currentlySelectedConfigHasChanged: Bool {
        if hubIsSelected { return hubHasChanged }
            return meshHasChanged
    }
    
    var hubHasChanged: Bool {
        return nodePorts != originalNodePorts
    }
    
    var meshHasChanged: Bool {
        // Here, we also have to check if Hub's use, because we are only manipulating hub's use
        if originalNodePorts.use != nodePorts.use {
            return true
        }
        return meshPorts != originalMeshPorts
    }
    
    var canSetNetworkConfiguration: Bool {
        if HubDataModel.shared.isMN && meshPorts.isEmpty {
            return false
        }
        
        return true
    }
    
    var showResetButton: Bool {
        if nodePorts.reset_trigger == nil { return false }
        
        if let inUse = portStatus.is_used {
            return inUse && !portStatus.operational
        }
        
        return false
    }
    
    private func setInitiallySelectedNodeMeshOption() {
        // TODO: Set along the lines of the  color rules
        
        let nodeUse = nodePorts.use
        let meshUse = meshPorts.use
        
        if !nodeUse && !meshUse  {
            hubIsSelected = false
            return
        }
        
        if !nodeUse && meshUse  {
            hubIsSelected = false
        }
        else if nodeUse && !meshUse  {
            hubIsSelected = true
        }
        else if nodeUse && meshUse  {
            hubIsSelected = true
        }
    }
}

// MARK: - Type and Link states
extension PortConfigCellViewModel {
    
    var showTypeAndLink: Bool {
        guard portStatus.link_state != nil,
              portInfo.device_type != nil else {
            return false
        }
        
        return true
    }
    
    var typeString: String {
        portInfo.device_type ?? "None"
    }
    
    var linkColor: UIColor {
        guard let link = portStatus.link_state else {
            return .lightGray
        }
        
        return link == "up" ? .dashboardIndicatorGreen : .lightGray
    }
}

// MARK: - Ports status
extension PortConfigCellViewModel {
    func getState() -> PortStatusBarConfig {
        var selectedConfig = nodePorts
        let isOperational = portStatus.operational
        
        if !hubIsSelected {
            selectedConfig = meshPorts
        }
        
        let nodeUse = nodePorts.use
        let meshUse = meshPorts.use
        let currentIsEnabled = !selectedConfig.locked
        
        // Initial values
        var status = PortStatusBarConfig(state: .inactive)
        
        // Are they in use
        if !nodeUse && !meshUse  {
            return PortStatusBarConfig.init(state: .inactive)
        }
        
        let currentSelectionIsIncomplete = hubIsSelected ? nodeStateIsIncomplete : meshStateIsIncomplete
        if currentlySelectedConfigHasChanged && currentSelectionIsIncomplete {
            status = PortStatusBarConfig(state: .editingNotValid)
        }
        else if currentlySelectedConfig.use && !currentIsEnabled {
            status = PortStatusBarConfig(state: .disabled)
        }
        else if isOperational && !currentlySelectedConfigHasChanged && currentlySelectedConfig.use {
            status = PortStatusBarConfig(state: .active)
        }
        
        else if !isOperational && !currentlySelectedConfigHasChanged && portNeverUsed {
            status = PortStatusBarConfig(state: .neverUsed)
        }
        
        else if !isOperational && !currentlySelectedConfigHasChanged {
            status = PortStatusBarConfig(state: .notOperational)
        }
        else if currentlySelectedConfigHasChanged {
            status = PortStatusBarConfig(state: .editingValid)
        }

        return status
    }
    
    var nodeStateIsIncomplete: Bool {
        if self.nodePorts.role == .UNUSED && !nodePorts.mesh {
            return true
        }
        
        return false
    }
    
    var meshStateIsIncomplete: Bool {
        if self.meshPorts.role == .UNUSED && !meshPorts.mesh {
            return true
        }
        
        return false
    }
}
