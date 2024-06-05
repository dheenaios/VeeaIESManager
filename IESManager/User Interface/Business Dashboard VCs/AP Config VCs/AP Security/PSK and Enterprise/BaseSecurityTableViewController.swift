//
//  SecurityTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

/// Common functionality for the Shared Key and Enterprise  screens
class BaseSecurityTableViewController: APSecurityBaseTableViewController {
    
    @IBOutlet weak var ssidNameLabel: UILabel!
    @IBOutlet var encryptCells: [UITableViewCell]!
    
    @IBOutlet var enable80211wCells: [UITableViewCell]!
    @IBOutlet var enable80211rCells: [UITableViewCell]! // Disabled / Enabled
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private var wEnabled = true
    private var rEnabled = true
    
    func uiSetup() {
        var ssid = coordinator?.config.ssid ?? "No SSID set".localized()
        if ssid.isEmpty {
            ssid = "No SSID set".localized()
        }
        ssidNameLabel.text = ssid
        
        guard let coordinator = coordinator  else { return }
        
        if !coordinator.enhancedSecuritySupported {
            setForUnsupported()
            return
        }
        
        if let mode = coordinator.config.wpaMode {
            encryptCells[mode.rawValue].accessoryType = .checkmark
        }
        
        setWifiWUi()
        setWForScreenAndWpaMode()
        setRForScreenAndWpaMode()
    }
    
    private func setWifiWUi() {
        let wpa2Only = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.isWpa2Only ?? false
        guard let coordinator = coordinator  else { return }
        let currentW = coordinator.config.enable80211w
        let rEnabled = coordinator.config.enable80211r
        
        if wpa2Only {
            for cell in encryptCells { cell.accessoryType = .none }
            encryptCells.first?.accessoryType = .checkmark
            coordinator.encryptMode = .wpa2Only
            
            for cell in enable80211wCells { cell.accessoryType = .none }
            enable80211wCells[currentW.rawValue].accessoryType = .checkmark
            
            return
        }
        
        for cell in enable80211wCells { cell.accessoryType = .none }
        enable80211wCells[currentW.rawValue].accessoryType = .checkmark
        
        for cell in enable80211rCells { cell.accessoryType = .none }
        let checkedCell = rEnabled ? 1 : 0
        enable80211rCells[checkedCell].accessoryType = .checkmark
    }
    
    private func setForUnsupported() {
        for cell in encryptCells { cell.contentView.alpha = 0.3 }
        for cell in enable80211wCells { cell.contentView.alpha = 0.3 }
    }
    
    func encryptionChange(i: Int) {
        for cell in encryptCells {
            cell.accessoryType = .none
        }
        
        guard let coordinator = coordinator else { return }
        
        if coordinator.enhancedSecuritySupported {
            encryptCells[i].accessoryType = .checkmark
            let encryptionMode = AccessPointConfig.EncryptMode(rawValue: i)!
            coordinator.encryptMode = encryptionMode
            
            setWForScreenAndWpaMode()
            setRForScreenAndWpaMode()
        }
        else {
            showUpdateWarning()
        }
    }
    
    private func setWForScreenAndWpaMode() {
        guard let coordinator = coordinator else { return }
        if coordinator.encryptMode != .wpa2Only {
            wEnabled = false
            for cell in enable80211wCells { cell.accessoryType = .none }
        }
        else {
            wEnabled = true
            setWifiWUi()
        }
        
        tableView.reloadData()
    }
    
    private func setRForScreenAndWpaMode() {
        guard let coordinator = coordinator else { return }
        let isAvailableOnHub = HubDataModel
            .shared.baseDataModel?
            .nodeCapabilitiesConfig?
            .wifi802_11rAvailable ?? false
        
        if !isAvailableOnHub || coordinator.isHubAp {
            hideWifiR()
            return
        }
        
        rEnabled = true
    }
    
    private func hideWifiR() {
        rEnabled = false
        tableView.reloadData()
        
    }
    
    func wChange(i: Int) {
        guard let coordinator = coordinator else { return }
        
        if !wEnabled {
            for cell in enable80211wCells { cell.accessoryType = .none }
            return
        }
        
        if coordinator.enhancedSecuritySupported {
            for cell in enable80211wCells { cell.accessoryType = .none }
            enable80211wCells[i].accessoryType = .checkmark
            
            coordinator.config.enable80211w = AccessPointConfig.Enable80211w(rawValue: i) ?? .disabled
        }
        else {
            for cell in enable80211wCells { cell.accessoryType = .none }
            showUpdateWarning()
        }
    }
    
    func rChange(i: Int) {
        guard let coordinator = coordinator else { return }
        
        if !rEnabled {
            for cell in enable80211rCells { cell.accessoryType = .none }
            return
        }
        
        if coordinator.enhancedSecuritySupported {
            for cell in enable80211rCells { cell.accessoryType = .none }
            enable80211rCells[i].accessoryType = .checkmark
            
            coordinator.config.enable80211r = i == 0 ? false : true
        }
        else {
            for cell in enable80211rCells { cell.accessoryType = .none }
            showUpdateWarning()
        }
    }
    
    private func showUpdateWarning() {
        showInfoAlert(title: "Not available".localized(),
                      message: "Please update your VeeaHub firmware to access this functionality.\nYou can only set your passphrase".localized())
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // If  "WPA2 Only" features field is present, then do not show WPA3 options. (VHM 791)
        let wpa2Only = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.isWpa2Only ?? false
        
        if indexPath.section == EntSections.wpa &&
            wpa2Only &&
            indexPath.row > 0{
            return 0
        }
        
        return 44.0
    }
}

/// Table view method overrides for dynamically showing and hiding
extension BaseSecurityTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self is SecurityEnterpriseTableViewController {
            if section == EntSections.wifiW && !wEnabled { // VHM 912 - Only show W if WP2 is selected
                return 0
            }
            else if section == EntSections.wifiR && !rEnabled { // VHM 913 - Hiding wifi R
                return 0
            }
        }
        else {
            if section == PskSections.wifiW && !wEnabled { // VHM 912 - Only show W if WP2 is selected
                return 0
            }
            else if section == PskSections.wifiR && !rEnabled { // VHM 913 - Hiding wifi R
                return 0
            }
        }
        
        
        
        return numberOfRowsInSection(section: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self is SecurityEnterpriseTableViewController {
            if section == EntSections.wifiW && !wEnabled { // VHM 912 - Only show W if WP2 is selected
                return nil
            }
            else if section == EntSections.wifiR && !rEnabled { // VHM 913 - Hiding wifi R
                return nil
            }
        }
        else {
            if section == PskSections.wifiW && !wEnabled { // VHM 912 - Only show W if WP2 is selected
                return nil
            }
            else if section == PskSections.wifiR && !rEnabled { // VHM 913 - Hiding wifi R
                return nil
            }
        }
        
        
        return headerTextForSection(section: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if self is SecurityEnterpriseTableViewController {
            if section == EntSections.wifiW && !wEnabled { // VHM 912 - Only show W if WP2 is selected
                return nil
            }
            else if section == EntSections.wifiR && !rEnabled { // VHM 913 - Hiding wifi R
                return nil
            }
        }
        else {
            if section == PskSections.wifiW && !wEnabled { // VHM 912 - Only show W if WP2 is selected
                return nil
            }
            else if section == PskSections.wifiR && !rEnabled { // VHM 913 - Hiding wifi R
                return nil
            }
        }
        
        return footerTextForSection(section: section)
    }
}
