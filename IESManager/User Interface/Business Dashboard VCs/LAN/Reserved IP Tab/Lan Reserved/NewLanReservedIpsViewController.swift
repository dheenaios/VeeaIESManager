//
//  NewLanReservedIpsViewController.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 20/04/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit

protocol NewLanReservedIpsViewControllerDelegate {
    func didCreateNewItem(model: NodeLanStaticIpModel, lan: Int)
}


class NewLanReservedIpsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var newConfig = NodeLanStaticIpModel()
    
    var lanNumber: Int? // 0 rated (Lan 1 is 0)
    var delegate: NewLanReservedIpsViewControllerDelegate?
    
    
    // MARK: - Page presentation
    
    @IBAction func doneTapped(_ sender: Any) {
        if let errors = validationErrors() {
            showInfoAlert(title: "Validation Issues".localized(), message: errors)
            return
        }
        
        delegate?.didCreateNewItem(model: newConfig, lan: lanNumber ?? 0)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func validationErrors() -> String? {
        // The device name OR the device mac is required
        // And the IP address
        
        if newConfig.mac.isEmpty && newConfig.host.isEmpty {
            return "Device Name or MAC Address required".localized()
        }
        
        if newConfig.ip.isEmpty {
            return "An IP is required".localized()
        }
        
        var message = ""
        message.append(LanReservedIPsViewModel.validateAgainstDHCPSettings(hostIpAddress: newConfig.ip, lanNumber: lanNumber ?? 0))
        
        if !newConfig.mac.isEmpty {
            let valid = AddressAndPortValidation.isMacAddressValid(string: newConfig.mac)
            if !valid {
                message.append("\nInvalid MAC Address".localized())
            }
        }
        
        return message.isEmpty ? nil : message
    }
}

extension NewLanReservedIpsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewStaticIpCell
        cell.delegate = self
        cell.lanNumber = lanNumber
        
        return cell
    }
}

extension NewLanReservedIpsViewController: NewStaticIpCellDelegate {
    func changed(cell: NewStaticIpCell) {
        if let text = cell.deviceName.text { newConfig.host = text }
        if let text = cell.assignedIp.text { newConfig.ip = text }
        if let text = cell.deviceMacAddress.text { newConfig.mac = text }
        if let text = cell.comment.text { newConfig.name = text }
        newConfig.use = cell.activeSwitch.isOn
    }
}

class NewStaticIpCell: UITableViewCell {
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var deviceName: TitledTextField!
    @IBOutlet weak var deviceMacAddress: TitledTextField!
    @IBOutlet weak var assignedIp: TitledTextField!
    @IBOutlet weak var comment: TitledTextView!
    var lanNumber: Int?
    
    fileprivate var delegate: NewStaticIpCellDelegate? {
        didSet {
            deviceName.delegate = self
            deviceMacAddress.delegate = self
            assignedIp.delegate = self
            assignedIp.setKeyboardType(type: .decimalPad)
            comment.delegate = self
        }
    }
}

extension NewStaticIpCell: TitledTextFieldDelegate, TitledTextViewDelegate {
    func textDidChange(sender: TitledTextField) {
        if sender === assignedIp {
            assignedIp.setErrorLabel(message: LanReservedIPsViewModel.validateAgainstDHCPSettings(hostIpAddress: sender.text ?? "", lanNumber: lanNumber ?? 0))
        }
        if sender === deviceName {
            if sender.text == nil || sender.text!.isEmpty {
                sender.setErrorLabel(message: "")
            }
        }
        if sender === deviceMacAddress {
            let valid = AddressAndPortValidation.isMacAddressValid(string: sender.text ?? "")
            sender.setErrorLabel(message: valid ? "" : "Invalid MAC address".localized())
        }
        
        delegate?.changed(cell: self)
    }
    
    func textDidChange(sender: TitledTextView) {
        delegate?.changed(cell: self)
    }
}

fileprivate protocol NewStaticIpCellDelegate {
    func changed(cell: NewStaticIpCell)
}
