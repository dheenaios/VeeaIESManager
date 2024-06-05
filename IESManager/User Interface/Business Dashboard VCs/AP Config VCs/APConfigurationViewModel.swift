//
//  APConfigurationViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 14/02/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit


class APConfigurationViewModel: BaseConfigViewModel {
    
    public var selectedAP: SelectedAP = .AP1
    public var selectedOperation: SelectedOperation = .Start
    private var originalNodeConfig: AccessPointsConfig?
    private var originalMeshConfig: AccessPointsConfig?
    
    private var workingNodeConfig: AccessPointsConfig?
    private var workingMeshConfig: AccessPointsConfig?
    
    public var tableViewModels: [APConfigurationCellModel]?
    private var workingNodeCapabilitiesConfig: NodeCapabilities?
    
    public var titleText: String {
        get {
            let freq = selectedAP == .AP1 ? "2.4Ghz" : "5Ghz"
            return "\(freq) \("Configuration".localized())"
        }
    }
    
    public var headerImage: UIImage {
        get {
            return #imageLiteral(resourceName: "dash_icon_wifi")
        }
    }
    
    init(freq: SelectedAP) {
        self.originalNodeConfig = HubDataModel.shared.baseDataModel?.nodeAPConfig
        self.originalNodeConfig?.accessPointType = .NODE
        self.originalMeshConfig = HubDataModel.shared.baseDataModel?.meshAPConfig
        originalMeshConfig?.accessPointType = .MESH
        
        self.selectedAP = freq
        
        super.init()
        self.createTableViewModels()
    }
    
    public var ssidsAndPasswordsAreValid: (SuccessAndOptionalMessage) {
        guard let tableViewModels = tableViewModels else {
            return (false, "Data was missing")
        }

        let validationResult = validateConfigs(configs: tableViewModels)
        if !validationResult.0 { return validationResult }

        return (true, nil)
    }
    
    private func validateConfigs(configs: [APConfigurationCellModel]) -> (SuccessAndOptionalMessage) {
        for ap in configs {
            let result = APConfigurationViewModel.validateConfiguration(config: ap)
            let valid = result.0
            
            if !valid {
                return (false, result.1)
            }
        }
        
        return (true, nil)
    }
    
    static func validateConfiguration(config: APConfigurationCellModel) -> (SuccessAndOptionalMessage) {
        if !config.nodeChanged && !config.meshChanged {
            return(true, nil)
        }
        
        if config.nodeApConfig.system_only && config.meshApConfig.system_only {
            return(true, nil)
        }
        
        // If Network SSID is enabled and configured properly (validate all the entries for Network and mesh's Use=true)
        // then we should make node's Use = true even its blank. Status of the Hub’s SSID is change from “Not use” to “Disabled”.
        if config.hubIsSelected && config.meshApConfig.enabled && config.meshProperlyConfigured && config.meshApConfig.use {
            if config.nodeApConfig.isBlank {
                return (true, nil)
            }
        }
        
        // Hub is selected
        if !config.nodeApConfig.use && !config.meshApConfig.use {
            if (config.nodeApConfig.enabled || config.nodeApConfig.hidden) && config.nodeApConfig.isEmpty {
                /*
                ii) Configure Network SSID properly and then switch back to Hub
                If Network SSID is enabled and configured properly (validate all the
                entries for Network and mesh's Use=true) then we should make node's Use = true even its
                blank. Status of the Hub's SSID is change from "Not use" to "Disabled".
                (Nick's case If user wants to disable MEN's Network SSID without disrupt the connected MNs
                Network wide connection Nick has reviewed this and agreed this is the correct rule)
                 */
                if (config.meshApConfig.ssidIsValid && config.meshApConfig.enabled) && config.nodeApConfig.isEmpty {
                    return (true, nil)
                }
                
                
                return (false, "Hub AP configuration incomplete".localized())
            }
            if (config.meshApConfig.enabled || config.meshApConfig.hidden) && config.meshApConfig.isEmpty {
                return (false, "Mesh AP configuration incomplete".localized())
            }
        }
        
        let selectedAp = config.hubIsSelected ? config.nodeApConfig : config.meshApConfig
        
        let ssid = selectedAp.ssid
        let pass = selectedAp.pass
        
        if selectedAp.system_only {
            return(true, nil)
        }
        
        if ssid.isEmpty {
            if selectedAp.enabled {
                return (false, "One of your enabled APs has no SSID name".localized())
            }
        }
        else {
            let result = SSIDNamePasswordValidation.ssidNameValid(str: ssid)
            if !result.0 {
                return result
            }
        }
        
        if let mode = selectedAp.secureMode {
            if mode == .preSharedPsk {
                
                // User selects the Hub and then only configure the SSID name, but other required fields are blank and enable = false. (Show disable as status)
                //- Should we allow the user to apply those changes? If yes, then if the user changes the database with an invalid entry (maybe special characters and SSID's name is too long or password too short, etc.) is it ok for the platform? (Nick confirms this is correct)
                if pass.isEmpty {
                    return (true, nil)
                }
                
                let validation = SSIDNamePasswordValidation.passwordValid(passString: pass, ssid: ssid)
                
                // If the password is empty OR the password is invalid
                if pass.isEmpty || !validation.0 {
                    return validation
                }
            }
        }
        
        return (true, nil)
    }
    
    public func enterpriseSecuritySettingsAreValid() -> (SuccessAndOptionalMessage) {
        let accessPoints = visibleNodeWorkingModels()
        let nodeAps = accessPoints.0
        let meshAps = accessPoints.1
    
        let nodeValid = validateEnterpriseAps(configs: nodeAps)
        let meshValid = validateEnterpriseAps(configs: meshAps)

        if !nodeValid.0 { return nodeValid }
        if !meshValid.0 { return meshValid }
        
        return (true, nil)
    }
    
    private func validateEnterpriseAps(configs: [AccessPointConfig]) -> (SuccessAndOptionalMessage) {
        for ap in configs {
            if ap.system_only { continue }
            if let mode = ap.secureMode {
                if mode == .enterprise {
                    let isMN = HubDataModel.shared.isMN
                    let mnWarning = isMN ? "\n(Radius servers can only be configured on the Management Hub)".localized() : ""
                    
                    if ap.radius1_auth_id == 0 && ap.radius2_auth_id == 0 {
                        if ap.ssid.isEmpty {
                            return(false, "\("Radius Auth Server not set for AP using Enterprise Security".localized())\(mnWarning)")
                        }
                        else {
                            return(false, "\("Radius Auth Server not set for".localized()) \(ap.ssid)\(mnWarning)")
                        }
                    }
                }
            }
        }
        
        return (true, nil)
    }
    
    /// Some of the system AP SSIDs do not confirm to the SSID naming roles.
    /// So we only want the user editable items
    /// - Returns: A tuple. The first is node. The second is mesh
    private func visibleNodeWorkingModels() -> ([AccessPointConfig], [AccessPointConfig]) {
        var visibleNodeApConfigs = [AccessPointConfig]()
        var visibleMeshApConfigs = [AccessPointConfig]()
        
        guard let nodeApConfig = workingNodeApsForSelectedFreq,
              let meshApConfig = workingMeshApsForSelectedFreq else {
            return (visibleNodeApConfigs, visibleMeshApConfigs)
        }

        for (index, nodeAp) in nodeApConfig.enumerated() {
            guard let node = selectedAP == .AP1 ? originalNodeConfig?.allAP1s[index] : originalNodeConfig?.allAP2s[index],
                  let mesh = selectedAP == .AP1 ? originalMeshConfig?.allAP1s[index] : originalMeshConfig?.allAP2s[index] else {
                return (visibleNodeApConfigs, visibleMeshApConfigs)
            }
            
            if node.systemOnlyAndInUse || mesh.systemOnlyAndInUse {} // System AP
            else {
                visibleNodeApConfigs.append(nodeAp)
                visibleMeshApConfigs.append(meshApConfig[index])
            }
        }
        
        // There are 6 aps. Only 4 should be shown. AP1 is the system AP
        // If there are more than 4 at this state we should delete the last
        while visibleNodeApConfigs.count > 4 {
            visibleNodeApConfigs.removeLast()
        }
        
        while visibleMeshApConfigs.count > 4 {
            visibleMeshApConfigs.removeLast()
        }
        
        return (visibleNodeApConfigs, visibleMeshApConfigs)
    }
    
    public var hasSsidOrPasswordChanged: Bool {
        updateModels()
        
        guard let originalNodeAps = originalNodeApsForSelectedFreq,
              let originalMashAps = originalMeshApsForSelectedFreq,
              let workingNodeAps = workingNodeApsForSelectedFreq,
              let workingMeshAps = workingMeshApsForSelectedFreq else {
            return false
        }
        
        for (index, ap) in originalNodeAps.enumerated() {
            let workingAp = workingNodeAps[index]
            
            if workingAp.ssid != ap.ssid || workingAp.pass != ap.pass {
                return true
            }
        }
        
        for (index, ap) in originalMashAps.enumerated() {
            let workingAp = workingMeshAps[index]
            
            if workingAp.ssid != ap.ssid || workingAp.pass != ap.pass {
                return true
            }
        }
        
        return false
    }
    
    public var isDataModelUpdated: Bool {
        if nodeApChanged || meshApChanged {
            return true
        }

        return false
    }
}

// MARK: - Computed model getters
extension APConfigurationViewModel {
    public var nodeApChanged: Bool {
        return originalNodeConfig != nodeAccessPointConfig
    }
    
    public var meshApChanged: Bool {
        return originalMeshConfig != meshAccessPointConfig
    }
    
    /// The working version of the node access point
    public var nodeAccessPointConfig: AccessPointsConfig? {
        updateModels()
        
        return workingNodeConfig
    }
    
    /// The working version of the mesh access point
    public var meshAccessPointConfig: AccessPointsConfig? {
        updateModels()
        
        return workingMeshConfig
    }
    
    private var workingNodeApsForSelectedFreq: [AccessPointConfig]? {
        var aps = nodeAccessPointConfig?.allAP1s
        if selectedAP == .AP2 {
            aps = nodeAccessPointConfig?.allAP2s
        }
        
        return aps
    }
    
    private var workingMeshApsForSelectedFreq: [AccessPointConfig]? {
        var aps = meshAccessPointConfig?.allAP1s
        if selectedAP == .AP2 {
            aps = meshAccessPointConfig?.allAP2s
        }
        
        return aps
    }
    
    private var originalNodeApsForSelectedFreq: [AccessPointConfig]? {
        var aps = originalNodeConfig?.allAP1s
        if selectedAP == .AP2 {
            aps = originalNodeConfig?.allAP2s
        }
        
        return aps
    }
    
    private var originalMeshApsForSelectedFreq: [AccessPointConfig]? {
        var aps = originalMeshConfig?.allAP1s
        if selectedAP == .AP2 {
            aps = originalMeshConfig?.allAP2s
        }
        
        return aps
    }
    
    var operationOptionOfWIFI: SelectedOperation {
       guard let nodeConfig = HubDataModel.shared.baseDataModel?.nodeConfig else {
           return .Start
       }
        if selectedAP == .AP1 {
            if nodeConfig.access1_local_control?.lowercased() == "locked" {
               return .Disabled
           }
        }else{
            if nodeConfig.access2_local_control?.lowercased() == "locked" {
               return .Disabled
           }
        }
        return .Start
   }
}

// MARK: - Updating
extension APConfigurationViewModel {
    private func updateModels() {
        guard tableViewModels != nil else {
            return
        }
        
        // Create a copy of the original config struct
        workingNodeConfig = originalNodeConfig
        workingMeshConfig = originalMeshConfig
        
        // Set the working copies AP configs to the new values
        for configModel in tableViewModels! {
            if selectedAP == .AP1 {
                updateAP1(model: configModel)
            }
            else if selectedAP == .AP2 {
                updateAP2(model: configModel)
            }
        }
    }
    
    private func updateAP1(model: APConfigurationCellModel) {
        switch model.index {
        case 0:
            workingNodeConfig?.ap_1_1 = model.nodeApConfig
            workingMeshConfig?.ap_1_1 = model.meshApConfig
        case 1:
            workingNodeConfig?.ap_1_2 = model.nodeApConfig
            workingMeshConfig?.ap_1_2 = model.meshApConfig
        case 2:
            workingNodeConfig?.ap_1_3 = model.nodeApConfig
            workingMeshConfig?.ap_1_3 = model.meshApConfig
        case 3:
            workingNodeConfig?.ap_1_4 = model.nodeApConfig
            workingMeshConfig?.ap_1_4 = model.meshApConfig
        case 4:
            workingNodeConfig?.ap_1_5 = model.nodeApConfig
            workingMeshConfig?.ap_1_5 = model.meshApConfig
        case 5:
            workingNodeConfig?.ap_1_6 = model.nodeApConfig
            workingMeshConfig?.ap_1_6 = model.meshApConfig
        default:
            break
            //print("Error. Bad model index. AP1")
        }
    }
    
    private func updateAP2(model: APConfigurationCellModel) {
        switch model.index {
        case 0:
            workingNodeConfig?.ap_2_1 = model.nodeApConfig
            workingMeshConfig?.ap_2_1 = model.meshApConfig
        case 1:
            workingNodeConfig?.ap_2_2 = model.nodeApConfig
            workingMeshConfig?.ap_2_2 = model.meshApConfig
        case 2:
            workingNodeConfig?.ap_2_3 = model.nodeApConfig
            workingMeshConfig?.ap_2_3 = model.meshApConfig
        case 3:
            workingNodeConfig?.ap_2_4 = model.nodeApConfig
            workingMeshConfig?.ap_2_4 = model.meshApConfig
        case 4:
            workingNodeConfig?.ap_2_5 = model.nodeApConfig
            workingMeshConfig?.ap_2_5 = model.meshApConfig
        case 5:
            workingNodeConfig?.ap_2_6 = model.nodeApConfig
            workingMeshConfig?.ap_2_6 = model.meshApConfig
        default:
            break
            //print("Error. Bad model index. AP2")
        }
    }
}

// MARK: - Table View Model Population
extension APConfigurationViewModel {
    private func createTableViewModels() {
        guard let nodeConfig = originalNodeConfig,
              let meshConfig = originalMeshConfig,
              let nodeApStatus = HubDataModel.shared.baseDataModel?.nodeApStatus else {
            return
        }
        
        // Create a model for each ap
        var nodeAps = nodeConfig.allAP1s
        var meshAps = meshConfig.allAP1s
        var apStats = nodeApStatus.allAP1s
        if selectedAP == .AP2 {
            nodeAps = nodeConfig.allAP2s
            meshAps = meshConfig.allAP2s
            apStats = nodeApStatus.allAP2s
        }
        
        var models = [APConfigurationCellModel]()
        for (index, nodeAp) in nodeAps.enumerated() {
            let meshAp = meshAps[index]
            let apStatus = apStats[index]
            
            let model = APConfigurationCellModel(nodeApConfig: nodeAp,
                                                 meshApConfig: meshAp,
                                                 nodeApStatus: apStatus,
                                                 index: index)
            models.append(model)
        }

        trimModels(models: models)
    }
    
    private func trimModels(models: [APConfigurationCellModel]) {
        var userAps = [APConfigurationCellModel]()
        
        for (index, model) in models.enumerated() {
            if let node = selectedAP == .AP1 ? HubDataModel.shared.baseDataModel?.nodeAPConfig?.allAP1s[index] :
                    HubDataModel.shared.baseDataModel?.nodeAPConfig?.allAP2s[index],
                  let mesh = selectedAP == .AP1 ? HubDataModel.shared.baseDataModel?.meshAPConfig?.allAP1s[index] :
            HubDataModel.shared.baseDataModel?.meshAPConfig?.allAP2s[index] {
                if node.systemOnlyAndInUse || mesh.systemOnlyAndInUse {} // System AP
                else {
                    userAps.append(model)
                }
            }
        }
        
        // There are 6 aps. Only 4 should be shown. AP1 is the system AP
        // If we are using a VH05 then there should be 3 user configurable SSID (VHM-323)
        // If we are using any other devices then there should be 4
        let ssidCount = HubDataModel.shared.hardwareVersion.numberOfUserConfigurableSsids
        
        while userAps.count > ssidCount {
            userAps.removeLast()
        }
        
        tableViewModels = userAps
    }
}
