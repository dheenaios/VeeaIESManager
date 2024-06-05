//
//  SecurityEditRadiusTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

class SecurityEditRadiusTableViewController: APSecurityBaseTableViewController {
    let vm = SecurityEditRadiusViewModel()
    
    @IBOutlet weak var ipAddressTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var passPhraseTextField: SecureEntryTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Radius".localized()
        passPhraseTextField.textField.placeholder = "Secret".localized()
        passPhraseTextField.textField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        setupUI()
    }
    
    private func setupUI() {
        guard let model = vm.model else { return }
        ipAddressTextField.text = model.address
        portTextField.text = "\(model.port)"
        passPhraseTextField.text = model.secret
        portTextField.placeholder = "\(vm.defaultPort)"
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if sender === ipAddressTextField {
            if vm.validIp(ip: sender.text) {
                ipAddressTextField.textColor = .black
                vm.model?.address = ipAddressTextField.text ?? ""
            }
            else {
                ipAddressTextField.textColor = .red
                vm.model?.address = ""
            }
        }
        else if sender === portTextField {
            if vm.validPort(port: portTextField.text) {
                if let i = Int.init(portTextField.text ?? "\(vm.defaultPort)") {
                    vm.model?.port = i
                }
            }
            else {
                vm.model?.port = vm.defaultPort
            }
        }
        else if sender === passPhraseTextField {
            let passphrase = passPhraseTextField.text
            
            if passphrase.count.between(lowerValue: 1, and: 31) {
                vm.model?.secret = passphrase
                passPhraseTextField.textField.textColor = .black
            }
            else {
                vm.model?.secret = ""
                passPhraseTextField.textField.textColor = .black
            }
        }
    }
    
    @IBAction func clearFieldsTapped(_ sender: Any) {
        ipAddressTextField.text = ""
        portTextField.text = ""
        passPhraseTextField.text = ""
        
        vm.model?.address = ""
        vm.model?.port = vm.defaultPort
        vm.model?.secret = ""
    }
    
    
    @IBAction override func cancelTapped(_ sender: Any) {
        hideKeyboard()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction override func doneTapped(_ sender: Any) {
        hideKeyboard()
        
        if let errorMessage = getEntryErrors() {
            showErrorInfoMessage(message: errorMessage)
        }
        else {
            informUserOfChanges()
        }
    }

    @objc func passwordChanged() {
        let str = passPhraseTextField.text
        
        if vm.validPass(pass: str) {
            passPhraseTextField.textField.textColor = .black
            vm.model?.secret = str
        }
        else {
            passPhraseTextField.textField.textColor = .red
            vm.model?.secret = ""
        }
    }
    
    private func hideKeyboard() {
        ipAddressTextField.resignFirstResponder()
        portTextField.resignFirstResponder()
        passPhraseTextField.textField.resignFirstResponder()
    }
}

// MARK: - Sending
extension SecurityEditRadiusTableViewController {
    private func getEntryErrors() -> String? {
        if vm.validEmptySelection(ssid: ipAddressTextField.text, port: portTextField.text, secret: passPhraseTextField.text) {
    
            if vm.isInUse {
                return "You cannot clear the setting for this server as it is currently in use.".localized()
            }
            if vm.isCurrentlySelected {
                return "You cannot clear the setting for this server as it is currently selected (on the previous screen)".localized()
            }
            
            return nil
        }
        
        var message = ""
        
        // IP
        if !vm.validIp(ip: ipAddressTextField.text) {
            message = message + "IP Address is not valid\n".localized()
        }
        if !vm.validPort(port: portTextField.text) {
            if portTextField.text == nil || portTextField.text!.isEmpty {
                // Then set to the default. No error
            }
            else {
                message = message + "Port must be between 1-65535\n".localized()
            }
        }
        
        // Pass
        if !vm.validPass(pass: passPhraseTextField.text) {
            message = message + "Password invalid. Must be 1 - 31 chars\n".localized()
        }
        
        if message.isEmpty {
            return nil
        }
        
        return message
    }
    
    
    
    private func informUserOfChanges() {
        let message = "Changes made to this entry will apply to all SSIDs using this entry".localized()
        let alert = UIAlertController(title: "Update".localized(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Update".localized(), style: .destructive, handler: { (action) in
            if let t = self.portTextField.text {
                if t.isEmpty { self.vm.model?.port = self.vm.defaultPort }
            }
            
            self.vm.sendUpdate(vc: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
