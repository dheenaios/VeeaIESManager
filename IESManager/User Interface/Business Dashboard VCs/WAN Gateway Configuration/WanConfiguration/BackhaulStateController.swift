//
//  BackhaulStateController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 20/10/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit

enum BackhaulType: String, CaseIterable {
    case cellular = "gateway_cellular_locked"
    case ethernet = "gateway_ethernet_locked"
    case wifi = "gateway_wifi_locked"
    
    var title: String {
        switch self {
        case .cellular:
            return "Cellular".localized()
        case .ethernet:
            return "Ethernet".localized()
        case .wifi:
            return "Wi-Fi".localized()
        }
    }
    
    var iconComponentName: String {
        switch self {
        case .cellular:
            return "cellular"
        case .ethernet:
            return "ethernet"
        case .wifi:
            return "wifi"
        }
    }
}

struct BackhaulStateController {
    
    var nodeStatus = HubDataModel.shared.baseDataModel?.nodeStatusConfig
    var gatewayConfig = HubDataModel.shared.baseDataModel?.gatewayConfig
    var nodeCapabilities = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig
    var lockStatus = HubDataModel.shared.baseDataModel?.lockStatus
    let isMN = HubDataModel.shared.isMN
    
    enum BackhaulState {
        case operational
        case operationButLocked
        case nonOperational
        case none
        
        private struct StatusIconColor {
            static let grey = "grey"
            static let green = "green"
            static let orange = "orange"
            static let red = "red"
        }
        
        fileprivate var colorString: String {
            switch self {
            case .operational:
                return StatusIconColor.green
            case .operationButLocked:
                return StatusIconColor.orange
            case .nonOperational:
                return StatusIconColor.red
            case .none:
                return StatusIconColor.grey
            }
        }
    }
    
    
    /// Get the icon for a given type
    /// - Parameter type: The type of backhaul
    /// - Returns: UIImage of the icon to be used
    func getIconFor(type: BackhaulType) -> UIImage {
        let state = getStateFor(backhaulType: type)
        
        let iconName = "\(type.iconComponentName)_icon_\(state.colorString)"
        return UIImage(named: iconName)!
    }
    
    
    /// The state for a given backhaul
    /// - Parameter type: The backhaul
    /// - Returns: The state of the backhaul
    func getStateFor(backhaulType type: BackhaulType) -> BackhaulState {
        switch type {
        case .cellular:
            return stateCellular()
        case .ethernet:
            return stateEthernet()
        case .wifi:
            return stateWifi()
        }
    }
    
    /// Should the backhaul be shown as enabled or disabled
    /// - Parameter type: The backhail
    /// - Returns: Bool indicating enabled state
    func isEnabledFor(type: BackhaulType) -> Bool {
        if isMN { return false }
        
        switch type {
        case .cellular:
            return cellularShouldBeEnabled
        case .ethernet:
            return true
        case .wifi:
            return BackhaulStateController.isBackhaulWiFiAvailable
        }
    }
}

// MARK: - Backhaul states
extension BackhaulStateController {
    private func stateWifi() -> BackhaulState {
        guard let nodeCapabilities = nodeCapabilities,
              let lockStatus = lockStatus else {
                  return .none
              }
        
        let isOperational = getOperationalStateFor(backhaulType: .wifi)
        var status:BackhaulState = isOperational ? .operational : .nonOperational
        
        // SW-8038: From Nick J: If wifi_wan is present in the capabilities list then Wi-Fi should be made 'orange' if Wi-Fi is marked as 'locked'. If 'wifi_wan' is not in the capabilities list then it should be greyed out.
        let locked = lockStatus.gateway_wifi_locked
        
        if nodeCapabilities.isWifiWanPresent {
            if locked { status = .operationButLocked }
        }
        else { status = .none }
        
        return status
    }
    
    private func stateEthernet() -> BackhaulState {
        let isOperational = getOperationalStateFor(backhaulType: .ethernet)
        if isMN { return .none }
        return isOperational ? .operational : .nonOperational
    }
    
    // See [VHM-1156 Colour scheme on VHM for Cellular under WAN isnt consistent with MAS  - JIRA](https://max2inc.atlassian.net/browse/VHM-1156)
    private func stateCellular() -> BackhaulState {
        if let cellularAvailable = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.isCellularAvailable {
            if !cellularAvailable {
                return .none
            }
        }
        
        if isMN {
            return .none // MNs should not have cellular
        }
        
        guard let nodeStatus = nodeStatus,
              let gatewayConfig = gatewayConfig else {
                  return .none
              }
        
        var status = BackhaulState.nonOperational
        if nodeStatus.gateway_cellular_operational {
            status = .operational
        }
        
        for lock in gatewayConfig.locks {
            if lock.backhaulType == .cellular && lock.locked {
                status = .operationButLocked
            }
        }
        
        return status
    }
    
    private func getOperationalStateFor(backhaulType type: BackhaulType) -> Bool {
        guard let nodeStatus = nodeStatus else {
            return false
        }
        
        switch type {
        case .cellular:
            return false
        case .ethernet:
            return nodeStatus.gateway_ethernet_operational
        case .wifi:
            return nodeStatus.gateway_wifi_operational
        }
    }
}


// MARK: - Enabled or disabled
extension BackhaulStateController {
    private var cellularShouldBeEnabled: Bool {
        guard let nodeCapabilities = nodeCapabilities else {
            return false
        }
        
        return nodeCapabilities.isCellularAvailable
    }
    
    static var isBackhaulWiFiAvailable: Bool {
        guard let nodeCapabilities = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig else {
            return false
        }
        
        return nodeCapabilities.isWifiWanPresent
    }
}
