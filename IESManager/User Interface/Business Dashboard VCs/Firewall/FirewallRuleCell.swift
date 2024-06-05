//
//  FirewallRuleCell.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 17/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

// TODO: Extracted this from FirewallConfigView Controller. Needs to be changed so certain UI elements are not public

import UIKit

protocol FirewallRuleCellProtocol: UIViewController {
    func deleteRule(filewallRule: FirewallRule)
    func ruleChanged(filewallRule: FirewallRule)
}

class FirewallRuleCell: UITableViewCell {
    
    private weak var delegate: FirewallRuleCellProtocol?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var actionRow: KeyValueView!
    @IBOutlet weak var protocolRow: KeyValueView!
    @IBOutlet weak var localIpRow: TitledTextField!
    @IBOutlet weak var portRangeRow: TitledTextField!
    @IBOutlet weak var localPortRow: TitledTextField!
    
    var firewallRule: FirewallRule?
    
    @objc func protocolRowButtonTapped() {
        firewallRule?.mProtocol = firewallRule?.mProtocol?.lowercased() == "tcp" ? "udp" : "tcp"
        updateRuleState(state: .UPDATE)
        updateUI()
        delegate?.ruleChanged(filewallRule: firewallRule!)
    }
    
    @objc func actionRowButtonTapped() {
        firewallRule?.ruleActionType = firewallRule?.actionTypeDescription?.lowercased() == "accept" ? FirewallRule.FirewallRuleActionType.DROP : FirewallRule.FirewallRuleActionType.ACCEPT
        updateRuleState(state: .UPDATE)
        updateUI()
        delegate?.ruleChanged(filewallRule: firewallRule!)
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        guard let vc = delegate,
              let rule = firewallRule else {
            return
        }
        
        let alert = UIAlertController.init(title: "Delete rule".localized(),
                                           message: "Are you sure you want to delete this rule?".localized(),
                                           preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(),
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Delete".localized(),
                                      style: .destructive,
                                      handler: { (action) in
                                        self.delegate?.deleteRule(filewallRule: rule)
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    // TODO: Add the validators to the text field
    @objc private func textFieldDidChange(_ sender: UITextField) {
        guard let newText = sender.text else {
            return
        }
        
        var darkModeColor = UIColor.darkText
        darkModeColor = .label

        switch sender {
        case portRangeRow.textField: // Port
            sender.textColor = AddressAndPortValidation.isPortRangeValid(string: newText) ? UIColor.black : UIColor.red
            updatePortOrRangeAccessoryView()
            break
        case localIpRow.textField: // IP
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
        case localPortRow.textField: // Local Port
            sender.textColor = AddressAndPortValidation.isPortRangeValid(string: newText) ? UIColor.black : UIColor.red
            break
        default:
            break
        }

        updateRuleWithTextChanges()
        delegate?.ruleChanged(filewallRule: firewallRule!)
    }
    
    private func updateRuleWithTextChanges() {
        guard let rule = firewallRule else {
            return
        }
        
        updateRuleState(state: .UPDATE)
        
        if rule.ruleActionType == .FORWARD {
            rule.mPort = portRangeRow.text
            rule.mSource = localIpRow.text
            rule.mLocalPort = localPortRow.text
        }
        else {
            rule.mPort = portRangeRow.text
            rule.mSource = localIpRow.text
        }
    }
    
    public func configure(rule: FirewallRule, delegate: FirewallRuleCellProtocol?) {
        self.delegate = delegate
        
        firewallRule = rule
        
        localIpRow.setKeyboardType(type: .decimalPad)
        portRangeRow.setKeyboardType(type: .decimalPad)
        localPortRow.setKeyboardType(type: .decimalPad)
        
        portRangeRow.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        localIpRow.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        localPortRow.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        updateUI()
    }
    
    public func updateUI() {
        
        guard let rule = firewallRule else {
                return
        }
        
        protocolRow.setUp(key: "Protocol".localized(),
                          value: rule.mProtocol!.uppercased(),
                          showLowerSep: true,
                          showUpperSep: false,
                          hostViewController: nil,
                          questionText: nil)
        protocolRow.button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                       action: #selector(protocolRowButtonTapped)))
        
        actionRow.setUp(key: "Action".localized(),
                        value: rule.actionTypeDescription!.capitalizingFirstLetter(),
                        showLowerSep: true,
                        showUpperSep: false,
                        hostViewController: nil,
                        questionText: nil)
        actionRow.button.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(actionRowButtonTapped)))
        
        // Configure the view for action selection
        if rule.ruleActionType == .FORWARD {
            localIpRow.title = "LOCAL IP".localized()
            portRangeRow.title = "PORT OR PORT RANGE (P1:P2)".localized()
            localPortRow.title = "LOCAL PORT".localized()
            
            localIpRow.textField.inputAccessoryView = nil
            localPortRow.isHidden = false
            actionRow.isHidden = true
        }
        else {
            localPortRow.isHidden = true
            
            portRangeRow.title = "PORT OR PORT RANGE (P1:P2)".localized()
            portRangeRow.placeholderText = "e.g. 100:123".localized()
            localIpRow.title = "Source (CIDR)".localized()
            actionRow.isHidden = false
        }
        
        // Set the bottom row info
        if rule.ruleActionType == .FORWARD {
            portRangeRow.text = rule.mPort
            localIpRow.text = rule.mSource
            localPortRow.text = rule.mLocalPort
        }
        else {
            portRangeRow.text = rule.mPort
            localIpRow.text = rule.mSource
        }
        
        updatePortOrRangeAccessoryView()
        updateSourceIPFieldAccessoryView()
    }
    
    // MARK: - Accessory Views
    
    private func updateSourceIPFieldAccessoryView() {
        guard let rule = firewallRule else {
                return
        }
    
        let toolBar = accessoryToolBar(field: localIpRow.textField)
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
    
    @objc private func forwardSlashButtonTapped() {
        let text = localIpRow.text!
        if text.contains("/") == true { return }
        localIpRow.text = text + "/"
    }
    
    private func updatePortOrRangeAccessoryView() {
        let toolBar = accessoryToolBar(field: portRangeRow.textField)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(title: " : (Add port range)".localized(),
                                     style: .plain,
                                     target: self,
                                     action: #selector(portRangeButtonTapped))
        button.setTitleTextAttributes([.foregroundColor: UIColor.vPurple], for: .normal)
        toolBar.setItems([flexSpace, button, flexSpace], animated: true)
    }
    
    @objc private func rangeButtonTapped() {
        let text = localIpRow.text!
        if text.contains("/") == true { return }
        localIpRow.text = text + "/"
    }
    
    @objc private func portRangeButtonTapped() {
        let text = portRangeRow.text!

        if text.contains(":") == true {
            return
        }

        portRangeRow.text = text + ":"
    }
    
    private func accessoryToolBar(field: UITextField) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolBar.barStyle = .default
        field.inputAccessoryView = toolBar
        
        return toolBar
    }
    
    public func updateRuleState(state: FirewallRule.FirewallRuleUpdateState) {
        guard let rule = firewallRule else {
            return
        }
        
        rule.mUpdateState = state
    }
}
