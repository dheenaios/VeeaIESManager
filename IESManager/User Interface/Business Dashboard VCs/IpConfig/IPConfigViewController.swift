//
//  IPConfigurationViewController.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 15/03/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class IPConfigViewController: BaseConfigViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .ip_address_settings_screen

    var flowController: HubInteractionFlowController?

    @IBOutlet weak var ipAddress: UILabel!
    @IBOutlet weak var gateway: UILabel!
    @IBOutlet weak var delegatePrefixField: TitledTextField!
    @IBOutlet weak var menMeshAddressField: TitledTextField!
    @IBOutlet weak var internalPrefixField: TitledTextField!
    
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    private var viewsToHide: [UIView] {
        return [delegatePrefixField,
                menMeshAddressField]
    }
    
    let vm = IPConfigViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "IP Address".localized()
        inlineHelpView.setText(labelText: "This page shows the IP address of the VeeaHub. If the VeeaHub is configured as a MEN, it also shows the backhaul type.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }

        DispatchQueue.main.async {
            self.setLabels()
            self.setVisibleViews()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .ip_address, push: true)
    }
    
    private func setVisibleViews() {
        if vm.showOnlyInternalPrefix {
            for v in viewsToHide {
                v.isHidden = true
            }
        }
    }

    private func setLabels() {
        var ipAddr = self.vm.ipAddr
        if ipAddr.isEmpty {
            ipAddr = "(no IP address)".localized()
        }
        self.ipAddress.text = ipAddr
        
        var gatewayString = self.vm.selectedGateway
        if gatewayString.isEmpty {
            gatewayString = "no"
        }
        self.gateway.text = "(\(gatewayString) gateway)"
    
        delegatePrefixField.text = self.vm.delegatePrefix
        menMeshAddressField.text = self.vm.meshAddr
        internalPrefixField.text = self.vm.intPrefix
        
        delegatePrefixField.delegate = self
        menMeshAddressField.delegate = self
        internalPrefixField.delegate = self
        internalPrefixField.readOnly = true
    }
    
    override func applyConfig() {
        if sendingUpdate == true || !validateDNS() {
            return
        }
        
        sendingUpdate = true
        updateUpdateIndicatorState(state: .uploading)
        
        vm.delegatePrefix = delegatePrefixField.text!
        vm.meshAddr = menMeshAddressField.text!
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
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}

// MARK: - Validation
extension IPConfigViewController {
    
    private func validateDNS() -> Bool{
        let title = "Invalid DNS Setting".localized()
        var message = ""
        
        if !message.isEmpty {
            message.append("\nPlease correct and tap apply again".localized())
            showInfoAlert(title: title, message: message)
        }
        
        return message.isEmpty
    }
}

extension IPConfigViewController: TitledTextFieldDelegate {
    func textDidChange(sender: TitledTextField) {
        if sender === delegatePrefixField {
            vm.delegatePrefix = delegatePrefixField.text!
        }
        if sender === menMeshAddressField {
            vm.meshAddr = menMeshAddressField.text!
        }
        if sender === internalPrefixField {
            vm.intPrefix = internalPrefixField.text!
        }
        
        applyButtonIsHidden = !vm.hasConfigChanged()
    }
}
