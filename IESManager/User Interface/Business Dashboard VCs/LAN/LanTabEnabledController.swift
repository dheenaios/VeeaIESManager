//
//  TabEnabledController.swift
//  IESManager
//
//  Created by Richard Stockdale on 15/05/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation


/// The display logic is quite complex. This struct keeps it all in the same place.
struct LanTabEnabledController {
    private let wanMode: WanMode
    private let ipManagementMode: IpManagementMode

    var configEnabled: Bool = true // This is always true

    var lanIpEnabled: Bool {
        if wanMode == .ISOLATED {
            return false
        }
        else if wanMode == .ROUTED {
            if ipManagementMode == .SERVER { return true }
            if ipManagementMode == .STATIC { return false }
        }
        else if wanMode == .BRIDGED {
            return false
        }

        Log.tag(tag: "LanTabEnabledController",
                message: "Error, illegal combination of modes (lanIpEnabled)")
        return false
    }

    var reservedIpsEnabled: Bool {
        if wanMode == .ISOLATED {
            return false
        }
        else if wanMode == .ROUTED {
            if ipManagementMode == .SERVER { return true }
            if ipManagementMode == .STATIC { return false }
        }
        else if wanMode == .BRIDGED {
            return false
        }

        Log.tag(tag: "LanTabEnabledController",
                message: "Error, illegal combination of modes (reservedIpsEnabled)")
        return false
    }

    func staticIpsEnabled(lan: LanWanStaticIpConfig?) -> Bool {
        print("lan::\(lan)")
        if wanMode == .ISOLATED {
            if ipManagementMode == .SERVER { return false }
            if ipManagementMode == .CLIENT { return false }
            if ipManagementMode == .STATIC {
                // TODO: VHM 1657 -> Needs to take into account of node_lan_config_static_ip lan_X use is true or false
                if let lan {
                    return lan.use
                }
                return true
            }
        }
        else if wanMode == .ROUTED {
            if ipManagementMode == .SERVER { return false }
            if ipManagementMode == .STATIC { return true }
        }
        else if wanMode == .BRIDGED {
            if ipManagementMode == .CLIENT { return false }
            if ipManagementMode == .STATIC { return true }
        }

        Log.tag(tag: "LanTabEnabledController",
                message: "Error, illegal combination of modes (staticIpsEnabled)")
        return false
    }

    init(wanMode: WanMode,
         ipManagementMode: IpManagementMode) {
        self.wanMode = wanMode
        self.ipManagementMode = ipManagementMode
    }
}
