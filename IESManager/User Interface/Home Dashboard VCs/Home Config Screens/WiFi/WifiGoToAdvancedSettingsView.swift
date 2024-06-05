//
//  WifiGoToAdvancedSettingsView.swift
//  IESManager
//
//  Created by Richard Stockdale on 11/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

protocol WifiGoToAdvancedSettingsViewActionDelegate: AnyObject {
    func didTapRestore()
    func didTapGoToAdvanced()
}

class WifiGoToAdvancedSettingsView: LoadedXibView {

    private let baseText = "Wi-Fi settings of this mesh has been changed through Advanced Settings page and can not be changed from this page any longer unless default settings are restored.".localized()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var advancedSettingsButton: CurvedButton!
    @IBOutlet weak var restoreButton: UIButton!

    enum IssueType {
        case SecurityNotSupported, WifiDetailsDoNotMatch

        var issueExplanation: String {
            switch self {
            case .SecurityNotSupported:
                return "(Looks like you are not using a pre-shared key)".localized()
            case .WifiDetailsDoNotMatch:
                return "(Looks like you are using different credentials for different radios.)".localized()
            }
        }
    }
    
    weak var delegate: WifiGoToAdvancedSettingsViewActionDelegate?
    
    @IBAction func goToAdvancedSettingsTapped(_ sender: Any) {
        delegate?.didTapGoToAdvanced()
    }
    
    @IBAction func restoreDefaultsTapped(_ sender: Any) {
        delegate?.didTapRestore()
    }
    
    override func loaded() {
        let cm = InterfaceManager.shared.cm
        
        xibView.backgroundColor = cm.background2.colorForAppearance
        titleLabel.font = FontManager.bold(size: 18)
        bodyLabel.font = FontManager.bodyText
        restoreButton.titleLabel?.font = FontManager.medium(size: 15)
        restoreButton.setTitleColor(cm.textWarningRed1.colorForAppearance, for: .normal)
    }
    
    override func setTheme() {
        loaded()
    }

    func setForIssue(_ issue: IssueType) {
        bodyLabel.text = baseText + "\n" + issue.issueExplanation

        switch issue {
        case .SecurityNotSupported:
            restoreButton.isHidden = false
        case .WifiDetailsDoNotMatch:
            restoreButton.isHidden = true
        }
    }
}
