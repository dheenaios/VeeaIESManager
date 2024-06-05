//
//  ApConfigCells.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 15/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

public class DisabledInfoCell: UITableViewCell {
    
    
}

public class APBaseConfigurationCell: UITableViewCell {
    let colorManager = InterfaceManager.shared.cm
    
    @IBOutlet weak var statusBar: StatusBar!
    @IBOutlet var ssidTextField: UITextField!
    @IBOutlet weak var hubNetworkSegController: UISegmentedControl!
    @IBOutlet weak var ssidErrorLabel: UILabel!
    @IBOutlet var hiddenSwitch: UISwitch!
    @IBOutlet var enabledSwitch: UISwitch!
    @IBOutlet weak var lanLabel: UILabel!
    @IBOutlet weak var lanTextField: UITextField!
    @IBOutlet weak var lanButton: UIButton!
    @IBOutlet weak var resetValuesButton: CurvedButton!

    var disabledSegmentIndex: Int?
    
    let isMEN = !HubDataModel.shared.isMN
    weak var hostViewController: APConfigurationViewController?
    
    var cellModel: APConfigurationCellModel?
    
    var hubIsSelected: Bool {
        let hubSelected = hubNetworkSegController.selectedSegmentIndex == 0 ? true : false
        return hubSelected
    }

    func clientIsolationEnabled() {
        if cellModel!.showClientIsolationOptions {
            lanLabel.alpha = cellModel!.clientIsolationAvailable ? 1.0 : 0.3
            lanTextField.alpha = cellModel!.clientIsolationAvailable ? 1.0 : 0.3
            lanTextField.isUserInteractionEnabled = false
            lanButton.isUserInteractionEnabled = cellModel!.clientIsolationAvailable
        }
        else {
            lanLabel.isHidden = true
            lanTextField.isHidden = true
            lanButton.isUserInteractionEnabled = false
            lanButton.isHidden = false
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    func setTheme() {
        let cm = InterfaceManager.shared.cm
        hubNetworkSegController.selectedSegmentTintColor = cm.themeTint.colorForAppearance
        resetValuesButton.setCustomFontSize(12.0)
    }
    
    @IBAction func lanButtonTapped(_ sender: UIControl) {
        if !cellModel!.clientIsolationAvailable {
            return
        }
        
        var style = UIAlertController.Style.actionSheet
        if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
            style = UIAlertController.Style.alert
        }
        
        let a = UIAlertController(title: "Select a LAN".localized(),
                                       message: nil,
                                       preferredStyle: style)
        
        a.addAction(UIAlertAction(title: "LAN 1".localized(), style: .default, handler: { (alert) in
            self.setLanTextValue(val: "1", sender)
        }))
        a.addAction(UIAlertAction(title: "LAN 2".localized(), style: .default, handler: { (alert) in
            self.setLanTextValue(val: "2", sender)
        }))
        a.addAction(UIAlertAction(title: "LAN 3".localized(), style: .default, handler: { (alert) in
            self.setLanTextValue(val: "3", sender)
        }))
        a.addAction(UIAlertAction(title: "LAN 4".localized(), style: .default, handler: { (alert) in
            self.setLanTextValue(val: "4", sender)
        }))
        a.addAction(UIAlertAction(title: "None".localized(), style: .destructive, handler: { (alert) in
            self.setLanTextValue(val: "0", sender)
        }))
        
        hostViewController?.present(a, animated: true, completion: nil)
    }


    @IBAction func resetButtonTapped(_ sender: Any) {
        let ssidName = cellModel?.currentSsidName
        let message = "This will clear the configuration of \(ssidName ?? "this Wi-Fi access point"). These changes will be applied on your VeeaHub when you tap \"Apply\"."

        let alert = UIAlertController(title: "Clear Wi-Fi Configuration?", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { action in
            self.clearAp()
            self.hostViewController?.cellWasUpdated()
        }))

        hostViewController?.present(alert, animated: true)
    }

    private func clearAp() {
        cellModel?.clearConfiguration()
        populateUi()
    }

    func updateResetButtonState() {
        if let cellModel = cellModel {
            resetValuesButton.disableView(disabled: cellModel.hasBeenCleared)
        }
    }

    private func setLanTextValue(val: String, _ sender: UIControl) {
        lanTextField.text = val
        settingChanged(sender)
        hostViewController?.cellWasUpdated()
    }
    
    @IBAction func settingChanged(_ sender: UIControl) {
        if sender == hubNetworkSegController {
            if let i = disabledSegmentIndex {
                if hubNetworkSegController.selectedSegmentIndex == i {
                    hubNetworkSegController.selectedSegmentIndex = 0
                    cellModel?.hubIsSelected = true
                    showIsMnWarning()
                    
                    return
                }
            }

            cellModel?.hubIsSelected = hubNetworkSegController.selectedSegmentIndex == 0 ? true : false

            populateUi()
        }
        
        updateCellModel()
        setColorState()
        clientIsolationEnabled()
        updateResetButtonState()
    }
    
    func setUpSegmentedControl() {
        guard let cellModel = cellModel else { return }
        
        if cellModel.hubIsSelected {
            hubNetworkSegController.selectedSegmentIndex = 0
        }
        else {
            if cellModel.canSetNetworkConfiguration {
                hubNetworkSegController.selectedSegmentIndex = 1
            }
            else {
                hubNetworkSegController.selectedSegmentIndex = 0
            }
        }
        
        if cellModel.canSetNetworkConfiguration {
            disabledSegmentIndex = nil
        }
        else {
            disabledSegmentIndex = 1
        }
    }
    
    func setColorState() {
        guard let cellModel = cellModel else {
            return
        }
        
        statusBar.setConfig(config: cellModel.statusBarConfig)
    }
   
    func showIsMnWarning() {
        hostViewController?.showIsMnWarning()
    }
    
    @objc func updateCellModel() {
        assertionFailure("Implement in sub classes")
    }
    
    func populateUi() {
        assertionFailure("Implement in sub classes")
    }
}















// MARK: - Current cell with AP Security
public class APConfigurationCell: APBaseConfigurationCell {
    @IBOutlet weak var securityTypeLabel: UILabel!
    @IBOutlet weak var syConfigButton: UIButton!
    @IBOutlet weak var sySelectButton: UIButton! // Not visible
    @IBOutlet weak var securityError: UILabel!
        
    lazy var configCoordinator: SecurityConfigCoordinator? = {
        let cc = SecurityConfigCoordinator(config: cellModel!.currentConfig,
                                           delegate: self,
                                           isHubAp: hubIsSelected)
        return cc
    }()
    
    private var allViews: [UIView] {
        return [ssidTextField,
                hiddenSwitch,
                enabledSwitch,
                securityTypeLabel,
                syConfigButton,
                sySelectButton,
                securityTypeLabel,
                syConfigButton,
                lanTextField
        ]
    }
    
    override func setTheme() {
        super.setTheme()
        syConfigButton.backgroundColor = colorManager.themeTint.colorForAppearance
    }
    
    @IBAction func securityButtonTapped(_ sender: Any) {
        updateCellModel()
        guard let config = cellModel?.currentConfig else { return }
        guard let nc = UIStoryboard(name: "WifiApSecurity",
                                    bundle: nil).instantiateInitialViewController() as? SecurityNavigationViewController else { return }
        
        configCoordinator = SecurityConfigCoordinator(config: config,
                                                      delegate: self,
                                                      isHubAp: hubIsSelected)
        nc.coordinator = configCoordinator
        hostViewController?.present(nc, animated: true, completion: nil)
    }
    
    func configure(model: APConfigurationCellModel) {
        cellModel = model
        configCoordinator = nil
        statusBar.delegate = self
        
        setUpSegmentedControl()
        validateEntries()
        populateUi()
        displaySelectedSecurityMode()
        clientIsolationEnabled()

        self.updateResetButtonState()
        
        setTheme()
    }
        
    private func displaySelectedSecurityMode() {
        guard let cellModel = cellModel else {
            return
        }
        
        let config = cellModel.currentConfig
        
        if !hubIsSelected && !cellModel.meshEditable {
            enabled(enabled: false)
            return
        }
        
        if config.enhancedSecuritySupported {
            syConfigButton.alpha = 1.0
            syConfigButton.isUserInteractionEnabled = true
            
            if let mode = config.secureMode {
                switch mode {
                case .open:
                    securityTypeLabel.text = "Open".localized()
                    syConfigButton.alpha = 0.3
                    syConfigButton.isUserInteractionEnabled = false
                case .preSharedPsk:
                    securityTypeLabel.text = "Pre-shared key".localized()
                case .enterprise:
                    securityTypeLabel.text = "Enterprise".localized()
                }
            }
            
            return
        }
        
        securityTypeLabel.text = "Security type: Pre-shared key".localized()
    }
    
    override func updateCellModel() {
        guard let cellModel = cellModel else { return }
        
        cellModel.hubIsSelected = hubIsSelected
        
        if hubIsSelected {
            cellModel.currentSsidName = ssidTextField.text ?? ""
            cellModel.currentIsHidden = hiddenSwitch.isOn
            cellModel.currentIsOn = enabledSwitch.isOn
            
            guard let lanStr = lanTextField.text,
                  let lId = Int(lanStr) else { return }
            cellModel.currentLanId = lId
            
            /*
            ii) Configure Network SSID properly and then switch back to Hub
            If Network SSID is enabled and configured properly (validate all the
            entries for Network and mesh's Use=true) then we should make node's Use = true even its
            blank. Status of the Hub's SSID is change from "Not use" to "Disabled".
            (Nick's case If user wants to disable MEN's Network SSID without disrupt the connected MNs
            Network wide connection Nick has reviewed this and agreed this is the correct rule)
             */
            if (cellModel.meshApConfig.ssidIsValid && cellModel.meshApConfig.enabled) && cellModel.nodeApConfig.isEmpty {
                cellModel.nodeApConfig.use = true
            }
            else {
                cellModel.nodeApConfig.use = !cellModel.nodeApConfig.isEmpty
            }
        }
        else { // Network
            cellModel.nodeApConfig.use = false
            
            if isMEN {
                cellModel.currentSsidName = ssidTextField.text ?? ""
                cellModel.currentIsHidden = hiddenSwitch.isOn
                cellModel.currentIsOn = enabledSwitch.isOn
                
                guard let lanStr = lanTextField.text,
                      let lId = Int(lanStr) else { return }
                cellModel.currentLanId = lId
                
                // Only set to true if the ap config is not empty
                cellModel.meshApConfig.use = !cellModel.meshApConfig.isEmpty
            }
        }
        
        validateEntries()
        displaySelectedSecurityMode()
        hostViewController?.cellWasUpdated()
    }
    
    private func validateEntries() {
        ssidErrorLabel.text = ""
        securityError.text = ""
        
        // SSID
        if !(ssidTextField.text?.isEmpty ?? true) {
            let ssidValidationResult = SSIDNamePasswordValidation.ssidNameValid(str: ssidTextField.text ?? "")
            if !ssidValidationResult.0 {
                ssidErrorLabel.text = ssidValidationResult.1
            }
        }
    }
        
    override func populateUi() {
        ssidErrorLabel.text = ""
        securityError.text = ""
        
        guard let model = cellModel else {
            enabled(enabled: false)
            return
        }

        ssidTextField.text = model.currentSsidName
        hiddenSwitch.isOn = model.currentIsHidden
        enabledSwitch.isOn = model.currentIsOn
        lanTextField.text = "\(model.currentLanId)"

        setColorState()
        
        if hubIsSelected { enabled(enabled: true) }
        else { enabled(enabled: model.meshEditable) }
        self.updateResetButtonState()
    }
    
    // Users should not be able to edit Mesh info on MNs
    private func enabled(enabled: Bool) {
        for v in allViews {
            v.isUserInteractionEnabled = enabled
            v.alpha = enabled ? 1.0 : 0.3
        }
    }
    
    @IBAction func syTypeTapped(_ sender: Any) {
        selectSyType()
    }
    
    private func selectSyType() {
        var style = UIAlertController.Style.actionSheet
        if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
                    style = UIAlertController.Style.alert
                }
        
        let alert = UIAlertController(title: "Security Type".localized(),
                                      message: "Select SSID Security Type".localized(),
                                      preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Open".localized(), style: .default, handler: { (alert) in
            self.setSecurityMode(mode: .open)
        }))
        alert.addAction(UIAlertAction(title: "Pre-shared key (PSK)".localized(),
                                      style: .default,
                                      handler: { (alert) in
            self.setSecurityMode(mode: .preSharedPsk)
        }))
        alert.addAction(UIAlertAction(title: "Enterprise".localized(),
                                      style: .default,
                                      handler: { (alert) in
            self.setSecurityMode(mode: .enterprise)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(),
                                      style: .cancel,
                                      handler: { (alert) in
            // Handle
        }))
        
        hostViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func setSecurityMode(mode: AccessPointConfig.SecureMode) {
        cellModel?.currentSecureMode = mode
        displaySelectedSecurityMode()
        hostViewController?.cellWasUpdated()
    }
}

extension APConfigurationCell: StatusBarDelegate {
    func inUseTitleTapped() {
        //print("Title tapped")
    }
    
    func inUseChanged(inUse: Bool) {
        updateCellModel()
        setColorState()
    }
}

extension APConfigurationCell: SecurityConfigCoordinatorDelegate {
    func secChangesDidFinishWithChanges(model: AccessPointConfig) {
        if hubIsSelected { cellModel?.nodeApConfig = model }
        else { cellModel?.meshApConfig = model }
        
        displaySelectedSecurityMode()
        setColorState()
        hostViewController?.cellWasUpdated()
    }
}













// MARK: - Legacy Cell
public class LegacyAPConfigurationCell: APBaseConfigurationCell {
    @IBOutlet private var passwordTextField: SecureEntryTextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    private var allViews: [UIView] {
        return [ssidTextField,
                passwordTextField,
                hiddenSwitch,
                enabledSwitch,
                lanTextField]
    }
    
    func configure(model: APConfigurationCellModel) {
        cellModel = model
        statusBar.delegate = self
        setUpSegmentedControl()
        passwordTextField.textField.addTarget(self, action: #selector(updateCellModel), for: .editingChanged)
        populateUi()
        passwordTextField.textChangeDelegate = self
        clientIsolationEnabled()

        self.updateResetButtonState()
        
        setTheme()
    }
    
    override func updateCellModel() {
        guard let cellModel = cellModel else { return }
        
        cellModel.hubIsSelected = hubIsSelected
        
        if hubIsSelected {
            cellModel.nodeApConfig.ssid = ssidTextField.text ?? ""
            cellModel.nodeApConfig.pass = passwordTextField.textField.text ?? ""
            cellModel.nodeApConfig.hidden = hiddenSwitch.isOn
            cellModel.nodeApConfig.locked = !enabledSwitch.isOn
            
            guard let lanStr = lanTextField.text,
                  let lId = Int(lanStr) else { return }
            cellModel.nodeApConfig.lan_id = lId
            
            /*
            ii) Configure Network SSID properly and then switch back to Hub
            If Network SSID is enabled and configured properly (validate all the
            entries for Network and mesh's Use=true) then we should make node's Use = true even its
            blank. Status of the Hub's SSID is change from "Not use" to "Disabled".
            (Nick's case If user wants to disable MEN's Network SSID without disrupt the connected MNs
            Network wide connection Nick has reviewed this and agreed this is the correct rule)
             */
            if (cellModel.meshApConfig.ssidIsValid && cellModel.meshApConfig.enabled) && cellModel.nodeApConfig.isEmpty {
                cellModel.nodeApConfig.use = true
            }
            else {
                cellModel.nodeApConfig.use = !cellModel.nodeApConfig.ssid.isEmpty
            }
        }
        else {
            cellModel.nodeApConfig.use = false
            
            if isMEN {
                cellModel.meshApConfig.ssid = ssidTextField.text ?? ""
                cellModel.meshApConfig.pass = passwordTextField.textField.text ?? ""
                cellModel.meshApConfig.hidden = hiddenSwitch.isOn
                cellModel.meshApConfig.locked = !enabledSwitch.isOn
                
                guard let lanStr = lanTextField.text,
                      let lId = Int(lanStr) else { return }
                cellModel.meshApConfig.lan_id = lId
                
                // Only set to true if the ap config is not empty
                cellModel.meshApConfig.use = !cellModel.meshApConfig.isEmpty
            }
        }
        
        validateEntries()
        hostViewController?.cellWasUpdated()
    }
    
    private func validateEntries() {
        ssidErrorLabel.text = ""
        passwordErrorLabel.text = ""
        
        // SSID
        if !(ssidTextField.text?.isEmpty ?? true) {
            let ssidValidationResult = SSIDNamePasswordValidation.ssidNameValid(str: ssidTextField.text ?? "")
            if !ssidValidationResult.0 {
                ssidErrorLabel.text = ssidValidationResult.1
            }
        }
        
        // Password
        if !passwordTextField.text.isEmpty {
            let passValidationResult = SSIDNamePasswordValidation.passwordValid(passString: passwordTextField.text, ssid: ssidTextField.text)
            if !passValidationResult.0 {
                passwordErrorLabel.text = passValidationResult.1
            }
        }
    }
    
    override func populateUi() {
        ssidErrorLabel.text = ""
        passwordErrorLabel.text = ""
        
        guard let model = cellModel else {
            enabled(enabled: false)
            return
        }

        ssidTextField.text = model.currentSsidName
        hiddenSwitch.isOn = !model.currentIsHidden
        enabledSwitch.isOn = model.currentIsOn
        lanTextField.text = "\(model.currentLanId)"
        passwordTextField.textField.text = model.legacyCellPasswordFieldPassword

        setColorState()
        
        if hubIsSelected { enabled(enabled: true) }
        else { enabled(enabled: model.meshEditable) }
        self.updateResetButtonState()
    }
    
    private func enabled(enabled: Bool) {
        for v in allViews {
            v.isUserInteractionEnabled = enabled
            v.alpha = enabled ? 1.0 : 0.3
        }
    }
}

extension LegacyAPConfigurationCell: SecureEntryTextFieldDelegate {
    func valueChanged(sender: SecureEntryTextField) {
        updateCellModel()
        setColorState()
    }
}

extension LegacyAPConfigurationCell: StatusBarDelegate {
    func inUseTitleTapped() {
        //print("Title tapped")
    }
    
    func inUseChanged(inUse: Bool) {
        updateCellModel()
        setColorState()
    }
}

