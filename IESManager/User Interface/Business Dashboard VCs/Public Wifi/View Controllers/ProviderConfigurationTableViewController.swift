//
//  PublicWifiOperatorConfigurationTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 19/01/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit


class ProviderConfigurationTableViewController: BaseConfigTableViewController, HubInteractionFlowControllerProtocol {
    var flowController: HubInteractionFlowController?
    
    let vm = ProviderConfigurationViewModel()

    @IBOutlet weak var providerImage: UIImageView!
    
    // MARK: - Data Models
    
    var selectedDefaultProviderDetails: PublicWifiOperatorDetailsConfig?
    var isTheCurrentlySelectedProvider: Bool = false
    let dm = HubDataModel.shared
    
    // MARK: - Cells
    
    @IBOutlet weak var nasIDCell: StringIntCell!
    @IBOutlet weak var uamRedirectUrlCell: StringIntCell!
    @IBOutlet weak var uamSecretCell: StringIntCell!
    @IBOutlet weak var radiusServer1Cell: StringIntCell!
    @IBOutlet weak var radiusServer2Cell: StringIntCell!
    @IBOutlet weak var radiusSecretCell: StringIntCell!
    @IBOutlet weak var radiusSwapOctetsCell: BoolCell!
    @IBOutlet weak var radiusAuthPortCell: StringIntCell!
    @IBOutlet weak var radiusAccountingCell: StringIntCell!
    @IBOutlet weak var uamAllowedDomainsCell: StringArrayCell!
    @IBOutlet weak var uamAllowedSitesCell: StringArrayCell!
    @IBOutlet weak var dnsServer1Cell: StringIntCell!
    @IBOutlet weak var dnsServer2Cell: StringIntCell!
    @IBOutlet weak var dhcpLeaseCell: StringIntCell!
    @IBOutlet weak var uamUiPortCell: StringIntCell!
    @IBOutlet weak var uamPortCell: StringIntCell!
    
    @IBOutlet weak var lanIdCell: StringIntCell!
    
    @IBOutlet weak var unitSerialNumberShort: StringIntCell!
    @IBOutlet weak var hsNetmaskCell: StringIntCell!
    @IBOutlet weak var hsNetworkCell: StringIntCell!
    @IBOutlet weak var hsUAMListenCell: StringIntCell!
    
    @IBOutlet var allWritableCells: [BaseValueTableViewCell]!
    
    // MARK: - Import Defaults
    
    @IBAction func importSettingsTapped(_ sender: Any) {
        let message = "Importing default settings will overwrite any changes you have made. Changes will not be Applied to the hub until you tap Apply".localized()
        let actions = UIAlertController(title: "Import Defaults".localized(), message: message, preferredStyle: .alert)
        
        actions.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (action) in
            
        }))
        actions.addAction(UIAlertAction(title: "Continue".localized(), style: .destructive, handler: { (action) in
            self.setDefaults()
        }))
        present(actions, animated: true)
    }
    
    private func setDefaults() {
        guard let defaultSettings = selectedDefaultProviderDetails else {
            return
        }
        
        nasIDCell.userSavedSetting = defaultSettings.nasId
        uamRedirectUrlCell.userSavedSetting = defaultSettings.uamRedirectUrl
        uamSecretCell.userSavedSetting = defaultSettings.uamSecret
        radiusServer1Cell.userSavedSetting = defaultSettings.radiusServer1
        radiusServer2Cell.userSavedSetting = defaultSettings.radiusServer2
        radiusSecretCell.userSavedSetting = defaultSettings.radiusSecret
        radiusSwapOctetsCell.userSavedSetting = defaultSettings.radiusSwapOctets.getBoolValue()
        radiusAuthPortCell.userSavedIntSetting = defaultSettings.radiusAuthPort
        radiusAccountingCell.userSavedIntSetting = defaultSettings.radiusAcctPort
        
        uamAllowedDomainsCell.defaultSetting = nil
        uamAllowedDomainsCell.userSavedSetting = defaultSettings.uamAllowedDomains
        uamAllowedSitesCell.defaultSetting = nil
        uamAllowedSitesCell.userSavedSetting = defaultSettings.uamAllowedSites
        dnsServer1Cell.userSavedSetting = defaultSettings.dnsServer1
        dnsServer2Cell.userSavedSetting = defaultSettings.dnsServer2
        dhcpLeaseCell.userSavedIntSetting = defaultSettings.dhcpLease
        uamUiPortCell.userSavedIntSetting = defaultSettings.uamUiPort
        uamPortCell.userSavedIntSetting = defaultSettings.uamPort
    }
    
    // MARK: - Population
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .onDrag
        
        if selectedDefaultProviderDetails != nil {
            setHeaderImage()
        }
        else {
            title = "Error. No details found".localized()
            providerImage.image = vm.logoImageForProvider(providerName: nil)
        }
        
        populateWithDefaultDetails()
        populateReadOnlyDetails()
        
        if isTheCurrentlySelectedProvider {
            populateWithSettings()
        }
        
        if navigationController?.viewControllers.count == 1 {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
            navigationItem.leftBarButtonItem = cancelButton
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setHeaderImage() {
        title = selectedDefaultProviderDetails?.supplierName
        let provider = selectedDefaultProviderDetails?.supplierName
        providerImage.image = vm.logoImageForProvider(providerName: provider)
        
        if (provider == vm.kSocify) {
            if VeeaFiController.providerBrandingShouldBeVeeaFi(provider: vm.kSocify) {
                providerImage.image = vm.veeaFiImage
                title = "VeeaFi"
            }
        }
        else if (provider == vm.kPurple) {
            if VeeaFiController.providerBrandingShouldBeVeeaFi(provider: vm.kPurple) {
                providerImage.image = vm.veeaFiImage
                title = "VeeaFi"
            }
        }
        else if (provider == vm.kHotspot) {
            if VeeaFiController.providerBrandingShouldBeVeeaFi(provider: vm.kHotspot) {
                providerImage.image = vm.veeaFiImage
                title = "VeeaFi"
            }
        }
        else if (provider == vm.kGlobalreach) {
            if VeeaFiController.providerBrandingShouldBeVeeaFi(provider: vm.kGlobalreach) {
                providerImage.image = vm.veeaFiImage
                title = "VeeaFi"
            }
        }
    }
    
    private func populateWithDefaultDetails() {
        guard let defaultConfig = selectedDefaultProviderDetails else {
            return
        }
        
        uamRedirectUrlCell.defaultSetting = defaultConfig.uamRedirectUrl
        uamSecretCell.defaultSetting = defaultConfig.uamSecret
        radiusServer1Cell.defaultSetting = defaultConfig.radiusServer1
        radiusServer2Cell.defaultSetting = defaultConfig.radiusServer2
        radiusSecretCell.defaultSetting = defaultConfig.radiusSecret
        radiusSwapOctetsCell.defaultSetting = defaultConfig.radiusSwapOctets.getBoolValue()
        radiusAuthPortCell.defaultIntSetting = defaultConfig.radiusAuthPort
        radiusAccountingCell.defaultIntSetting = defaultConfig.radiusAcctPort
        uamAllowedDomainsCell.defaultSetting = defaultConfig.uamAllowedDomains
        uamAllowedSitesCell.defaultSetting = defaultConfig.uamAllowedSites
        dnsServer1Cell.defaultSetting = defaultConfig.dnsServer1
        dnsServer2Cell.defaultSetting = defaultConfig.dnsServer2
        dhcpLeaseCell.defaultIntSetting = defaultConfig.dhcpLease
        uamUiPortCell.defaultIntSetting = defaultConfig.uamUiPort
        uamPortCell.defaultIntSetting = defaultConfig.uamPort
        
        guard let infoConfig = dm.optionalAppDetails?.publicWifiInfoConfig else {
            return
        }
        
        nasIDCell.defaultSetting = infoConfig.hs_nasid
    }
    
    private func populateReadOnlyDetails() {
        guard let infoConfig = dm.optionalAppDetails?.publicWifiInfoConfig else {
            return
        }
        
        hsNetmaskCell.userSavedSetting = infoConfig.hs_netmask
        hsNetworkCell.userSavedSetting = infoConfig.hs_network
        hsUAMListenCell.userSavedSetting = infoConfig.hs_uamlisten
        unitSerialNumberShort.userSavedSetting = infoConfig.unit_short_serial
    }
    
    private func populateWithSettings() {
        guard let saveConfig = dm.optionalAppDetails?.publicWifiSettingsConfig else {
            return
        }
        
        uamRedirectUrlCell.userSavedSetting = saveConfig.uam_redirect_url
        uamSecretCell.userSavedSetting = saveConfig.uam_secret
        radiusServer1Cell.userSavedSetting = saveConfig.radius_server_1
        radiusServer2Cell.userSavedSetting = saveConfig.radius_server_2
        radiusSecretCell.userSavedSetting = saveConfig.radius_secret
        
        uamAllowedDomainsCell.userSavedSetting = saveConfig.uam_allowed_domains
        uamAllowedSitesCell.userSavedSetting = saveConfig.uam_allowed_sites
        dnsServer1Cell.userSavedSetting = saveConfig.dns_server_1
        dnsServer2Cell.userSavedSetting = saveConfig.dns_server_2
        lanIdCell.userSavedIntSetting = saveConfig.lan_id
        
        if saveConfig.radius_auth_port != 0 {
            radiusAuthPortCell.userSavedIntSetting = saveConfig.radius_auth_port
        }
        
        if saveConfig.radius_acct_port != 0 {
            radiusAccountingCell.userSavedIntSetting = saveConfig.radius_acct_port
        }
        
        if saveConfig.dhcp_lease != 0 {
            dhcpLeaseCell.userSavedIntSetting = saveConfig.dhcp_lease
        }
        
        if saveConfig.uam_ui_port != 0 {
            uamUiPortCell.userSavedIntSetting = saveConfig.uam_ui_port
        }
        
        if saveConfig.uam_port != 0 {
            uamPortCell.userSavedIntSetting = saveConfig.uam_port
        }
        
        if saveConfig.radiusSwapOctets != .isEmptyOrNull {
            radiusSwapOctetsCell.userSavedSetting = saveConfig.radiusSwapOctets.getBoolValue()
        }
    }
    
    // MARK: - Updating
    
    override func applyConfig() {
        
        for cell in allWritableCells {
            cell.dismissKeyboard()
        }
        
        if let saveConfig = dm.optionalAppDetails?.publicWifiSettingsConfig {
            
            if selectedDefaultProviderDetails?.supplierName == saveConfig.selected_operator  {
                sendUpdate()
            }
            else {
                let message = "\("You are about to change your public Wi-Fi provider from".localized()) \(saveConfig.selected_operator) to \(selectedDefaultProviderDetails?.supplierName ?? "Error".localized()). \("Are you sure you want to continue?".localized())"
                let actions = UIAlertController(title: "Changing Wi-Fi Provider".localized(), message: message, preferredStyle: .alert)
                
                actions.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (action) in
                    
                }))
                actions.addAction(UIAlertAction(title: "Continue".localized(), style: .destructive, handler: { (action) in
                    self.sendUpdate()
                }))
                present(actions, animated: true)
            }
        }
    }
    
    private func sendUpdate() {
        guard let ies = connection else {
            //print("No IES")
            return
        }
        
        if var saveConfig = dm.optionalAppDetails?.publicWifiSettingsConfig {
            
            updateUpdateIndicatorState(state: .uploading)
            
            saveConfig.selected_operator = (selectedDefaultProviderDetails?.supplierName!)!
            saveConfig.nas_id = nasIDCell.dominantStringValue
            saveConfig.uam_redirect_url = uamRedirectUrlCell.dominantStringValue
            saveConfig.uam_secret = uamSecretCell.dominantStringValue
            saveConfig.radius_server_1 = radiusServer1Cell.dominantStringValue
            saveConfig.radius_server_2 = radiusServer2Cell.dominantStringValue
            saveConfig.radius_secret = radiusSecretCell.dominantStringValue
            saveConfig.uam_allowed_domains = uamAllowedDomainsCell.stringValue
            saveConfig.uam_allowed_sites = uamAllowedSitesCell.stringValue
            saveConfig.dns_server_1 = dnsServer1Cell.dominantStringValue
            saveConfig.dns_server_2 = dnsServer2Cell.dominantStringValue
            saveConfig.lan_id = lanIdCell.dominantIntValue
            
            if radiusAuthPortCell.dominantIntValue == 0 {
                saveConfig.radius_auth_port = selectedDefaultProviderDetails?.radiusAuthPort ?? 0
            }
            else {
                saveConfig.radius_auth_port = radiusAuthPortCell.dominantIntValue
            }
            
            if radiusAccountingCell.dominantIntValue == 0 {
                saveConfig.radius_acct_port = selectedDefaultProviderDetails?.radiusAcctPort ?? 0
            }
            else {
                saveConfig.radius_acct_port = radiusAccountingCell.dominantIntValue
            }
            
            if dhcpLeaseCell.dominantIntValue == 0 {
                saveConfig.dhcp_lease = selectedDefaultProviderDetails?.dhcpLease ?? 0
            }
            else {
                saveConfig.dhcp_lease = dhcpLeaseCell.dominantIntValue
            }
            
            if uamPortCell.dominantIntValue == 0 {
                saveConfig.uam_port = selectedDefaultProviderDetails?.uamPort ?? 0
            }
            else {
                saveConfig.uam_port = uamPortCell.dominantIntValue
            }
            
            if uamUiPortCell.dominantIntValue == 0 {
                saveConfig.uam_ui_port = selectedDefaultProviderDetails?.uamUiPort ?? 0
            }
            else {
                saveConfig.uam_ui_port = uamUiPortCell.dominantIntValue
            }
            
            saveConfig.radiusSwapOctets.setBoolValue(bool: radiusSwapOctetsCell.boolValue)
            
            ApiFactory.api.setConfig(connection: ies, config: saveConfig) {  [weak self]  (result, error) in
                NSLog("got result: \(String(describing: result)), error: \(String(describing: error))") // TODO
                
                if error != nil {
                    self?.updateUpdateIndicatorState(state: .completeWithError)
                    self?.showErrorUpdatingAlert(error: error!)
                    
                    return
                }
                
                HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
            }
            
        }
        else {
            //print("Error sending update")
        }
    }
}

extension ProviderConfigurationTableViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}
