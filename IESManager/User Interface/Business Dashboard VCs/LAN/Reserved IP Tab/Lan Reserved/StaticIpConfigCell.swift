//
//  StaticIpConfigCell.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 20/04/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit

// MARK: - StaticIpConfigCell

class StaticIpConfigCell: UITableViewCell {
    private var lanNumber: Int = -1
    private var resNumber = -1
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var clearFields: CurvedButton!
    
    @IBOutlet weak var deviceName: TitledTextField!
    @IBOutlet weak var deviceMacAddress: TitledTextField!
    @IBOutlet weak var assignedIp: TitledTextField!
    @IBOutlet weak var comment: TitledTextView!
    
    private weak var hostVc: LanReservedIPsViewController?
    
    private var configModel: NodeLanStaticIpModel?
        
    @IBAction func activeSwitchChanged(_ sender: UISwitch) {
        updateConfig()
        readOnly(readonly: !sender.isOn)
    }
    
    @IBAction func clearFieldsTapped(_ sender: Any) {
        deviceName.text = ""
        deviceMacAddress.text = ""
        assignedIp.text = ""
        comment.text = ""
        activeSwitch.isOn = false
        
        updateConfig()
        readOnly(readonly: true)
        updateClearFieldsButton()
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        let a = UIAlertController(title: "Delete".localized(),
                                  message: "Are you sure you want to delete this Reserved IP".localized(),
                                  preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        a.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { (action) in
            self.doDelete()
        }))
        
        hostVc?.present(a, animated: true, completion: nil)
    }
    
    private func doDelete() {
        guard let model = configModel else { return }
        
        hostVc?.deleteItem(configModel: model,
                           selectedLan: lanNumber,
                           reservationNumber: resNumber)
    }
    
    private func updateClearFieldsButton() {
        if !activeSwitch.isOn {
            clearFields.isHidden = true
            return
        }
        
        if deviceMacAddress.text!.isEmpty &&
            assignedIp.text!.isEmpty &&
            deviceName.text!.isEmpty &&
            comment.text!.isEmpty {
            clearFields.isHidden = true
            return
        }
        
        clearFields.isHidden = false
    }
    
    public func configure(model: NodeLanStaticIpModel,
                          lan: Int,
                          reservationNumber: Int,
                          hostVc: LanReservedIPsViewController) {
        setTheme()
        lanNumber = lan
        resNumber = reservationNumber
        configModel = model
        self.hostVc = hostVc
        
        readOnly(readonly: !model.use)
        activeSwitch.isOn = model.use
        deviceName.text = configModel?.host
        deviceMacAddress.text = configModel?.mac
        assignedIp.text = configModel?.ip
        assignedIp.placeholderText = "xxx.xxx.xxx.xxx"
        comment.text = configModel?.name
        comment.placeholderText = "Enter a comment".localized()
        
        deviceName.delegate = self
        deviceMacAddress.delegate = self
        assignedIp.delegate = self
        comment.delegate = self
        
        assignedIp.setKeyboardType(type: .decimalPad)
        assignedIp.setErrorLabel(message: LanReservedIPsViewModel.validateAgainstDHCPSettings(hostIpAddress: assignedIp.text ?? "", lanNumber: lanNumber))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    private func setTheme() {
        let c = InterfaceManager.shared.cm
        clearFields.setTitleColor(c.themeTint.colorForAppearance, for: .normal)
        clearFields.borderColor = c.themeTint.colorForAppearance
    }
    
    private func updateConfig() {
        configModel?.use = activeSwitch.isOn
        configModel?.host = deviceName.text ?? ""
        configModel?.mac = deviceMacAddress.text ?? ""
        configModel?.ip = assignedIp.text ?? ""
        configModel?.name = comment.text ?? ""
        
        if configModel == nil { return }
        hostVc?.configDidChange(model: configModel!,
                                lanNumber: lanNumber,
                                reservation: resNumber)
    }
    
    public func readOnly(readonly: Bool) {
        deviceName.readOnly = readonly
        deviceMacAddress.readOnly = readonly
        assignedIp.readOnly = readonly
        comment.readOnly = readonly
        clearFields.isHidden = readonly
        
    }
}

extension StaticIpConfigCell: TitledTextFieldDelegate {
    func textDidChange(sender: TitledTextField) {
        if sender === assignedIp {
            assignedIp.setErrorLabel(message: LanReservedIPsViewModel.validateAgainstDHCPSettings(hostIpAddress: sender.text ?? "", lanNumber: lanNumber))
        }
        if sender === deviceMacAddress {
            if sender.text == nil || sender.text!.isEmpty {
                sender.setErrorLabel(message: "")
            }
            else {
                let valid = AddressAndPortValidation.isMacAddressValid(string: sender.text ?? "")
                sender.setErrorLabel(message: valid ? "" : "Invalid MAC address".localized())
            }
            
        }
        
        updateConfig()
    }
}

extension StaticIpConfigCell: TitledTextViewDelegate {
    func textDidChange(sender: TitledTextView) {
        updateConfig()
    }
}
