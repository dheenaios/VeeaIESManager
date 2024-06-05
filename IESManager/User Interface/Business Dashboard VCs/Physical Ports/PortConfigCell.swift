//
//  PortConfigCell.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 06/01/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

// MARK: - PortConfigCell

class PortConfigCell: UITableViewCell {
    let portNameDefault = "Port Name".localized()
    var isPortNameChanged = false
    
    @IBOutlet weak var statusBar: StatusBarWithLeftRightContent!
    @IBOutlet weak var enabledSwitch: UISwitch!
    
    @IBOutlet weak var meshSwitch: UISwitch!
    @IBOutlet weak var meshLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorBarView: UIView!
    @IBOutlet weak var errorBarHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var roleTypeSelector: TypeSelector!
    
    @IBOutlet weak var hubNetworkControl: VeeaSegmentedControl!
    @IBOutlet weak var editPortNameButton: UIButton!
    
    var disabledSegmentIndex: Int?
    
    // Type and Link
    @IBOutlet weak var typeLinkStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeLinkStackView: UIStackView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var linkIndicator: UIView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var stackToBottomConstraint: NSLayoutConstraint!
    private let showResetConstant: CGFloat = 50
    private let hideResetConstant: CGFloat = 0
    
    weak var hostViewController: UIViewController?
    var model: PortConfigCellViewModel?
    private let isMEN = !HubDataModel.shared.isMN
    
    var hubIsSelectedSegment: Bool {
        return hubNetworkControl.selectedSegmentIndex == 0
    }
    
    private var roleStrings: [String] {
        guard let roles = model?.portRolesForSelection else { return ["None".localized()] }
        var roleStrings = roles.roles.map { $0.rawValue.uppercased() }
        roleStrings.append("None".localized())
        
        return roleStrings
    }
    
    func configure(model: PortConfigCellViewModel, hostViewController: UIViewController) {
        statusBar.hideSwitch = true
        
        self.model = model
        self.hostViewController = hostViewController
        statusBar.delegate = self
        
        setupSegmentedControl()
        
        populateUI()
        showMeshSwitchIfAvailable()
        updateUIForStateChange()
        setTypeAndLan()
        showHideResetPortButton()
    }
    
    private func setupSegmentedControl() {
        guard let cellModel = model else { return }
        
        if cellModel.hubIsSelected {
            hubNetworkControl.selectedSegmentIndex = 0
        }
        else {
            if cellModel.canSetNetworkConfiguration {
                hubNetworkControl.selectedSegmentIndex = 1
            }
            else {
                hubNetworkControl.selectedSegmentIndex = 0
            }
        }
        
        if cellModel.canSetNetworkConfiguration {
            disabledSegmentIndex = nil
        }
        else {
            disabledSegmentIndex = 1
        }
    }
    
    private func setTypeAndLan() {
        guard let m = model else { return }
        
        typeLinkStackViewHeightConstraint.constant = m.showTypeAndLink ? 88 : 0
        typeLinkStackView.isHidden = m.showTypeAndLink ? false : true
        self.contentView.layoutIfNeeded()
        
        typeLabel.text = m.typeString
        linkIndicator.backgroundColor = m.linkColor
        linkIndicator.makeCircular()
    }
    
    private func showMeshSwitchIfAvailable() {
        guard let enabled = HubDataModel
                .shared.baseDataModel?
                .nodeCapabilitiesConfig?
                .supportsWiredMesh else {
                    meshSwitch.isHidden = true
                    meshLabel.isHidden = true
                    return
                }
        
        meshSwitch.isHidden = !enabled
        meshLabel.isHidden = !enabled
    }
    
    private func setEnableState() {
        guard let model = model else { return }
        
        // Are we an MN on the network view. If so nothing is enabled but the Hub Network toggle
        if HubDataModel.shared.isMN && !model.hubIsSelected {
            enableUI(enable: false)
        }
        else { // Turn everything on
            enableUI(enable: true)
        }
    }
    
    private func enableUI(enable: Bool) {
        let alpha = enable ? 1.0 : 0.3
        
        statusBar.isUserInteractionEnabled = enable
        enabledSwitch.isEnabled = enable
        roleTypeSelector.isEnabled = enable
        editPortNameButton.isEnabled = enable
        editPortNameButton.alpha = CGFloat(alpha)
        meshSwitch.isEnabled = enable
        hubNetworkControl.isEnabled = enable
        typeLinkStackView.alpha = CGFloat(alpha)
    }
    
    private func updateRoleOptions() {
        // Disable segments we dont need
        guard let hostVC = hostViewController else { return }
        guard let hubSelected = model?.hubIsSelected,
              let config = hubSelected ? model?.nodePorts : model?.meshPorts else {
                  return
              }
        
        var index = roleStrings.count - 1
        if let i = roleStrings.firstIndex(of: config.role.rawValue.uppercased()) {
            index = i
        }
        
        roleTypeSelector.configure(title: "Role".localized(),
                                   alertMessage: "Select the port role".localized(),
                                   options: self.roleStrings,
                                   initialSelection: index,
                                   hostViewController: hostVC) { selectedString, selectedIndex in
            self.uiSelectionChanged()
        }
    }
    
    @IBAction private func hubNetworkSelectionChanged() {
        if !hubIsSelectedSegment {
            if let i = disabledSegmentIndex {
                if hubNetworkControl.selectedSegmentIndex == i {
                    hubNetworkControl.selectedSegmentIndex = 0
                    
                    if let vc = hostViewController as? PortsViewController {
                        vc.showIsMnWarning()
                    }
                    
                    return
                }
            }
        }
        
        // Save the current state
        updateForInUseToggleChange()
        updateConfig()
        
        // Update to using the new Hub or Network Setting, then update the UI
        self.model?.hubIsSelected = hubIsSelectedSegment
        populateUI() // as we are changing the selection
        updateUIForStateChange()
        setErrorLabel()
    }
    
    @IBAction private func uiSelectionChanged() {
        updateConfig()
        updateUIForStateChange()
    }
    
    private func updateForInUseToggleChange() {
        if hubIsSelectedSegment {
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
            model?.nodePorts.use = true
        }
        else { // its network
            model?.meshPorts.use = true
            model?.nodePorts.use = false
        }
    }
        
    // This need to be called after any UI change and before any UI updates.
    // This method should have no UI updating in it. Only config updating
    private func updateConfig() {
        guard let hubSelected = model?.hubIsSelected,
              var configSelected = hubSelected ? model?.nodePorts : model?.meshPorts,
              let configDeselected = hubSelected ? model?.meshPorts : model?.nodePorts else { return }

        
        if !isMEN && !(model!.hubIsSelected) {
            // Stop here if this is an MN and we have mesh selected.
            guard let vc = hostViewController as? PortsViewController else { return }
            vc.updateApplyButton()
            return
        }
        
        // Other configuration related selections
        configSelected.locked = !enabledSwitch.isOn
        configSelected.mesh = meshSwitch.isOn
        if isPortNameChanged {
            configSelected.name = statusBar.switchSubTitleText
        }
        
        // Segmented control
        if let roles = model?.portRolesForSelection.roles {
            if let selectedIndex = roleTypeSelector.selectedIndex {
                if selectedIndex == roleStrings.count - 1 {
                    configSelected.role = .UNUSED
                }
                else {
                    let role = roles[selectedIndex]
                    configSelected.role = role
                }
            }
        }
        else {
            configSelected.role = Role.UNUSED
        }
        
        // Assign the changes back to the model
        if model!.hubIsSelected {
            model?.nodePorts = configSelected
            model?.meshPorts = configDeselected
        }
        else {
            model?.meshPorts = configSelected
            model?.nodePorts = configDeselected
        }
        
        guard let vc = hostViewController as? PortsViewController else { return }
        vc.updateApplyButton()
    }

    // Only call after saving the config
    private func populateUI() {
        guard let model = model else { return }
        
        let portNum = model.index + 1
        let portNameLabelText = "\("Port".localized()) \(portNum) "
        statusBar.switchTitleText = portNameLabelText
        
        let config = model.currentlySelectedConfig
        //statusBar.inUse = config.use
        enabledSwitch.isOn = !config.locked
        
        if config.name.isEmpty {
            statusBar.switchSubTitleText  = portNameDefault
            statusBar.switchSubTitleTextFaded(faded: true)
        } else {
            statusBar.switchSubTitleText = config.name
            statusBar.switchSubTitleTextFaded(faded: false)
        }
        
        meshSwitch.isOn = config.mesh
        updateRoleOptions()
        
        let role = config.role
        let index = segmentIndexForRole(role: role)
        roleTypeSelector.selectedIndex = index
        setStateColor()
        setEnableState()
    }
    
    func segmentIndexForRole(role: Role) -> Int? {
        let roleName = role.rawValue
        if let index = roleStrings.firstIndex(of: roleName) {
            return index
        }
        
        return nil
    }
    
    private func updateUIForStateChange() {
        setEnableState()
        setStateColor()
        setErrorLabel()
    }
    
    private func setErrorLabel() {
        guard let errorMessage = model?.portStatus.reason else { return }
        if !errorMessage.isEmpty {
            errorLabel.text = errorMessage
            errorBarHeightContraint.constant = 27.0
        }
        else {
            errorBarHeightContraint.constant = 0
        }
        
        if let model = model {
            if model.portNeverUsed {
                errorBarView.backgroundColor = UIColor(named: "portNeverUpGrey")
                errorLabel.textColor = .label
            }
            else {
                errorBarView.backgroundColor = UIColor(named: "errorBarBgColor")
                errorLabel.textColor = UIColor(named: "errorBarTextColor")
            }
        }
    }
    
    @IBAction func portNameTapped() {
        guard let config = model?.currentlySelectedConfig,
              let vc = hostViewController else { return }
        
        Utils.showInputAlert(from: vc,
                             title: "Port Name".localized(),
                             message: "You can change your port here.".localized(),
                             initialValue: config.name,
                             okButtonText: "Change".localized()) { (newValue) in
            if newValue.isEmpty {
                self.statusBar.switchSubTitleText = self.portNameDefault
                self.statusBar.switchSubTitleTextFaded(faded: true)
            }
            else {
                self.statusBar.switchSubTitleTextFaded(faded: false)
                self.isPortNameChanged = true
                self.statusBar.switchSubTitleText = newValue
            }
            
            self.uiSelectionChanged()
        }
    }
}

extension PortConfigCell: StatusBarDelegate {
    func inUseChanged(inUse: Bool) {
        updateConfig()
    }
    
    func inUseTitleTapped() {
        portNameTapped()
    }
}

// MARK: Reset Button
extension PortConfigCell {
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
        hostViewController?.present(alert,
                                    animated: true,
                                    completion: nil)
    }
    
    private func sendTrigger() {
        model?.nodePorts.reset_trigger = true
        if let host = hostViewController as? PortsViewController {
            host.applyConfig()
        }
    }
    
    fileprivate func showHideResetPortButton() {
        if let model = model {
            resetButton.isHidden = !model.showResetButton
            stackToBottomConstraint.constant = model.showResetButton ? showResetConstant : hideResetConstant
            return
        }
        
        resetButton.isHidden = true
        stackToBottomConstraint.constant = hideResetConstant
    }
    
}

// MARK: Color state
extension PortConfigCell {
    private func setStateColor() {
        // VHM- 872 - Color logic changes and UI changes
        setStatusToNone()
        
        guard let model = model else { return }
        let state = model.getState()
        statusBar.setConfig(config: state)
    }
    
    private func setStatusToNone() {
        setErrorLabel()
        
        guard let model = model else {
            let c = PortStatusBarConfig(state: .inactive)
            statusBar.setConfig(config: c)
            
            return
        }
        
        if model.portNeverUsed {
            let c = PortStatusBarConfig(state: .neverUsed)
            statusBar.setConfig(config: c)
            return
        }
        
        let c = PortStatusBarConfig.init(state: .inactive)
        statusBar.setConfig(config: c)
    }
}



