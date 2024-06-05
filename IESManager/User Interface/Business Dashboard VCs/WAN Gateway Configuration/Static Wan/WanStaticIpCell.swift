//
//  WanStaticIpCell.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 20/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

protocol WanStaticIpCellDelegate {
    func cellUpdateChanged(index: Int, updatedModel: LanWanStaticIpConfig)
}

class WanStaticIpCell: UITableViewCell {
    
    var delegate: WanStaticIpCellDelegate?
    
    @IBOutlet weak var activeSwitch: UISwitch!
    
    @IBOutlet weak var cdirTextField: TitledTextField!
    @IBOutlet weak var gatewayIpTextField: TitledTextField!
    @IBOutlet weak var dns1IpTextField: TitledTextField!
    @IBOutlet weak var dns2IpTextField: TitledTextField!
    private lazy var fields: [TitledTextField] = {
        return [cdirTextField,
                gatewayIpTextField,
                dns1IpTextField,
                dns2IpTextField]
    }()
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var m: LanWanStaticIpConfig?
    
    var cellIndex = -1
    
    var uiEnabled = true {
        didSet {
            let alpha: CGFloat = uiEnabled ? 1.0 : 0.3
            activeSwitch.isEnabled = uiEnabled
            for f in fields {
                f.isUserInteractionEnabled = uiEnabled
                f.alpha = alpha
            }
            
            activeSwitch.alpha = alpha
        }
    }
    
    func populate(model: LanWanStaticIpConfig, cellIndex: Int) {
        uiEnabled = true
        self.cellIndex = cellIndex
        m = model
        
        activeSwitch.isOn = model.use
        
        // VHM-462
        cdirTextField.title = "CDIR".localized()
        cdirTextField.placeholderText = "xxx.xxx.xxx.xxx/xx"
        cdirTextField.text = model.ip4_address
        cdirTextField.setKeyboardType(type: .decimalPad)
        cdirTextField.delegate = self
        cdirTextField.addSubnetEntryAccessory()
        
        gatewayIpTextField.title = "GATEWAY IP".localized()
        gatewayIpTextField.placeholderText = "xxx.xxx.xxx.xxx"
        gatewayIpTextField.text = model.ip4_gateway
        gatewayIpTextField.setKeyboardType(type: .decimalPad)
        gatewayIpTextField.delegate = self
        
        dns1IpTextField.title = "DNS 1".localized()
        dns1IpTextField.placeholderText = "xxx.xxx.xxx.xxx"
        dns1IpTextField.text = model.ip4_dns_1
        dns1IpTextField.setKeyboardType(type: .decimalPad)
        dns1IpTextField.delegate = self
        
        dns2IpTextField.title = "DNS 2".localized()
        dns2IpTextField.placeholderText = "xxx.xxx.xxx.xxx"
        dns2IpTextField.text = model.ip4_dns_2
        dns2IpTextField.setKeyboardType(type: .decimalPad)
        dns2IpTextField.delegate = self
        
        enableFields(enabled: activeSwitch.isOn)
    }
    
    @IBAction func settingChanged(_ sender: Any) {
        enableFields(enabled: activeSwitch.isOn)
        detailsChanged()
    }
    
    private func detailsChanged() {
        guard m != nil else {
            return
        }
        
        m?.use = activeSwitch.isOn
        m?.ip4_address = cdirTextField.text ?? ""
        m?.ip4_gateway = gatewayIpTextField.text ?? ""
        m?.ip4_dns_1 = dns1IpTextField.text ?? ""
        m?.ip4_dns_2 = dns2IpTextField.text ?? ""
        
        validateFieldsAndFeedback()
        delegate?.cellUpdateChanged(index: cellIndex, updatedModel: m!)
    }
    
    /// Validate the fields and show user feedback
    private func validateFieldsAndFeedback() {
        errorLabel.text = ""
        
        if dns1IpTextField.text!.isEmpty &&
            dns2IpTextField.text!.isEmpty &&
            cdirTextField.text!.isEmpty &&
            gatewayIpTextField.text!.isEmpty {
            return
        }
        
        // Check CDIR is valid
        if let reason = cdirInvalidReason {
            errorLabel.text = reason
            return
        }
        if let reason = gatewayInvalidReason {
            errorLabel.text = reason
            return
        }
        if !cdirAndGatewayOnSameSubnet {
            errorLabel.text = "CDIR and Gateway IPs are on different subnets".localized()
            return
        }
        if let reason = dns1InvalidReason {
            errorLabel.text = reason
            return
        }
        
        if let reason = dns2InvalidReason {
            errorLabel.text = reason
            return
        }
        
        if dns1IpTextField.text!.isEmpty && dns2IpTextField.text!.isEmpty {
            errorLabel.text = "Please enter at least 1 DNS Address".localized()
            return
        }
    }
    
    private func enableFields(enabled: Bool) {
        let alpha: CGFloat = enabled ? 1.0 : 0.3
        for f in fields {
            f.isUserInteractionEnabled = enabled
            f.alpha = alpha
        }
    }
}

// MARK: - Validation
extension WanStaticIpCell {
    private var cdirAndGatewayOnSameSubnet: Bool {
        // Check there is a subnet mask on CDIR
        guard let cdir = cdirTextField.text, let gwIp = gatewayIpTextField.text else {
            return true // If they're both empty then lets just say they're the same
        }
        
        if cdir.isEmpty || gwIp.isEmpty {
            return true
        }
        
        let parts = cdir.split(separator: "/")
        if parts.count != 2 {
            return false
        }
        
        let cdirIp = String(parts.first!)
        let cdirMask = Int(parts.last!) ?? -1
        
        if cdirMask == -1 {
            return false
        }
        
        return AddressAndSubnetValidation.areBothIpsOnSameSubnet(ipA: cdirIp, ipB: gwIp, mask: cdirMask)
    }
    
    private var cdirInvalidReason: String? {
        guard let ip = cdirTextField.text else {
            return nil
        }
        
        if ip.isEmpty {
            return nil
        }
        
        if AddressAndSubnetValidation.isAddressAndPrefixValid(addressSubnetString: ip) {
            return nil
        }
        
        return "\("CDIR should follow format".localized()) xxx.xxx.xxx.xxx/xx"
    }
    
    private var gatewayInvalidReason: String? {
        guard let message = ipErrorMessageFor(textField: gatewayIpTextField.textField) else {
            return nil
        }
        
        return "\("Gateway IP".localized()): \(message)"
    }
    
    private var dns1InvalidReason: String? {
        guard let message = ipErrorMessageFor(textField: dns1IpTextField.textField) else {
            return nil
        }
        
        return "\("DNS 1".localized()): \(message)"
    }
    
    private var dns2InvalidReason: String? {
        guard let message = ipErrorMessageFor(textField: dns2IpTextField.textField) else {
            return nil
        }
        
        return "\("DNS 2".localized()): \(message)"
    }
    
    private func ipErrorMessageFor(textField: UITextField) -> String? {
        guard let ip = textField.text else {
            return nil
        }
        
        if ip.isEmpty {
            return nil
        }
        
        if !AddressAndPortValidation.isIPValid(string: ip) {
            return "\("IP should follow format".localized()) xxx.xxx.xxx.xxx"
        }
        
        return nil
    }
}

extension WanStaticIpCell: TitledTextFieldDelegate {
    func textDidChange(sender: TitledTextField) {
        settingChanged(sender)
    }
}
