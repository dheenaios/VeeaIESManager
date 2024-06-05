//
//  WanIpModeController.swift
//  IESManager
//
//  Created by Richard Stockdale on 20/07/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation
import UIKit

/// Contains the state data to support displaying the WAN and IP mode UI
class WanIpModeController {

    let supportsBackpack: Bool
    let supportsIpMode: Bool

    var selectedWanMode: WanMode
    var selectedIpMode: IpManagementMode

    var availableWanModes: [WanMode] {
        var modes = WanMode.allCases
        if !supportsBackpack {
            modes.removeAll { $0 == .ISOLATED }
        }

        return modes
    }

    var ipManagementHidden: Bool {
        let present = supportsBackpack && supportsIpMode
        return !present
    }

    var availableIpModes: [IpManagementMode] {
        return selectedWanMode.availableIpManagementModes
    }

    internal init(supportsBackpack: Bool,
                  supportsIpMode: Bool,
                  selectedWanMode: WanMode,
                  selectedIpMode: IpManagementMode) {
        self.supportsBackpack = supportsBackpack
        self.supportsIpMode = supportsIpMode
        self.selectedWanMode = selectedWanMode
        self.selectedIpMode = selectedIpMode
    }

    func updateForNewLan(selectedWanMode: WanMode,
                         selectedIpMode: IpManagementMode) {
        self.selectedWanMode = selectedWanMode
        self.selectedIpMode = selectedIpMode
    }
}

// MARK: - Menu Options
extension WanIpModeController {

    var availableWanModesOptions: [MenuViewController.MenuItemOption] {
        var options = [MenuViewController.MenuItemOption]()
        for mode in availableWanModes {
            let option = MenuViewController.MenuItemOption(title: mode.displayName,
                                                           selected: mode == selectedWanMode)
            options.append(option)
        }

        return options
    }

    var availableIpModesOptions: [MenuViewController.MenuItemOption] {
        var options = [MenuViewController.MenuItemOption]()
        for mode in availableIpModes {
            let option = MenuViewController.MenuItemOption(title: mode.displayText,
                                                           selected: mode == selectedIpMode)
            options.append(option)
        }

        return options
    }
}
