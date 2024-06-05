//
//  PortsViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 17/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class PortsViewController: BaseConfigViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .ports_settings_screen

    var flowController: HubInteractionFlowController?
    
    let vm = PortsConfigsViewModel()
    
    let portNameDefault = "Port Name".localized()
    
    @IBOutlet weak var portPicker: PortsPickerView!
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    @IBOutlet weak var healthPill: PortHealthPill!
    @IBOutlet weak var meshOrNetworkRow: RowView!
    @IBOutlet weak var portNameRow: RowImgView!
    @IBOutlet weak var roleRow: RowView!
    @IBOutlet weak var enableRow: RowSwitchView!
    @IBOutlet weak var meshRow: RowSwitchView!
    @IBOutlet weak var typeRow: RowView!
    @IBOutlet weak var linkRow: RowIndicatorView!
    @IBOutlet weak var resetButtonRow: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Physical Ports".localized()
        inlineHelpView.setText(labelText: "This screen shows information about the Ethernet ports on the VeeaHub network.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
        
        updatePicker()
        
        if !vm.portDetails.isEmpty {
            portPicker.setPort(portIndex: 0)
            vm.selectedPortConfigModel = vm.physicalPortCellModels.first!
        }
        
        updateStatusPill()
        enableConfigRows()
                
        meshOrNetworkRow.observerTaps { self.handleMeshNetworkSelection() }
        portNameRow.observerTaps { self.handlePortNameChange() }
        roleRow.observerTaps { self.handleRoleSelectionChange() }
        enableRow.observerTaps { self.saveChanges() }
        meshRow.observerTaps { self.saveChanges() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    func showIsMnWarning() {
            if HubDataModel.shared.isMN {
                showInfoMessage(message: "Network settings can only be changed from the MEN.\n".localized())
                showInfoAlert(title: "Unable to select Network".localized(), message: "The \"Network\" port is not configured. If you want to select or use the \"Network\" port, please configure it from MEN.".localized())
            }
        }

    private func updatePicker() {
        portPicker.hostVc = self
        portPicker.portDetails = vm.portDetails
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .physical_ports, push: true)
    }
    
    override func applyConfig() {
        if let errors = vm.settingErrors() {
            let title = errors.0
            let message = errors.1
            showInfoAlert(title: title, message: message)
            return
        }
        
        sendingUpdate = true
        updateUpdateIndicatorState(state: .uploading)
        
        vm.applyUpdate { [weak self] (message, error) in
            self?.sendingUpdate = false
            
            if error != nil {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                self?.showErrorUpdatingAlert(error: error!)
                
                return
            }
            
            self?.updateHubDataSet()
        }
    }
    
    private func updateHubDataSet() {
        HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
    }
}

// MARK: - User Interaction
extension PortsViewController {
    private func handleMeshNetworkSelection() {
        let sheet = UIAlertController(title: "Select Network Type".localized(),
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Hub Network".localized(), style: .default, handler: { action in
            self.saveChanges()
            self.vm.selectedPortConfigModel?.hubIsSelected = true
            self.updateForNetworkTypeChange()
        }))
        sheet.addAction(UIAlertAction(title: "Mesh Network".localized(), style: .default, handler: { action in
            self.saveChanges()
            self.vm.selectedPortConfigModel?.hubIsSelected = false
            self.updateForNetworkTypeChange()
        }))
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
    }
    
    private func updateForNetworkTypeChange() {
        enableConfigRows()
        updateUi()
        updateApplyButton()
    }
    
    private func enableConfigRows() {
        var enable = true
        if !(vm.selectedPortConfigModel?.hubIsSelected ?? false) && HubDataModel.shared.isMN {
            showInfoMessage(message: "Network settings can only be changed from the MEN".localized())
            enable = false
        }
        
        portNameRow.disableView(disabled: !enable)
        roleRow.disableView(disabled: !enable)
        enableRow.disableView(disabled: !enable)
        meshRow.disableView(disabled: !enable)
        typeRow.disableView(disabled: !enable)
        linkRow.disableView(disabled: !enable)
    }
    
    private func handlePortNameChange() {
        guard let model = vm.selectedPortConfigModel?.currentlySelectedConfig else { return }
        
        Utils.showInputAlert(from: self,
                             title: portNameDefault,
                             message: "You can change your port here.".localized(),
                             initialValue: model.name,
                             okButtonText: "Change".localized()) { (newValue) in
            if newValue.isEmpty {
                self.portNameRow.title = self.portNameDefault
            }
            else {
                self.portNameRow.title = newValue
            }
            
            self.saveChanges()
        }
    }
    
    private func handleRoleSelectionChange() {
        let sheet = UIAlertController(title: "Select Role Type".localized(),
                                      message: nil,
                                      preferredStyle: .actionSheet)
        for item in vm.roleStringsForSelectedConfiguration {
            let action = UIAlertAction(title: item, style: .default, handler: { action in
                self.roleRow.valueText = action.title!
                self.saveChanges()
            })
            sheet.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
    }
}

// MARK: - Reset button
extension PortsViewController {
    @IBAction func resetButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Reset Port".localized(), message: "This action will reset any fault conditions on the port. A disconnected port is no longer considered a fault condition. Any DHCP conflict is cleared and re-tested.\nDo you wish to continue?".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(),
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Reset",
                                      style: .destructive,
                                      handler: { action in
            self.sendTrigger()
        }))
        present(alert,
                animated: true,
                completion: nil)
    }
    
    private func sendTrigger() {
        vm.selectedPortConfigModel?.nodePorts.reset_trigger = true
        applyConfig()
    }
}

// MARK: - Saving and updating the UI
extension PortsViewController {
    private func saveChanges() {
        guard let hubSelected = vm.selectedPortConfigModel?.hubIsSelected,
              var configSelected = hubSelected ? vm.selectedPortConfigModel?.nodePorts : vm.selectedPortConfigModel?.meshPorts,
              let configDeselected = hubSelected ? vm.selectedPortConfigModel?.meshPorts : vm.selectedPortConfigModel?.nodePorts else { return }
        
        // Role Change
        let newRole = Role.roleFromDescription(description: roleRow.valueText.lowercased())
        configSelected.role = newRole
        
        // Port Name
        if portNameRow.title != portNameDefault {
            configSelected.name = portNameRow.title
        }
        else {
            configSelected.name = ""
        }
        
        // Enable Changed
        configSelected.locked = !enableRow.switchIsOn
        
        // Mesh Changed
        configSelected.mesh = meshRow.switchIsOn
        
        // Assign the changes back to the model
        if vm.selectedPortConfigModel!.hubIsSelected {
            vm.selectedPortConfigModel?.nodePorts = configSelected
            vm.selectedPortConfigModel?.meshPorts = configDeselected
        }
        else {
            vm.selectedPortConfigModel?.meshPorts = configSelected
            vm.selectedPortConfigModel?.nodePorts = configDeselected
        }

        // Once the changes have been applied update the picker
        updatePicker()
        updateUi()
        updateApplyButton()
    }
    
    func updateApplyButton() {
        let updated = vm.hasConfigChanged()
        applyButtonIsHidden = !updated
    }
    
    private func updateUi() {
        guard let model = vm.selectedPortConfigModel else { return }
        
        let hubSelected = model.hubIsSelected
        let configSelected = hubSelected ? model.nodePorts : model.meshPorts
                
        // Type of network
        meshOrNetworkRow.title = model.hubIsSelected ? "Hub Network".localized() : "Mesh Network".localized()
        
        // Port name
        setPortNameDisplay(config: configSelected)
        
        // Role
        setRoleDisplay()
        
        // Enable
        enableRow.switchIsOn = !configSelected.locked
        
        // Mesh
        meshRow.switchIsOn = configSelected.mesh
        
        // Type
        typeRow.valueText = model.typeString
        
        // Link
        linkRow.indicatorColor = model.linkColor
        
        updateStatusPill()
        updatePicker()
        enableConfigRows()
        showHideItems()
    }
    
    private func setPortNameDisplay(config: PortConfigModel) {
        if config.name.isEmpty {
            portNameRow.title = portNameDefault
        }
        else {
            portNameRow.title = config.name
        }
    }
    
    private func setRoleDisplay() {
        guard let model = vm.selectedPortConfigModel else { return }
        let roleStrings = vm.roleStringsForSelectedConfiguration
        
        let ports = model.hubIsSelected ? model.nodePorts : model.meshPorts
        
        var index = roleStrings.count - 1
        if let i = roleStrings.firstIndex(of: ports.role.rawValue.uppercased()) {
            index = i
        }
        
        roleRow.valueText = roleStrings[index]
    }
    
    private func updateStatusPill() {
        guard let state = vm.selectedPortConfigModel?.getState(),
              let icon = state.icon,
              let iconColor = state.iconColor,
              let backgroundColor = state.barBackgroundColor else {
                  return
                  
              }
        
        icon.withRenderingMode(.alwaysTemplate)
        
        healthPill.configure(icon: icon.tintWithColor(iconColor),
                             backgroundColor: backgroundColor,
                             title: state.text ?? "",
                             reason: vm.selectedPortConfigModel?.portStatus.reason ?? "")
    }
    
    private func showHideItems() {
        // Mesh
        meshRow.isHidden = vm.hideMeshSwitch
        
        // Type & Link
        typeRow.isHidden = vm.hideTypeAndLink
        linkRow.isHidden = vm.hideTypeAndLink
        
        // Reset
        resetButtonRow.isHidden = vm.hideResetButton
    }
}

extension PortsViewController: PortsPickerProtocol {
    func didSelectPort(port: PortsPickerView.PortDetail) {
        saveChanges()
        vm.selectedPortConfigModel = vm.physicalPortCellModels[port.portNumber]
        updateUi()
    }
}

extension PortsViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        if !success {
            updateUpdateIndicatorState(state: .completeWithError)
            nonFatalConnectionIssue(message: message ?? "")
        }
        
        updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}
