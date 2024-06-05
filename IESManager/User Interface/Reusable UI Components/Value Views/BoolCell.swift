//
//  BoolView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 19/01/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

class BoolCell: BaseValueTableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var boolSwitch: UISwitch!
    @IBOutlet private weak var detailLabel: UILabel!
    
    public var defaultSettingValue: Bool?
    public var userSavedSettingValue: Bool?
    
    var title: String? {
        willSet {
            titleLabel.text = newValue
        }
    }
    
    var defaultSetting: Bool? {
        willSet {
            detailLabel.text = newValue! ? "Default Setting is On".localized() : "Default Setting is Off".localized()
            boolSwitch.isOn = newValue!
            defaultSettingValue = newValue
        }
    }
    
    var userSavedSetting: Bool? {
        willSet {
            boolSwitch.isOn = newValue!
            userSavedSettingValue = newValue
        }
    }
    
    var boolValue: Bool {
        return boolSwitch.isOn
    }
}
