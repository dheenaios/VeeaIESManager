//
//  SettingsSwitchCell.swift
//  VeeaHub Manager
//
//  Created by Al on 16/05/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit

protocol SettingsSwitchCellDelegate {
    func settingChanged(isEnabled: Bool)
}


class SettingsSwitchCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    
    var delegate: SettingsSwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        enabledSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    @objc func switchValueChanged(sender: UISwitch) {
        delegate?.settingChanged(isEnabled: sender.isOn)
    }
}
