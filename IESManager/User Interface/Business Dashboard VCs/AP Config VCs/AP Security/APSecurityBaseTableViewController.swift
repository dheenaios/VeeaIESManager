//
//  APSecurityBaseTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

class APSecurityBaseTableViewController: UITableViewController {

    struct EntSections {
        static let ssid = 0
        static let wpa = 1
        static let wifiR = 2
        static let wifiW = 3
        static let radiusAuth = 4
        static let radiusAccounting = 5
    }
    
    struct PskSections {
        static let ssid = 0
        static let wpa = 1
        static let passPhrase = 2 // DIFF
        static let wifiR = 3
        static let wifiW = 4
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        // Do we just show WPA cells
        let wpaCells = HubDataModel
            .shared
            .baseDataModel?
            .nodeCapabilitiesConfig?
            .isWpa2Only ?? false ? 1 : 3
        
        // ENTERPRISE
        if ((self as? SecurityEnterpriseTableViewController) != nil) {
            switch section {
            case EntSections.ssid : return 1
            case EntSections.wpa: return wpaCells
            case EntSections.radiusAuth: return 2
            case EntSections.wifiW: return 3
            case EntSections.wifiR: return 2
            case EntSections.radiusAccounting: return 3
            default:
                return 0
            }
        }
        
        // PSK
        switch section {
        case PskSections.ssid: return 1
        case PskSections.wpa: return wpaCells
        case PskSections.passPhrase: return 1
        case PskSections.wifiW: return 3
        case PskSections.wifiR: return 2
        default:
            return 0
        }
    }
    
    func headerTextForSection(section: Int) -> String? {
        // ENTERPRISE
        if ((self as? SecurityEnterpriseTableViewController) != nil) {
            switch section {
            case EntSections.ssid: return "SSID".localized()
            case EntSections.wpa: return "WPA Mode".localized()
            case EntSections.radiusAuth: return "Radius Authentication".localized()
            case EntSections.wifiW: return "802.11W".localized()
            case EntSections.wifiR: return "802.11R".localized()
            case EntSections.radiusAccounting: return "Radius Accounting".localized()
            
            default:
                return nil
            }
        }
        
        // PSK
        switch section {
        case PskSections.ssid: return "SSID".localized()
        case PskSections.wpa: return "WPA Mode".localized()
        case PskSections.passPhrase: return "Passphrase".localized()
        case PskSections.wifiW: return "802.11W".localized()
        case PskSections.wifiR: return "802.11R".localized()
        default:
            return nil
        }
    }
    
    func footerTextForSection(section: Int) -> String? {
        // ENTERPRISE
        if ((self as? SecurityEnterpriseTableViewController) != nil) {
            switch section {
            case EntSections.ssid: return nil
            case EntSections.wpa: return nil
            case EntSections.radiusAuth: return "Tap a server to configure".localized()
            case EntSections.wifiW: return "802.11w allows compatible Wi-Fi clients to use management frame protection as an additional security measure for management frames.".localized()
            case EntSections.wifiR: return "802.11r allows compatible Wi-Fi clients to fast transition (FT) between network APs that are configured with the same SSID. Enabling 802.11r may mean some older clients cannot connect to this SSID.".localized()
            case EntSections.radiusAccounting: return "Tap a server to configure".localized()
            default:
                return nil
            }
        }
        
        // PSK
        switch section {
        case PskSections.ssid: return nil
        case PskSections.wpa: return nil
        case PskSections.passPhrase: return "Phrase should be 8 - 63 character".localized()
        case PskSections.wifiW: return "802.11w allows compatible Wi-Fi clients to use management frame protection as an additional security measure for management frames.".localized()
        case PskSections.wifiR: return "802.11r allows compatible Wi-Fi clients to fast transition (FT) between network APs that are configured with the same SSID. Enabling 802.11r may mean some older clients cannot connect to this SSID.".localized()
        default:
            return nil
        }
    }
    
    var coordinator: SecurityConfigCoordinator? {
        guard let nc = navigationController as? SecurityNavigationViewController else {
            dismiss(animated: true, completion: nil)
            return nil
        }
        
        return nc.coordinator
    }
    
    var supported: Bool {
        return coordinator?.enhancedSecuritySupported ?? false
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        coordinator?.userTappedDone()
        dismiss(animated: true, completion: nil)
    }
}
