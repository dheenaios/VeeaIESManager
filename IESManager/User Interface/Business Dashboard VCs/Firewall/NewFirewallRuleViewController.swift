//
//  NewFirewallRuleViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 28/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

protocol NewFirewallRuleCreationProtocol {
    func createNewFireWall(rule: FirewallRule)
    func checkForwardPortsValid(rule: FirewallRule) -> Bool
}

class NewFirewallRuleViewController: UIViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .firewall_settings_screen

    
    var delegate: NewFirewallRuleCreationProtocol?
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var actionGroupView: UIView!
    @IBOutlet weak var actionControl: VeeaSegmentedControl!
    @IBOutlet weak var protocolControl: VeeaSegmentedControl!
    
    @IBOutlet weak var localIpField: TitledTextField!
    @IBOutlet weak var portOrPortRangeField: TitledTextField!
    @IBOutlet weak var localPortField: TitledTextField!
    
    private var rule: FirewallRule?
    private var isFwd = false
    
    private var selectedActionType: FirewallRule.FirewallRuleActionType {
        get {            
            switch actionControl.selectedSegmentIndex {
            case 0:
                return .ACCEPT
            case 1:
                return .DROP
            default:
                return .FORWARD
            }
        }
    }
    
    public func configure(rule: FirewallRule, isFwd: Bool) {
        self.rule = rule
        
        // If FWD then hide the action control segmented
        self.isFwd = isFwd
        if isFwd { rule.ruleActionType = .FORWARD }
        else { rule.ruleActionType = .ACCEPT }
    }
    
    private func changeFieldsBasedOnType() {
        switch selectedActionType {
        case .FORWARD:
            setUiToFwd()
        default:
            setUiToAcceptDeny()
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createTapped(_ sender: Any) {
        guard let rule = rule else {
            dismiss(animated: true, completion: nil)
            return
        }

        // Check that forward port rules are uniquw
        if rule.ruleActionType == .FORWARD {
            if !delegate!.checkForwardPortsValid(rule: rule) {
                showInfoAlert(title: "Invalid Rule".localized(),
                              message: "Two or more of your forward rules use the same port and protocol. Make sure ports are unique.\n".localized())

                return
            }
        }

        if let error = AddressAndPortValidation.validateRule(rule: rule) {
            showInfoAlert(title: "Invalid Rule".localized(), message: error)
            
            return
        }
        
        delegate?.createNewFireWall(rule: rule)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        portOrPortRangeField.setKeyboardType(type: .decimalPad)
        localIpField.setKeyboardType(type: .decimalPad)
        localPortField.setKeyboardType(type: .decimalPad)
        
        portOrPortRangeField.textField.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        localIpField.textField.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        localPortField.textField.addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        
        portOrPortRangeField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        localIpField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        localPortField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.title = isFwd ? "Create Forward Rule".localized() : "Create Accept Rule".localized()
        
        
        if HubDataModel.shared.isMN {
            actionControl.selectedSegmentIndex = 0
            actionControl.removeSegment(at: 2, animated: false)
        }
        else {
            actionControl.selectedSegmentIndex = isFwd ? 2 : 0
        }
        
        changeFieldsBasedOnType()
        setValuesFromRule()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
}

// MARK: - Population
extension NewFirewallRuleViewController {
    private func setValuesFromRule() {
        guard let rule = rule else {
            return
        }
        
        if rule.ruleActionType == .FORWARD {
            portOrPortRangeField.text = rule.mPort
            localIpField.text = rule.mSource
            localPortField.text = rule.mLocalPort
        }
        else {
            portOrPortRangeField.text = rule.mPort
            localIpField.text = rule.mSource
        }
    }
}

// MARK: - Accessory Views
extension NewFirewallRuleViewController {
    
    
    // TODO: THis needs to be called when the type changes
    @objc func editingDidBegin(_ sender: UITextField) {
        switch sender {
        case portOrPortRangeField.textField: // Port
            updatePortOrRangeAccessoryView()
            break
        case localIpField.textField: // IP
            updateSourceIPFieldAccessoryView()
            break
        default:
            sender.inputAccessoryView = UIView()
            break
            
        }
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        guard let newText = sender.text else {
            return
        }
        
        var darkModeColor = UIColor.darkText
        darkModeColor = .label
        
        switch sender {
        case portOrPortRangeField.textField: // Port
            sender.textColor = AddressAndPortValidation.isPortRangeValid(string: newText) ? darkModeColor : UIColor.red
            updatePortOrRangeAccessoryView()
            break
        case localIpField.textField: // IP
            if AddressAndPortValidation.isValidPlaceholderRoute(cidr: newText) {
                sender.textColor = darkModeColor
            }
            else if AddressAndPortValidation.ipAndSubnetError(string: newText) != nil {
                sender.textColor = UIColor.red
            }
            else {
                sender.textColor = darkModeColor
            }

            updateSourceIPFieldAccessoryView()
            
            break
        case localPortField.textField: // Source IP / Local Port
            
            if rule?.ruleActionType == .FORWARD {
                sender.textColor = AddressAndPortValidation.isPortRangeValid(string: newText) ? darkModeColor : UIColor.red
            }
            else {
                sender.textColor = AddressAndPortValidation.isIPValid(string: newText) ? darkModeColor : UIColor.red
            }
            break
        default:
            break
        }
        
        updateRuleWithTextChanges()
    }
}

// MARK: - Accessory Views
extension NewFirewallRuleViewController {
    private func updateSourceIPFieldAccessoryView() {
        guard let rule = rule else {
            return
        }
        
        let toolBar = accessoryToolBar(field: localIpField.textField)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        if rule.ruleActionType == .FORWARD {
            toolBar.setItems([flexSpace], animated: true)
            return
        }
        
        let forwardSlashButton = UIBarButtonItem(title: " / (Add subnet prefix)".localized(),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(forwardSlashButtonTapped))
        
        forwardSlashButton.setTitleTextAttributes([.foregroundColor: UIColor.vPurple], for: .normal)
        
        toolBar.setItems([flexSpace, forwardSlashButton, flexSpace], animated: true)
    }
    
    private func updatePortOrRangeAccessoryView() {

        let toolBar = accessoryToolBar(field: portOrPortRangeField.textField)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let button = UIBarButtonItem(title: " : (Add port range)".localized(),
                                     style: .plain,
                                     target: self,
                                     action: #selector(portRangeButtonTapped))
        button.setTitleTextAttributes([.foregroundColor: UIColor.vPurple], for: .normal)
        toolBar.setItems([flexSpace, button, flexSpace], animated: true)
    }
        
    @objc private func rangeButtonTapped() {
        let text = localIpField.text!
        
        if text.contains("/") == true {
            return
        }
        
        localIpField.text = text + "/"
    }
    
    @objc private func portRangeButtonTapped() {
        let text = portOrPortRangeField.text!

        if text.contains(":") == true {
            return
        }

        portOrPortRangeField.text = text + ":"
    }
    
    private func accessoryToolBar(field: UITextField) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolBar.barStyle = .default
        field.inputAccessoryView = toolBar
        
        return toolBar
    }
        
    @objc private func forwardSlashButtonTapped() {
        let text = localIpField.text!
        
        if text.contains("/") == true {
            return
        }
        
        localIpField.text = text + "/"
    }
}

// MARK: - Updating
extension NewFirewallRuleViewController {
    private func updateRuleWithTextChanges() {
        guard let rule = rule else {
            return
        }
        
        updateRuleState(state: .UPDATE)
        
        if rule.ruleActionType == .FORWARD {
            rule.mPort = portOrPortRangeField.text
            rule.mSource = localIpField.text
            rule.mLocalPort = localPortField.text
        }
        else {
            rule.mPort = portOrPortRangeField.text
            rule.mSource = localIpField.text
        }
    }
    
    public func updateRuleState(state: FirewallRule.FirewallRuleUpdateState) {
        guard let rule = rule else {
            return
        }
        
        rule.mUpdateState = state
    }
    
    @IBAction func ruleTypeChanged(_ sender: Any) {
        changeFieldsBasedOnType()
        rule?.ruleActionType = selectedActionType
        
        switch selectedActionType {
        case .FORWARD:
            self.title = "Create Forward Rule".localized()
            break
        case .ACCEPT:
            self.title = "Create Accept Rule".localized()
        case .DROP:
            self.title = "Create Drop Rule".localized()
        }
    }
    
    @IBAction func protocolChanged(_ sender: Any) {
        guard let rule = rule else {
            return
        }
        
        let selectedProtocolIndex = protocolControl.selectedSegmentIndex
        rule.mProtocol = selectedProtocolIndex == 0 ? "tcp" : "udp"
    }
}

// MARK: - UI
extension NewFirewallRuleViewController {
    private func setUiToAcceptDeny() {
        hideLocalPort(hidden: true)
        
        portOrPortRangeField.title = "PORT OR PORT RANGE (P1:P2)".localized().uppercased()
        portOrPortRangeField.placeholderText = "e.g. 100:123".localized()
        
        localIpField.title = "Source (CIDR)".localized().uppercased()
    }
    
    private func setUiToFwd() {
        hideLocalPort(hidden: false)
        
        portOrPortRangeField.title = "PORT OR PORT RANGE (P1:P2)".localized().uppercased()
        portOrPortRangeField.placeholderText = "e.g. 100:123".localized()
        
        localIpField.title = "LOCAL IP".localized().uppercased()
        localPortField.title = "LOCAL PORT".localized().uppercased()
        
    }
    
    private func hideLocalPort(hidden: Bool) {
        localPortField.isHidden = hidden
    }
}
