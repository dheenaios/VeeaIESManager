//
//  IPConfigurationViewController.swift
//  IESManager
//
//  Created by richardstockdale on 15/03/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class IPConfigViewController: BaseConfigViewController {

    @IBOutlet weak var ipAddress: UILabel!
    @IBOutlet weak var gateway: UILabel!
    @IBOutlet weak var delegatePrefixField: TitledTextField!
    @IBOutlet weak var menMeshAddressField: TitledTextField!
    @IBOutlet weak var internalPrefixField: TitledTextField!
    @IBOutlet weak var primaryDnsField: TitledTextField!
    @IBOutlet weak var secondaryDnsField: TitledTextField!
    
    let vm = IPConfigViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        primaryDnsField.textField.addTarget(self,
                                            action: #selector(textFieldChanged(field:)),
                                            for: .editingChanged)
        secondaryDnsField.textField.addTarget(self,
                                              action: #selector(textFieldChanged(field:)),
                                              for: .editingChanged)

        DispatchQueue.main.async {
            self.setLabels()
        }
    }
    
    @objc private func textFieldChanged(field: UITextField) {
        highlightDNSErrors()
    }
    
    private func setLabels() {
        var ipAddr = self.vm.ipAddr
        if ipAddr.isEmpty {
            ipAddr = "(no IP address)"
        }
        self.ipAddress.text = ipAddr
        
        var gatewayString = self.vm.selectedGateway
        if gatewayString.isEmpty {
            gatewayString = "no"
        }
        self.gateway.text = "(\(gatewayString) gateway)"
    
        delegatePrefixField.text = self.vm.delegatePrefix
        menMeshAddressField.text = self.vm.meshAddr
        primaryDnsField.text = self.vm.pDns
        secondaryDnsField.text = self.vm.sDns
        internalPrefixField.text = self.vm.intPrefix
    }
    
    override func applyConfig() {
        if sendingUpdate == true || !validateDNS() {
            return
        }
        
        sendingUpdate = true
        updateUpdateIndicatorState(state: .uploading)
        
        vm.delegatePrefix = delegatePrefixField.text!
        vm.meshAddr = menMeshAddressField.text!
        vm.pDns = primaryDnsField.text!
        vm.sDns = secondaryDnsField.text!
        vm.intPrefix = internalPrefixField.text!
        
        vm.update { [weak self] (result, error) in
            self?.sendingUpdate = false
            
            if error != nil {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                self?.showErrorUpdatingAlert(error: error!)
                
                return
            }
            
            HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
        }
    }
}

// MARK: - Updating
extension IPConfigViewController: HubDataModelProgressDelegate {
    func updateDidComplete(success: Bool, message: String?) {
        updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}

// MARK: - Validation
extension IPConfigViewController {
    private func highlightDNSErrors() {
        self.primaryDnsField.textField.textColor = vm.dnsValid(value: primaryDnsField.text) ? UIColor.darkText : UIColor.red
        self.secondaryDnsField.textField.textColor = vm.dnsValid(value: secondaryDnsField.text) ? UIColor.darkText : UIColor.red
    }
    
    private func validateDNS() -> Bool{
        highlightDNSErrors()
        
        let title = "Invalid DNS Setting"
        var message = ""
        
        if !vm.dnsValid(value: primaryDnsField.text) {
            message.append("Primary DNS In Error")
        }
        if !vm.dnsValid(value: secondaryDnsField.text) {
            if !message.isEmpty {
                message.append("\n")
            }
            
            message.append("Secondary DNS In Error")
        }
        
        if !message.isEmpty {
            message.append("\nPlease correct and tap apply again")
            showInfoAlert(title: title, message: message)
        }
        
        return message.isEmpty
    }
}
