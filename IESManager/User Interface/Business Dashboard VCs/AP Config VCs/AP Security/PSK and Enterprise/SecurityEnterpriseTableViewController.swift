//
//  SecurityEnterpriseTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

class SecurityEnterpriseTableViewController: BaseSecurityTableViewController {
    
    @IBOutlet weak var primaryRadiusAuthLabel: UILabel!
    @IBOutlet weak var secondaryRadiusAuthLabel: UILabel!
    
    @IBOutlet weak var radiusAcctEnabledCell: UITableViewCell!
    @IBOutlet weak var primaryRadiusAcctLabel: UILabel!
    @IBOutlet weak var secondaryRadiusAcctLabel: UILabel!
    
    @IBOutlet weak var tapEnableInfoLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Enterprise".localized()
        uiSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showRadiusServerSettings()
        tapEnableInfoLabel.text = radiusAcctEnabledCell.isChecked ? "Tap here to disable".localized() : "Tap here to enable".localized()
    }
    
    private func showRadiusServerSettings() {
        guard let coordinator = coordinator else {
            return
        }
        
        primaryRadiusAuthLabel.text = coordinator.radiusAuthPrimaryDescriptionText
        secondaryRadiusAuthLabel.text = coordinator.radiusAuthSecondaryDescriptionText
        
        primaryRadiusAcctLabel.text = coordinator.radiusAcctPrimaryDescriptionText
        secondaryRadiusAcctLabel.text = coordinator.radiusAcctSecondaryDescriptionText
        
        // Show hide acct servers
        radiusAcctEnabledCell.isChecked = coordinator.acctIsEnabled
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier,
              let vc = segue.destination as? SecurityRadiusSelectionTableViewController,
              let t = SecurityRadiusSelectionTableViewController.SecurityRadiusSelectionType(rawValue: id) else { return }
        vc.serverType = t
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == EntSections.wpa {
            encryptionChange(i: indexPath.row)
        }
        else if indexPath.section == EntSections.wifiW {
            wChange(i: indexPath.row)
        }
        else if indexPath.section == EntSections.wifiR {
            rChange(i: indexPath.row)
        }
        else if indexPath.section == EntSections.radiusAccounting {
            if indexPath.row == 0 { // Enable / Disable
                radiusAcctEnabledCell.toggleCheckMark()
                tapEnableInfoLabel.text = radiusAcctEnabledCell.isChecked ? "Tap here to disable".localized() : "Tap here to enable".localized()
                coordinator?.acctIsEnabled = radiusAcctEnabledCell.isChecked
                tableView.reloadData()
                showRadiusServerSettings()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == EntSections.radiusAccounting { // The Radius accounting section
            if indexPath.row > 0 {
                if !radiusAcctEnabledCell.isChecked {
                    return 0
                }
            }
            
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == EntSections.radiusAuth || section == EntSections.radiusAccounting {
            if HubDataModel.shared.isMN {
                return "Tap to view details and select configured servers. (Servers configurations can only be editied on the Management Node)".localized()
            }
        }
        
        return super.tableView(tableView, titleForFooterInSection: section)
    }
}
