//
//  MeshLanModes.swift
//  IESManager
//
//  Created by Richard Stockdale on 30/05/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation

// MARK: - WAN Mode
public enum WanMode: String, CaseIterable {
    case ROUTED = "rt"
    case BRIDGED = "br"
    case ISOLATED = "isolated"

    var displayName: String {
        switch self {
        case .ROUTED: return "Routed".localized()
        case .BRIDGED: return "Bridged".localized()
        case .ISOLATED: return "Isolated".localized()
        }
    }

    var defaultIpManagementMode: IpManagementMode {
        switch self {
        case .ROUTED:
            return .SERVER
        case .BRIDGED:
            return .CLIENT
        case .ISOLATED:
            return .CLIENT
        }
    }

    var availableIpManagementModes: [IpManagementMode] {
        let hasRw = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.usesIpModeTableRw ?? false
        let hasRo = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.usesIpModeTableRo ?? false
        
        return ipManagementModesFor(hasRw: hasRw, hasRo: hasRo)
    }
    
    func ipManagementModesFor(hasRw: Bool, hasRo: Bool) -> [IpManagementMode] {
        if hasRw {
            return IpManagementMode.availableIpModesForReadWrite(wanMode: self)
        }
        else if hasRo {
            return IpManagementMode.availableIpModesForReadOnly(wanMode: self)
        }
        else {
            return [IpManagementMode]()
        }
    }
}


// MARK: - IP Management Mode
public enum IpManagementMode: String, CaseIterable {
    case CLIENT = "client"
    case SERVER = "server"
    case STATIC = "static"

    var displayText: String {
        switch self {
        case .CLIENT: return "Client"
        case .SERVER: return "Server"
        case .STATIC: return "Static"
        }
    }

    // VHM-1616
    static func availableIpModesForReadOnly(wanMode: WanMode) -> [IpManagementMode] {
        switch wanMode {
        case .ROUTED:
            return [IpManagementMode.SERVER]
        case .BRIDGED:
            return [IpManagementMode.CLIENT]
        case .ISOLATED:
            return [IpManagementMode.CLIENT,
                    IpManagementMode.STATIC]
        }
    }

    // VHM-1616
    static func availableIpModesForReadWrite(wanMode: WanMode) -> [IpManagementMode] {
        switch wanMode {
        case .ROUTED:
            return [IpManagementMode.SERVER,
                    IpManagementMode.STATIC]
        case .BRIDGED:
            return [IpManagementMode.CLIENT,
                    IpManagementMode.STATIC]
        case .ISOLATED:
            return IpManagementMode.allCases
        }
    }
}
