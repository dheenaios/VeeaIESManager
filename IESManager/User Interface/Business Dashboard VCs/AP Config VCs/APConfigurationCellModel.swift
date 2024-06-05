//
//  APConfigurationCellModel.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 28/01/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

class APConfigurationCellModel {
    let index: Int
    var nodeApConfig: AccessPointConfig
    var meshApConfig: AccessPointConfig
    var nodeApStatus: NodeApStatusApX_X
    var meshEditable: Bool
    
    var hubIsSelected: Bool = false // To maintain settings across dequeues. Network is the default
    
    /// A **COPY** of the currently in use config
    var currentConfig: AccessPointConfig {
        return hubIsSelected ? nodeApConfig : meshApConfig
    }
    
    /// Has the user changed anything
    var nodeChanged: Bool {
        return nodeApConfig != originalNodeApConfig
    }
    
    var meshChanged: Bool {
        return meshApConfig != originalMeshApConfig
    }
    
    var nodeProperlyConfigured: Bool {
        return nodeApConfig.configIsValid
    }
    
    var meshProperlyConfigured: Bool {
        return meshApConfig.configIsValid
    }
    
    var clientIsolationAvailable: Bool {
        guard let nodeCaps = HubDataModel
            .shared
            .baseDataModel?
            .nodeCapabilitiesConfig else {
            return false
        }
        
        return nodeCaps.isLanIdEditableOnAP
    }
    
    var canSetNetworkConfiguration: Bool {
        if HubDataModel.shared.isMN && meshApConfig.isEmpty {
            return false
        }
        
        return true
    }
    
    var showClientIsolationOptions: Bool {
        guard let nodeCaps = HubDataModel
            .shared
            .baseDataModel?
            .nodeCapabilitiesConfig else {
            return false
        }
        
        return nodeCaps.showClientIsolationOptions
    }
    
    // Original Settings
    var originalNodeApConfig: AccessPointConfig
    var originalMeshApConfig: AccessPointConfig
    
    
    init(nodeApConfig: AccessPointConfig,
         meshApConfig: AccessPointConfig,
         nodeApStatus: NodeApStatusApX_X,
         index: Int) {
        self.index = index
        self.originalNodeApConfig = nodeApConfig
        self.originalMeshApConfig = meshApConfig
        
        self.nodeApConfig = nodeApConfig
        self.meshApConfig = meshApConfig
        self.nodeApStatus = nodeApStatus
        self.meshEditable = true
        
        // Only active if MEN
        meshEditable = !HubDataModel.shared.isMN
        setInitiallySelectedNodeMeshOption()
    }
    
    private func setInitiallySelectedNodeMeshOption() {
        hubIsSelected = (HubDataModel.shared.isMN && !meshApConfig.use) || nodeApConfig.use
    }
    
    var ssidIsValid: Bool {
        // Check the ssid is the correct length
        if !(currentSsidName.isEmpty) {
            let ssidValidationResult = SSIDNamePasswordValidation.ssidNameValid(str: currentSsidName)
            if !ssidValidationResult.0 { return false }
        }
        else {
            return false
        }
        
        let config = hubIsSelected ? nodeApConfig : meshApConfig
        if let mode = config.secureMode {
            switch mode {
            case .open:
                return true
            case .preSharedPsk:
                // Check the pass code is valid
                return config.pskIsValid
            case .enterprise:
                // Check a radius server has been set
                return config.radiusAuthSet
            }
        }
        
        return true
    }
    
    var statusBarConfig: ApStatusBarConfig {
        
        // Variables used
        let nodeInUse = nodeApConfig.use
        let meshInUse = meshApConfig.use
        let nodeIsEnabled = nodeApConfig.enabled
        let meshIsEnabled = meshApConfig.enabled
        let opStatus = nodeApStatus.opstate
        let isValid = ssidIsValid
        
        let currentyDisplayedSsidIsInUse = hubIsSelected ? nodeInUse : meshInUse
        let currentyDisplayedSsidIsEnabled = hubIsSelected ? nodeIsEnabled : meshIsEnabled
        let currentyDisplayedSsidIsEmpty = hubIsSelected ? nodeApConfig.isEmpty : meshApConfig.isEmpty
        let hasChanged = hubIsSelected ? nodeChanged : meshChanged
        
        let state = ApStatusBarConfig(state: .notConfigured)
        
        return calculateStatusBarConfig(meshIsEnabled: meshIsEnabled,
                                        meshInUse: meshInUse,
                                        state: state,
                                        currentlyDisplayedSsidIsInUse: currentyDisplayedSsidIsInUse,
                                        currentlyDisplayedSsidIsEnabled: currentyDisplayedSsidIsEnabled,
                                        currentlyDisplayedSsidIsEmpty: currentyDisplayedSsidIsEmpty,
                                        hasChanged: hasChanged,
                                        opStatus: opStatus,
                                        isValid: isValid)
    }
    
    func calculateStatusBarConfig(meshIsEnabled: Bool,
                                  meshInUse: Bool,
                                  state: ApStatusBarConfig,
                                  currentlyDisplayedSsidIsInUse currentyDisplayedSsidIsInUse: Bool,
                                  currentlyDisplayedSsidIsEnabled currentyDisplayedSsidIsEnabled: Bool,
                                  currentlyDisplayedSsidIsEmpty currentyDisplayedSsidIsEmpty: Bool,
                                  hasChanged: Bool,
                                  opStatus: Bool,
                                  isValid: Bool) -> ApStatusBarConfig {
        // If Network SSID is enabled and configured properly (validate all the entries for Network and mesh's Use=true)
        // then we should make node's Use = true even its blank. Status of the Hub’s SSID is change from “Not use” to “Disabled”.
        
        // 1.
        if hubIsSelected && meshIsEnabled && meshProperlyConfigured && meshInUse {
            if nodeApConfig.isBlank {
                state.setUp(state: .useButNotEnabled)
                return state
            }
        }
        
        // 2.
        if currentyDisplayedSsidIsInUse && !currentyDisplayedSsidIsEnabled && currentyDisplayedSsidIsEmpty {
            return ApStatusBarConfig(state: .notConfigured)
        }
        
        // 3.
        else if !hasAssociatedLan {
            state.setUp(state: .useButNotEnabled)
        }
        
        // 4.
        else if !hasChanged && currentyDisplayedSsidIsInUse && !currentyDisplayedSsidIsEnabled {
            state.setUp(state: .useButNotEnabled)
        }
        
        // 5.
        else if !hasChanged && currentyDisplayedSsidIsInUse && !opStatus {
            state.setUp(state: .notOperational)
        }
        
        // 6.
        else if !hasChanged && currentyDisplayedSsidIsInUse && opStatus {
            state.setUp(state: .operational)
        }
        
        // 7.
        else if hasChanged && !isValid {
            if currentyDisplayedSsidIsEnabled {
                state.setUp(state: .editingNotValid)
            }
            else {
                state.setUp(state: .useButNotEnabled)
            }
        }
        
        // 8.
        else if hasChanged && isValid {
            state.setUp(state: .editingValid)
        }
        
        // VHM-1503. If current has been cleared then show valid.
        if hasChanged && hasBeenCleared {
            state.setUp(state: .editingValid)
        }
        
        return state
    }
}

/// Get and Set
extension APConfigurationCellModel {
    
    var currentSsidName: String {
        get {
            if hubIsSelected { return nodeApConfig.ssid }
            else { return meshApConfig.ssid }
        }
        set {
            if hubIsSelected { nodeApConfig.ssid = newValue }
            else { meshApConfig.ssid = newValue }
        }
    }
    
    var currentPassword: String {
        get {
            if hubIsSelected { return nodeApConfig.pass }
            else { return meshApConfig.pass }
        }
        set {
            if hubIsSelected { nodeApConfig.pass = newValue }
            else { meshApConfig.pass = newValue }
        }
    }
    
    var currentIsOn: Bool {
        get {
            return hubIsSelected ? !nodeApConfig.locked : !meshApConfig.locked
        }
        set {
            if hubIsSelected { nodeApConfig.locked = !newValue }
            else { meshApConfig.locked = !newValue }
        }
    }
    
    var currentInUse: Bool {
        get {
            return hubIsSelected ? nodeApConfig.use : meshApConfig.use
        }
        set {
            if hubIsSelected { nodeApConfig.use = newValue }
            else { meshApConfig.use = newValue }
        }
    }
    var currentInEnable: Bool {
        get {
            return hubIsSelected ? nodeApConfig.enabled : meshApConfig.enabled
            
        }
        set {
            if hubIsSelected { nodeApConfig.enabled = newValue }
            else { meshApConfig.enabled = newValue }
        }
    }
    
    var currentIsHidden: Bool {
        get {
            return hubIsSelected ? nodeApConfig.hidden : meshApConfig.hidden
            
        }
        set {
            if hubIsSelected { nodeApConfig.hidden = newValue }
            else { meshApConfig.hidden = newValue }
        }
    }
    
    var currentLanId: Int {
        get {
            return hubIsSelected ? nodeApConfig.lan_id : meshApConfig.lan_id
        }
        set {
            if hubIsSelected { nodeApConfig.lan_id = newValue }
            else { meshApConfig.lan_id = newValue }
        }
    }
    
    var hasAssociatedLan: Bool {
        // VHM 1670 - show AP entries as if administratively locked if enabled but there is no associated LAN
        currentLanId != 0
    }
    
    var currentSecureMode: AccessPointConfig.SecureMode? {
        get {
            return hubIsSelected ? nodeApConfig.secureMode : meshApConfig.secureMode
        }
        set {
            if hubIsSelected {
                nodeApConfig.secureMode = newValue
            }
            else {
                meshApConfig.secureMode = newValue
            }
        }
    }
    
    var legacyCellPasswordFieldPassword: String {
        get {
            return hubIsSelected ? nodeApConfig.pass : meshApConfig.pass
        }
        set {
            if hubIsSelected { nodeApConfig.pass = newValue }
            else { meshApConfig.pass = newValue }
        }
    }
}

// Clear Configuration
extension APConfigurationCellModel {
    
    func clearConfiguration() {
        currentSsidName = ""
        currentPassword = ""
        currentInUse = false
        currentInEnable = false
        currentIsHidden = false
    }
    
    var hasBeenCleared: Bool {
        return currentSsidName == "" &&
        currentPassword == "" &&
        currentInUse == false &&
        currentInEnable == false &&
        currentIsHidden == false
    }
}
