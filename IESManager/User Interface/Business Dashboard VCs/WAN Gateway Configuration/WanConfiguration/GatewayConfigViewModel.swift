//
//  GatewayConfigViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

class GatewayConfigViewModel: BaseConfigViewModel {
    
    struct SectionId {
        static let Backhaul = 0
        static let SettingsWifi = 1
        static let SettingsCellularRequested = 2
        static let SettingsCellularApplied = 3
    }
    
    struct SettingsRowId {
        // Wifi Section
        static let SSID = 0
        static let Passphrase = 1
        
        // Requested Cellular Section
        static let apnName = 0
        static let apnMcc = 1
        static let apnMnc = 2
        static let apnUserName = 3
        static let apnPassphrase = 4
        
        
        // Applied Cellular Section
        static let connectedStatus = 0
        static let connectedApn = 1
        static let connectedMcc = 2
        static let connectedMnc = 3
        static let connectedUsername = 4
        static let connectedPassphrase = 5
    }
    
    struct BackhaulTypes {
        static let ethernet = "Ethernet"
        static let wifi = "Wifi"
        static let cellular = "Cellular"
    }

    var sectionTitles: [String] {
        if shouldShowAppliedAPNSettings() {
            return [ "Backhaul".localized(), "WiFi Settings".localized(), "Cellular Settings".localized(), "Applied Cellular Settings".localized() ]
        }
        
        return [ "Backhaul".localized(), "WiFi Settings".localized(), "Cellular Settings".localized() ]
    }
    
    lazy var gatewayConfig: GatewayConfig? = {
        return bdm?.gatewayConfig
    }()
    
    lazy var iesStatus: NodeStatus? = {
        return bdm?.nodeStatusConfig
    }()
    
    lazy var nodeConfig: NodeConfig? = {
        return bdm?.nodeConfig
    }()
    
    lazy var originalNodeConfig: NodeConfig? = {
        return bdm?.nodeConfig
    }()
    
    func shouldShowAPNSettings() -> Bool {
        return bdm?.nodeCapabilitiesConfig?.isCellularAvailable ?? false
    }
    
    func shouldShowAppliedAPNSettings() -> Bool {
        if !shouldShowAPNSettings() {
            return false
        }
        guard let s = iesStatus else {
            return false
        }
        
        return !s.gateway_cellular_connected_status.isEmpty
    }
    
    var sdWanAvailable: Bool {
        guard odm?.sdWanConfig != nil else {
            return false
        }
        
        return true
    }
    
    // MARK: - Validation
    func validateMncMccFields(text: String) -> String? {
        if text.isEmpty { return nil }
        
        // 3 chars max. These may have a leading 0, so strings like "030" or "30" or "111"; all valid values
        if text.count > 3 { return "3 characters max".localized() }
        
        // All should be numbers
        if !text.isNumeric {
            return "Only numbers".localized()
        }
        
        return nil
    }
}

// MARK: - Lock / Restriction information
extension GatewayConfigViewModel {
    var restrictedInterfaces: String {
        var restrictedInterfaces = ""
        for lock in gatewayConfig!.locks {
            if !lock.locked && lock.restricted {
                restrictedInterfaces.append("\(lock.title) ")
            }
        }
        return restrictedInterfaces
    }
    
    var unrestrictedInterfaces: String {
        var unrestrictedInterfaces = ""
        for lock in gatewayConfig!.locks {
            if !lock.locked && !lock.restricted {
                unrestrictedInterfaces.append("\(lock.title) ")
            }
        }
        return unrestrictedInterfaces
    }
    
    var hasRestricted: Bool {
        for lock in gatewayConfig!.locks {
            if !lock.locked && lock.restricted {
                return true
            }
        }
        return false
    }
    
    var hasUnrestricted: Bool {
        for lock in gatewayConfig!.locks {
            if !lock.locked && !lock.restricted {
                return true
            }
        }
        return false
    }
}

// MARK: - Backhaul selection
extension GatewayConfigViewModel {
    func viewControllerForBackHaulSelection(type: String) -> UIViewController? {
        
        // Checks
        if !sdWanAvailable { return nil }
        guard let sdWan = HubDataModel.shared.optionalAppDetails?.sdWanConfig else { return nil }
        if sdWan.isEmpty { return nil }
        
        let sdWanConfig = HubDataModel.shared.optionalAppDetails?.sdWanConfig
        let storyBoard: UIStoryboard = UIStoryboard(name: "WanGatewayConfig", bundle: nil)
        
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "SdWanBearerConfigTableViewController") as? SdWanBearerConfigTableViewController else {
            return nil
        }
        
        switch type {
        case GatewayConfigViewModel.BackhaulTypes.cellular:
            vc.backhaulType = GatewayConfigViewModel.BackhaulTypes.cellular
            vc.vm.backhaulConfig = sdWanConfig?.cellularBackHaulConfig
        case GatewayConfigViewModel.BackhaulTypes.wifi:
            vc.backhaulType = GatewayConfigViewModel.BackhaulTypes.wifi
            vc.vm.backhaulConfig = sdWanConfig?.wifiBackHaulConfig
            
        case GatewayConfigViewModel.BackhaulTypes.ethernet:
            vc.backhaulType = GatewayConfigViewModel.BackhaulTypes.ethernet
            vc.vm.backhaulConfig = sdWanConfig?.ethernetBackHaulConfig
            
        default:
            //print("Unknown selection")
            return nil
        }
        
        return vc
    }
}
