//
//  SecurityRuleCreateEditViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 28/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

protocol SecurityRuleCreateEditCompletionDelegate: AnyObject {
    func completedWithChanges(rule: FirewallRule)
}

class SecurityRuleCreateEditViewController: HomeUserBaseViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .home_security_settings_screen

    
    let vm = SecurityRuleCreateEditViewModel()
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var actionTypeSelector: TitledRadioButtonContainer!
    @IBOutlet weak var protocolTypeSelector: TitledRadioButtonContainer!
    @IBOutlet weak var cidrTextField: CurvedTextEntryField!
    
    @IBOutlet weak var startPort: CurvedTextEntryField!
    
    @IBOutlet weak var endPortContainer: UIView!
    @IBOutlet weak var endPort: CurvedTextEntryField!
    
    @IBOutlet weak var destinationPort: CurvedTextEntryField!
    @IBOutlet weak var showPortRangeSwitch: UISwitch!
    
    
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var viewTitle: UINavigationItem!
    @IBOutlet weak var doneButton: CurvedButton!
    @IBOutlet weak var deleteButton: CurvedButton!
    
    weak var delegate: SecurityRuleCreateEditCompletionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.populate()
        setupUi()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    static func new() -> SecurityRuleCreateEditViewController {
        let vc = UIStoryboard(name: StoryboardNames.SecuritySettings.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SecurityRuleCreateEditViewController") as! SecurityRuleCreateEditViewController
        return vc
    }
    
    private func setupUi() {
        actionTypeSelector.setStackViewAxis(axis: .vertical)
        actionTypeSelector.titleLabel.text = "Action Type".localized()
        actionTypeSelector.setTitles(SecurityRuleCreateEditViewModel.ActionType.optionText)
        actionTypeSelector.selectedIndex = vm.selectedActiontype.rawValue
        actionTypeSelector.delegate = self
        
        actionTypeSelector.disableView(disabled: !vm.actionTimePanelActive)
        
        protocolTypeSelector.setStackViewAxis(axis: .horizontal)
        protocolTypeSelector.titleLabel.text = "Protocols".localized()
        protocolTypeSelector.setTitles(SecurityRuleCreateEditViewModel.ProtocolType.optionText)
        protocolTypeSelector.selectedIndex = vm.selectedProtocolType.rawValue
        protocolTypeSelector.delegate = self
        
        cidrTextField.infoLabel.text = "Source (CIDR)".localized()
        cidrTextField.textField.placeholder = "optional".localized()
        cidrTextField.textField.keyboardType = .decimalPad
        
        startPort.infoLabel.text = "Port".localized()
        startPort.textField.placeholder = "required".localized()
        startPort.textField.keyboardType = .numberPad
        
        endPort.infoLabel.text = "End Port".localized()
        endPort.textField.placeholder = "required".localized()
        endPort.textField.keyboardType = .numberPad
        
        showPortRangeSwitch.isOn = vm.showEndPort
        
        destinationPort.infoLabel.text = "Destination Port".localized()
        destinationPort.textField.placeholder = "required".localized()
        
        doneButton.setTitle(vm.doneButtonText, for: .normal)
        viewTitle.title = vm.doneButtonText
        deleteButton.isHidden = !vm.showDelete
        
        updateUi()
    }
    
    override func setTheme() {
        super.setTheme()
        
        deleteButton.setTitleColor(cm.statusRed.colorForAppearance, for: .normal)
        deleteButton.borderColor = cm.statusRed.colorForAppearance
        deleteButton.fillColor = .clear
        deleteButton.titleLabel?.font = FontManager.bigButtonText
        
        setNavigationBarAttributes(navigationBar: naviBar,
                                   color: cm.background2.colorForAppearance,
                                   transparent: true)
    }
    
    private func updateUi() {
        cidrTextField.textField.text = vm.cidrText
        startPort.textField.text = vm.startPortText
        endPort.textField.text = vm.endPortText
        destinationPort.textField.text = vm.destinationPortText
        
        updatePortsUi()
    }
    
    // Update the port UI with animation
    private func updatePortsUi() {
        UIView.animate(withDuration: 0.3) {
            self.updatePortPresentation()
            self.view.layoutIfNeeded()
        }
    }
    
    private func updatePortPresentation() {
        if self.endPortContainer.isHidden != !self.vm.showEndPort {
            self.endPortContainer.isHidden = !self.vm.showEndPort
        }

        // Display destination if needed
        if self.destinationPort.isHidden != !self.vm.showDestinationPort {
            self.destinationPort.isHidden = !self.vm.showDestinationPort
        }

        // Set the starting port title depending on action type
        if self.vm.selectedActiontype == .forward {
            self.startPort.infoLabel.text = "Source Port".localized()
        }
        else {
            self.startPort.infoLabel.text = self.vm.showEndPort ? "Start Port".localized() : "Port".localized()
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func portRangeSwitchChanged(_ sender: Any) {
        vm.showEndPort = showPortRangeSwitch.isOn
        updatePortPresentation()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        updateRule()
        
        if let validationIssue = vm.validationIssues {
            showInfoAlert(title: "Invalid Rule".localized(), message: validationIssue)
            return
        }
        
        dismiss(animated: true) { [self] in
            self.delegate?.completedWithChanges(rule: self.vm.rule!)
        }
    }
    
    private func updateRule() {
        vm.rule!.ruleActionType = vm.selectedActiontype.equivelentFirewallActionType
        vm.rule!.mProtocol = vm.selectedProtocolType.stringValueForSending
        
        let startPortText = startPort.textField.text!
        var endPortText: String?
        if showPortRangeSwitch.isOn && endPort.textField.text != nil && !endPort.textField.text!.isEmpty {
            endPortText = endPort.textField.text
        }
        
        if vm.rule!.ruleActionType == .FORWARD {
            vm.rule!.mLocalPort = destinationPort.textField.text ?? ""
        }
        vm.rule!.mSource = cidrTextField.textField.text ?? ""
        vm.rule!.setPortRange(start: startPortText, end: endPortText)
        
        if vm.mode == .new {
            vm.rule?.mUpdateState = .NEW
        }
        else {
            vm.rule?.mUpdateState = .UPDATE
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // Confirm
        let alert = UIAlertController(title: "Delete".localized(),
                                      message: "Are you sure you want to delete this rule".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { action in
            self.dismiss(animated: true) { [self] in
                self.vm.rule?.mUpdateState = .DELETE
                self.delegate?.completedWithChanges(rule: self.vm.rule!)
            }
        }))
        
        present(alert, animated: true)
    }
}

extension SecurityRuleCreateEditViewController: TitledRadioButtonContainerDelegage {
    func didSelectItemAt(index: Int, in radioButtonContainer: TitledRadioButtonContainer) {
        if radioButtonContainer === actionTypeSelector {
            vm.selectedActiontype = SecurityRuleCreateEditViewModel.ActionType(rawValue: index)!
        }
        else {
            vm.selectedProtocolType = SecurityRuleCreateEditViewModel.ProtocolType(rawValue: index)!
        }
        
        updateUi()
    }
}
