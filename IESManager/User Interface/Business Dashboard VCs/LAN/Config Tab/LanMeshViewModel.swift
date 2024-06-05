//
//  LanMeshViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 05/06/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit


class LanMeshViewModel: BaseConfigViewModel {

    let parentVm: LanConfigurationViewModel

    enum OperationalState {
        case ORANGE(String)
        case RED(String)
        case CLEAR
    }
    
    // The view controller
    public weak var delegate: LanMeshViewController?
    
    private var sendingUpdate: Bool = false

    var wans: [String] { parentVm.nodeWanConfig.wanNames }

    var selectedIpManagementMode: IpManagementMode = .CLIENT {
        didSet {
            updateConfigUponChange()
        }
    }
    
    var allPortRoles: [PhysicalPortRoles]? {
        guard let allRoles = bdm?.nodeCapabilitiesConfig?.ethernetPortRoles else {
            return nil
        }
        
        return allRoles
    }
    
    public var physicalPortsAvailable: Int {
        let ports = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.numberOfEthernetPortsAvailable ?? 0
        return ports
    }
    
    var clientIsolationAvailable: Bool {
        guard let nodeCaps = HubDataModel
                .shared
                .baseDataModel?
                .nodeCapabilitiesConfig else {
            return false
        }
        return nodeCaps.hasClientTrafficFeature
    }
    
    var numberOfPorts: Int {
        return bdm?.nodeCapabilitiesConfig?.numberOfEthernetPortsAvailable ?? 0
    }
    
    func ipv4TextFieldUserEditableFor(lanNumber: Int) -> Bool {
         if let nodeLanStatus = HubDataModel.shared.optionalAppDetails?.nodeLanStatus {
             let lanStatus = nodeLanStatus.nodeLanStatuss[lanNumber]
             
             if !lanStatus.ip4_subnet.isEmpty {
                 return false
             }
         }

        return true
    }
    
    func ipv4AddressFor(lanNumber: Int) -> String {
        if let nodeLanStatus = HubDataModel.shared.optionalAppDetails?.nodeLanStatus {
            let lanStatus = nodeLanStatus.nodeLanStatuss[lanNumber]
            
            if !lanStatus.ip4_subnet.isEmpty {
                return lanStatus.ip4_subnet
            }
        }
        
        let config = parentVm.meshLanConfig.lans[lanNumber]
        return config.ip4_subnet
    }

    // From MAS 1534: The IP Subnet on the lan page should be greyed out for bridge mode
    var subnetAddressEnabled: Bool {
        guard let delegate else { return false }
        return delegate.wanMode != .BRIDGED
    }
    
    var numberOfAps: Int {
        return HubDataModel.shared.hardwareVersion.numberOfUserConfigurableSsids
    }
    
    // MARK: - Tab Bar Selection
    /// Record of the last tab bar selection
    var lastSelectedLan: Int = 0
    
    var currentlySelectedLanConfig: MeshLan? {
        get {
            let lans = self.parentVm.meshLanConfig
            let lansArr = [lans.lan_1, lans.lan_2, lans.lan_3, lans.lan_4]
            return lansArr[lastSelectedLan]
        }
    }
    
    // MARK: - Init and Helpers
    init(parentViewModel: LanConfigurationViewModel) {
        self.parentVm = parentViewModel
    }
}

// MARK: - WAN and IP Mode
extension LanMeshViewModel {
    /// Changes the wan mode and returns the next value
    func wanModeTapped(current: WanMode) -> WanMode {
        var allModes = WanMode.allCases

        // VHM 1595 - Remove isolated mode if backpack not supported
        if !parentVm.supportsBackpack { allModes.removeAll { $0 == .ISOLATED } }

        if let index = allModes.firstIndex(of: current) {
            let next = index + 1
            if next >= allModes.count { return allModes.first! }

            return allModes[next]
        }

        return .ROUTED
    }
}

// MARK: - Operational State
extension LanMeshViewModel {
    // See VHM - 662
    func getOperationalStateFor(lanNumber: Int) -> OperationalState {
        guard let nodeLanStatus = HubDataModel
            .shared
            .optionalAppDetails?
            .nodeLanStatus else {
                return .CLEAR
        }
        let config = parentVm.meshLanConfig.lans[lanNumber]
        let lanStatus = nodeLanStatus.nodeLanStatuss[lanNumber]
        
        let inUse = config.use
        let operational = lanStatus.operational
        let reason = lanStatus.reason
        
        if !inUse { return .CLEAR }
        
        if !operational {
            if reason.isEmpty { return .RED("LAN is not operational".localized()) }
            return .RED(reason)
        }
        
        if !reason.isEmpty { return .ORANGE(reason) }
        return .CLEAR
    }
}

// MARK: - Update
extension LanMeshViewModel {
    func updateSetting(completion: @escaping BaseConfigViewModel.CompletionDelegate) {
        
        if sendingUpdate { return }
        
        // Get the latest info from the view
        updateConfigUponChange()
        
        if !subnetsAreValid() { return }
        let shouldUpdate = parentVm.meshLanConfigChanged
        if shouldUpdate {
            guard let ies = connectedHub else { return }
            
            let dhcpDefaultSet = setDhcpDefaultsIfNeeded(updateConfig: parentVm.meshLanConfig)

            // Check if the any of the lans are set to isolated.
            // If they are, set the wans to 0 (VHM-1612)
            var meshLanConfig = parentVm.meshLanConfig
            meshLanConfig.setWanInterfaceToZeroIfIsolated()

            ApiFactory.api.setConfig(connection: ies, config: meshLanConfig) { [weak self]  (result, error) in
                if error != nil {
                    completion(nil, error)
                    return
                }

                if dhcpDefaultSet {
                    ApiFactory.api.setConfig(connection: ies,
                                             config: self!.parentVm.nodeLanConfig,
                                             completion: completion)
                }
                else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    private func setDhcpDefaultsIfNeeded(updateConfig: MeshLanConfig) -> Bool {
        var needUpdate = false
        
        for (index, config) in updateConfig.lans.enumerated() {
            if config.dhcp && (config.wanMode != .ISOLATED){
                if parentVm.nodeLanConfig.lans[index].lease_time == 0 {
                    parentVm.nodeLanConfig.lans[index].lease_time = 60
                    needUpdate = true
                }
                
                if parentVm.nodeLanConfig.lans[index].dns_1.isEmpty {
                    parentVm.nodeLanConfig.lans[index].dns_1 = "8.8.8.8"
                    needUpdate = true
                }
                
                if parentVm.nodeLanConfig.lans[index].dns_2.isEmpty {
                    parentVm.nodeLanConfig.lans[index].dns_2 = "8.8.8.4"
                    needUpdate = true
                }
            }
        }
        
        return needUpdate
    }
    
    func updateConfigUponChange() {
        guard let d = delegate else { return }

        var lan = parentVm.meshLanConfig.lans[lastSelectedLan]

        lan.use = d.enabledSwitch.isOn
        lan.name = d.lanNameTextField.text!

        // Only update this if the field is user editable.
        // This can be changed by ipv4AddressFor(lanNumber: Int) -> String 
        if !(d.subnetTextField.readOnly ?? true) { lan.ip4_subnet = d.subnetTextField.text! }

        lan.wanMode = d.wanMode
        lan.ipManagementMode = selectedIpManagementMode

        if let wanInterface = Int(d.wanInterface.text!) {
            lan.wan_id = wanInterface
        }
        
        // AP Switches
        updateApSelection(lan: &lan, apNumber: 1)
        updateApSelection(lan: &lan, apNumber: 2)
        
        // Port Switches
        //updatePortSelections(index: lastSelectedLan)
        updatePortSelections(lan: &lan)

        //updateVLanSelections(index: index)
        
        // Client Isolation
        lan.clientIsolationOn = d.clientIsolationSwitch.isOn
        
        var changed = false

        // Update the parent.
        parentVm.setMeshLan(meshLan: lan, for: lastSelectedLan)

        if parentVm.nodeLanConfigChanged ||
            parentVm.meshLanConfigChanged {
            changed = true
        }

        delegate?.showApply(show: changed)
    }

    private func updateApSelection(lan: inout MeshLan, apNumber: Int) {
        guard let d = delegate else { return }
        var apSelections = [Int]()

        // Get the correct UI switches
        var apSwitches = d.ap1Switches
        if apNumber == 2 {
            apSwitches = d.ap2Switches
        }

        for (index, apSwitch) in apSwitches!.enumerated() {
            if apSwitch.isOn == true {
                apSelections.append(index + 1)
            }
        }

        if apNumber == 1 {
            lan.ap_set_1 = apSelections
        }
        else if apNumber == 2 {
            lan.ap_set_2 = apSelections
        }
    }

    private func updatePortSelections(lan: inout MeshLan) {
        guard let d = delegate else { return }

        var portSelections = [Int]()

        for (index, sw) in d.lanOverlaySwitches.enumerated() {
            if sw.isOn == true {
                portSelections.append(index + 1)
            }
        }

        lan.port_set = portSelections
    }
    
    /// Update and deconficts the AP selections
    /// - Parameters:
    ///   - apSet: The AP set being manipulated
    ///   - selectedIndex: The currently selected Lan
    ///   - ap: The AP being manupulated
    func updateApConfigurationsForSelection(changedAp: [Int]?,
                                            selectedIndex: Int, // The index of the currently selected lan
                                            ap: Int) {
        guard let changedAp = changedAp else { return }
        
        for (index, var lan) in parentVm.meshLanConfig.lans.enumerated() {
            if index != selectedIndex {
                // Remove any duplicate values if its not the selected Lan
                let selectedAp = ap == 1 ? lan.ap_set_1 : lan.ap_set_2
                guard let deduplicatedVals = delegate?.deDuplicateLanSets(portOrApSet: selectedAp,
                                                                          changedSelection: changedAp) else { return }
                if ap == 1 {
                    lan.ap_set_1 = deduplicatedVals
                }
                else if ap == 2 {
                    lan.ap_set_2 = deduplicatedVals
                }

                parentVm.setMeshLan(meshLan: lan, for: index)
            }
        }
    }
    
    func updatePortSettings() {
        // Save the new port settings
        var selectedLan = parentVm.meshLanConfig.lans[lastSelectedLan]
        updatePortSelections(lan: &selectedLan)
        parentVm.setMeshLan(meshLan: selectedLan, for: lastSelectedLan)

        // Get the currently selected config
        let changedPorts = selectedLan.port_set
        
        for (index, var lan) in parentVm.meshLanConfig.lans.enumerated() {
            if index != lastSelectedLan {
                // Remove any duplicate values
                guard let deduplicatedVals = delegate?.deDuplicateLanSets(portOrApSet:
                    lan.port_set, changedSelection: changedPorts) else {
                    return
                }
                
                lan.port_set = deduplicatedVals
                parentVm.setMeshLan(meshLan: lan, for: index)
            }
        }
    }
    
    func updateVLanSettings() {
        // Save the new VLAN settings
        //updateVLanSelections(index: lastSelectedLan)
        
        // Get the currently selected config
        let changedVLans = parentVm.meshLanConfig.lans[lastSelectedLan].vlan_set
        
        for (index, var lan) in parentVm.meshLanConfig.lans.enumerated() {
            if index != lastSelectedLan {
                // Remove any duplicate values
                guard let deduplicatedVals = delegate?.deDuplicateLanSets(portOrApSet:
                    lan.vlan_set, changedSelection: changedVLans) else {
                    return
                }
                
                lan.vlan_set = deduplicatedVals
                parentVm.setMeshLan(meshLan: lan, for: index)
            }
        }
    }
    
    func updateApSettings(sw: UISwitch) {
        guard let d = delegate else { return }
        
        // Get the AP we have made an adjustment too for this LAN
        if d.ap1Switches.contains(sw) {
            var lan = parentVm.meshLanConfig.lans[lastSelectedLan]
            updateApSelection(lan: &lan, apNumber: 1)
            parentVm.setMeshLan(meshLan: lan, for: lastSelectedLan)
            updateApConfigurationsForSelection(changedAp: lan.ap_set_1,
                                               selectedIndex: lastSelectedLan, ap: 1)
        }
            
        else if d.ap2Switches.contains(sw) {
            var lan = parentVm.meshLanConfig.lans[lastSelectedLan]
            updateApSelection(lan: &lan, apNumber: 2)
            parentVm.setMeshLan(meshLan: lan, for: lastSelectedLan)
            updateApConfigurationsForSelection(changedAp: lan.ap_set_2,
                                               selectedIndex: lastSelectedLan, ap: 2)
        }
    }
}


// MARK: - Validation
extension LanMeshViewModel {
    func subnetsAreValid() -> Bool {
        guard let delegate = delegate else { return false }
        
        for (index, lan) in parentVm.meshLanConfig.lans.enumerated() {
            let ipSub = lan.ip4_subnet
            
            // Only check lans that are in use.
            if !lan.use || !ipv4TextFieldUserEditableFor(lanNumber: index) {
                continue
            }
            
            if ipSub.isEmpty /*&& delegate.dhcpActive*/ && delegate.wanMode == .ROUTED {
                showAlert(with: "IP Error".localized(), message: "\(lan.name)" + " has no IPv4 subnet entered".localized())
                return false
            }
            
            let components = ipSub.split(separator: "/")
            if components.count == 1 {
                guard let ip = components.first else {
                    showAlert(with: "IP Error".localized(), message: "Badly formed IP address".localized())
                    return false
                }
                
                let valid = AddressAndPortValidation.isIPValid(string: String(ip))
                if !valid {
                    showAlert(with: "IP Error".localized(), message: "Badly formed IP address".localized())
                }
                
                return valid
            }
            else if components.count > 2 {
                showAlert(with: "Subnet Error".localized(), message: "Badly formed IP address and subnet".localized())
                return false
            }
            
            if let e = AddressAndSubnetValidation.isFirstAddressAndPrefixValid(addressSubnetString: ipSub) {
                showAlert(with: "Subnet Error".localized(), message: "\(lan.name): \(e)")
                
                return false
            }
        }
        
        return true
    }
}

// MARK: - WAN Interface UI
extension LanMeshViewModel {

    var wanShouldBeHidden: Bool {
        currentlySelectedLanConfig?.wanMode == .ISOLATED
    }

    // Returns an error message if there is an issue: VHM-1654
    var wanEntryErrors: String? {
        if currentlySelectedLanConfig?.wanMode != .ISOLATED {
            if let wanId = currentlySelectedLanConfig?.wan_id {
                if wanId == 0 {
                    return "A WAN Interface needs to be associated with this LAN".localized()
                }
            }
        }

        // If Isolated is selected then 0 will be applied upon sending.
        return nil
    }
}

extension LanMeshViewModel: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        delegate?.updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}

// MARK: - VHM-1596 - IP Management
extension LanMeshViewModel {
    func setInitialIpManagmentMode(for lan: Int?) {
        guard let lan else { return }

        guard let mode = parentVm.getIpManagementMode(for: lan) else {
            selectedIpManagementMode = parentVm.defaultIpManagementMode(lan: lan)
            return
        }

        if !parentVm.supportsIpMode {
            selectedIpManagementMode = parentVm.defaultIpManagementMode(lan: lan)
            updateWanMode(lan: lan, mode: selectedIpManagementMode)
        }
        else if parentVm.isIpModeValidForWanMode(ipMode: mode, for: lan) {
            selectedIpManagementMode = mode
        }
        else { // Set the default
            selectedIpManagementMode = parentVm.defaultIpManagementMode(lan: lan)
            updateWanMode(lan: lan, mode: selectedIpManagementMode)
        }
    }

    private func updateWanMode(lan: Int, mode: IpManagementMode) {
        var meshLan = parentVm.meshLanConfig.lans[lan]
        meshLan.ipManagementMode = mode
        parentVm.setMeshLan(meshLan: meshLan, for: lan)
        setStaticIpUseBasedOn(mode: mode, lanNumber: lan)
    }

    // From MAS 1534: When static mode is set set set static ip use to true
    // We need to set the value from here, not the actual screen.
    private func setStaticIpUseBasedOn(mode: IpManagementMode, lanNumber: Int) {
        if !parentVm.supportsBackpack { return }
        guard var staticIPConfig = parentVm.nodeLanConfigStaticIpDetails else { return }
        var config = staticIPConfig.lanStaticIpConfig[lanNumber]

        let inUse = mode == .STATIC
        config.use = inUse

        staticIPConfig.update(lan: config, lanIndex: lanNumber)
        parentVm.nodeLanConfigStaticIpDetails = staticIPConfig
    }

    var isIpModeChanged: Bool {
        return parentVm.meshLanConfigChanged
    }
}
