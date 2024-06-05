//
//  RowSwitchView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 16/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit

class RowSwitchView: LoadedXibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var onOffSwitch: UISwitch!
    
    @IBInspectable var title: String = "Title" {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBInspectable var subTitle: String = "" {
        didSet {
            subTitleLabel.text = subTitle
        }
    }
    
    @IBInspectable var switchIsOn: Bool = false {
        didSet {
            onOffSwitch.isOn = switchIsOn
        }
    }
    
    private var observer: (() -> Void)?
    
    @IBAction func switchChangedTapped(_ sender: Any) {
        switchIsOn = onOffSwitch.isOn
        guard let o = observer else { return }
        o()
    }
    
    func observerTaps(observer: @escaping (() -> Void)) {
        self.observer = observer
    }
    
    override func loaded() {
        super.loaded()
        
        titleLabel.text = title
        subTitleLabel.text = subTitle
        onOffSwitch.isOn = switchIsOn
    }
    
    override func setTheme() {
        onOffSwitch.onTintColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
    }
}
