//
//  PhysicalPortsConfigsViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

class PortsConfigsViewModel: BaseConfigViewModel {
    private var nodePortConfig = HubDataModel.shared.optionalAppDetails!.nodePortConfig
    private var meshPortConfig = HubDataModel.shared.optionalAppDetails!.meshPortConfig
    private var nodePortStatusConfig = HubDataModel.shared.optionalAppDetails!.nodePortStatusConfig
    private var portRoles = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.ethernetPortRoles
    private var nodePortInfo = HubDataModel.shared.baseDataModel?.nodePortInfo
    private var netPortRoles = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.netPortRoles
    
    var roleStringsForSelectedConfiguration: [String] {
        guard let roles = selectedPortConfigModel?.portRolesForSelection else { return ["None".localized()] }
        var roleStrings = roles.roles.map { $0.rawValue.uppercased() }
        roleStrings.append("None".localized())
        
        return roleStrings
    }
    
    var portDetails: [PortsPickerView.PortDetail] {
        var portDetails = [PortsPickerView.PortDetail]()
        for model in physicalPortCellModels {
            
            let name = ""
            let portDetail = PortsPickerView.PortDetail(portNumber: model.index,
                                                        portState: model.getState(),
                                                        portName: name)
            portDetails.append(portDetail)
        }
        
        return portDetails
    }
    
    var selectedPortConfigModel: PortConfigCellViewModel?
    
    lazy var physicalPortCellModels: [PortConfigCellViewModel] = {
        var models = [PortConfigCellViewModel]()
        let ports = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.numberOfEthernetPortsAvailable ?? 0
        
        for i in 0..<ports {
            if let roles = portRoles,
               let nodePorts = nodePortConfig?.ports,
               let meshPorts = meshPortConfig?.ports,
               let nodePortStatusModels = nodePortStatusModels,
               let portInfo = nodePortInfo?.ports[i] {
                
                if netPortRoles == nil {
                    let model = PortConfigCellViewModel.init(nodePorts: nodePorts[i],
                                                             meshPorts: meshPorts[i],
                                                             portRoles: roles[i],
                                                             netPortRoles: nil,
                                                             portStatus: nodePortStatusModels[i],
                                                             portInfo: portInfo,
                                                             index: i)
                    // VHM-1173 / VHM 1207
                    if let isUsed = nodePortStatusModels[i].is_used {
                        model.portNeverUsed = !isUsed
                    }
                    
                    models.append(model)
                }
                else {
                    let model = PortConfigCellViewModel.init(nodePorts: nodePorts[i],
                                                             meshPorts: meshPorts[i],
                                                             portRoles: roles[i],
                                                             netPortRoles: netPortRoles![i],
                                                             portStatus: nodePortStatusModels[i],
                                                             portInfo: portInfo,
                                                             index: i)
                    
                    // VHM-1173 / VHM 1207
                    if let isUsed = nodePortStatusModels[i].is_used {
                        model.portNeverUsed = !isUsed
                    }
                    
                    models.append(model)
                }
            }
        }
        
        return models
    }()
    
    
    var nodePortStatusModels: [PortStatusModel]? {
        return nodePortStatusConfig?.ports
    }
    
    func hasConfigChanged() -> Bool {
        for model in physicalPortCellModels {
            if model.hubHasChanged || model.meshHasChanged {
                return true
            }
        }
        
        return false
    }
    
    func applyUpdate(completion: @escaping CompletionDelegate) {
        guard let h = connectedHub else {
            return
        }
        
        updateNodeAndMeshConfigs()
        
        ApiFactory.api.setConfig(connection: h, config: nodePortConfig!) { (result, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            
            if !self.isMN {
                // VHM-75. Add delay here to see if that helps the problem
                let delay = DispatchTime.now() + .milliseconds(500)
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    ApiFactory.api.setConfig(connection: h, config: self.meshPortConfig!) { (result, error) in
                        completion(nil, error)
                    }
                }
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    // Update the configs with the changes from the cell data models
    private func updateNodeAndMeshConfigs() {
        for (index, model) in physicalPortCellModels.enumerated() {
            switch index {
            case 0:
                nodePortConfig?.port_1 = model.nodePorts
                meshPortConfig?.port_1 = model.meshPorts
                break
            case 1:
                nodePortConfig?.port_2 = model.nodePorts
                meshPortConfig?.port_2 = model.meshPorts
                break
            case 2:
                nodePortConfig?.port_3 = model.nodePorts
                meshPortConfig?.port_3 = model.meshPorts
                break
            case 3:
                nodePortConfig?.port_4 = model.nodePorts
                meshPortConfig?.port_4 = model.meshPorts
                break
            default:
                Logger.log(tag: "PhysicalPortsConfigsViewModel", message: "Unexpected number of physicalPortCellModels")
            }
        }
    }
}

// MARK: - Show Hide
extension PortsConfigsViewModel {
    var hideMeshSwitch: Bool {
        guard let enabled = HubDataModel
                .shared.baseDataModel?
                .nodeCapabilitiesConfig?
                .supportsWiredMesh else {
                    return false
                }
        
        return !enabled
    }
    
    var hideTypeAndLink: Bool {
        guard let show = selectedPortConfigModel?.showTypeAndLink else { return true }
        return !show
    }
    
    var hideResetButton: Bool {
        guard let show = selectedPortConfigModel?.showResetButton else { return true }
        return !show
    }
}

// MARK: - Validation
extension PortsConfigsViewModel {
    
    
    /// Are there any issue with the current port settings
    /// - Returns: Optional is nil if no errors. First is title, second is message
    func settingErrors() -> (String, String)?  {
        for (index, model) in physicalPortCellModels.enumerated() {
            let portNumber = index + 1
            let message = "Some details you have entered are not valid. Please correct and try again.".localized()
            
            if model.nodeStateIsIncomplete {
                let name = model.nodePorts.name
                return ("Port \(portNumber) \(name)", message)
            }
            if model.meshStateIsIncomplete {
                let name = model.meshPorts.name
                return ("Port \(portNumber) \(name)", message)
            }
        }
        
        return nil
    }
}
