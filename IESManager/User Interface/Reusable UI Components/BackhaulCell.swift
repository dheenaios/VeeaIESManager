//
//  BackhaulCell.swift
//  VeeaHub Manager
//
//  Created by Al on 10/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit


typealias BackhaulCellToggleCallback = (_ allowToggle: Bool) -> Void

protocol BackhaulCellDelegate {
    func enabledChanged(to: Bool, cell: BackhaulCell, completion: @escaping BackhaulCellToggleCallback)
    func restrictedChanged(to: Bool, cell: BackhaulCell, completion: @escaping BackhaulCellToggleCallback)
}

class BackhaulCell: UITableViewCell {
    let stateController = BackhaulStateController()
    
    @IBOutlet weak var labelIpAddressValue: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    @IBOutlet weak var restrictedSwitch: UISwitch!
    
    var lock: GatewayLock!
    var delegate: BackhaulCellDelegate?

    func fillWith(lock: GatewayLock, isMN: Bool) {
        self.lock = lock
        
        setTitle(lock: lock)
        
        guard let backhaulType = lock.backhaulType else {
            enableDisableForMN(isMN: true)
            return
        }
        
        icon.image = stateController.getIconFor(type: backhaulType)
        enableDisableForMN(isMN: isMN)
        
        if !stateController.isEnabledFor(type: backhaulType) {
            setCellDisabled()
        }
    }
    
    private func setTitle(lock: GatewayLock) {
        let title = lock.title
        labelIpAddressValue.isHidden = true
        if title == "Wifi" {
            label.text = "Wi-Fi"
        }
        else {
            label.text = title
        }
        
        if HubDataModel.shared.hasCellularIpv4AddrAndWifiIpv4Addr() {
            if title == "Ethernet" {
                if HubDataModel.shared.getEthernetIPAddressValue() != "" {
                    labelIpAddressValue.isHidden = false
                    labelIpAddressValue.text = HubDataModel.shared.getEthernetIPAddressValue()
                }
            }
            else if title == "Cellular" {
                if HubDataModel.shared.getCellularIPAddressValue() != "" {
                    labelIpAddressValue.isHidden = false
                    labelIpAddressValue.text = HubDataModel.shared.getCellularIPAddressValue()
                }
            }
            else if title == "Wifi" {
                if HubDataModel.shared.getWifiIPAddressValue() != "" {
                    labelIpAddressValue.isHidden = false
                    labelIpAddressValue.text = HubDataModel.shared.getWifiIPAddressValue()
                }
            }
            else {
                labelIpAddressValue.isHidden = true
            }
        }
    }
    
    private func enableDisableForMN(isMN: Bool) {
        if !isMN {
            enabledSwitch.addTarget(self, action: #selector(enabledValueChanged), for: .valueChanged)
            restrictedSwitch.addTarget(self, action: #selector(restrictedValueChanged), for: .valueChanged)
        }
        enabledSwitch.setOn(!lock.locked, animated: true)
        restrictedSwitch.setOn(lock.restricted, animated: true)
        
        if isMN {
            setCellDisabled()
        }
    }
    
    private func setCellDisabled() {
        enabledSwitch.onTintColor = UIColor.lightGray
        enabledSwitch.isUserInteractionEnabled = false
        restrictedSwitch.onTintColor = UIColor.lightGray
        restrictedSwitch.isUserInteractionEnabled = false
        isUserInteractionEnabled = false
    }
    
    @objc func enabledValueChanged(sender: UISwitch) {
        delegate?.enabledChanged(to: sender.isOn, cell: self) { allowToggle in
            if !allowToggle {
                sender.isOn = !sender.isOn
            } else {
                self.lock.locked = !sender.isOn
            }
        }
    }
    
    @objc func restrictedValueChanged(sender: UISwitch) {
        delegate?.restrictedChanged(to: sender.isOn, cell: self) { allowToggle in
            if !allowToggle {
                sender.isOn = !sender.isOn
            } else {
                self.lock.restricted = sender.isOn
            }
        }
    }
}
