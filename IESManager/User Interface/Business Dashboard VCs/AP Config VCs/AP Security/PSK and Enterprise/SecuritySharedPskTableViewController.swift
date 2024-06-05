//
//  SecuritySharedPskTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

class SecuritySharedPskTableViewController: BaseSecurityTableViewController {
    
    
    @IBOutlet weak var passPhraseField: SecureEntryTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pre-shared Key".localized()
        passPhraseField.textField.addTarget(self, action: #selector(validatePassword), for: .editingChanged)
        passPhraseField.text = coordinator?.config.pass ?? ""
        uiSetup()
    }
    
    @objc func validatePassword() {
        let str = passPhraseField.text
        let minChars = 8
        let maxChars = 63
        
        let color: UIColor = str.count < minChars || str.count > maxChars ? .red : .label
        passPhraseField.textField.textColor = color
        
        coordinator?.config.pass = str
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == PskSections.wpa {
            encryptionChange(i: indexPath.row)
            
        }
        else if indexPath.section == PskSections.wifiW {
            wChange(i: indexPath.row)
        }
        else if indexPath.section == PskSections.wifiR {
            rChange(i: indexPath.row)
        }
    }
}
