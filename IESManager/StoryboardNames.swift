//
//  StoryboardNames.swift
//  IESManager
//
//  Created by Richard Stockdale on 25/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    static func initialViewController(storyboardName: StoryboardNames) -> UIViewController? {
        let vc = UIStoryboard(name: storyboardName.rawValue,
                              bundle: nil).instantiateInitialViewController()

        return vc
    }

    static func viewController(storyboardName: StoryboardNames,
                               viewControllerId: String) -> UIViewController? {
        let vc = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: viewControllerId)
        
        return vc
    }
}

enum StoryboardNames: String {
    // BUSINESS USERS
    case ApScan
    case BeaconConfig
    case CellularStats
    case Dash
    case DefaultWifiStoryboard
    case Firewall
    case GroupMeshSelection
    case InlineHelp
    case IPConfig
    case IPConnection
    case LanConfiguration
    case LaunchScreen
    case LogsStoryboard
    case MenuPicker
    case MultiSelect
    case MultiTenancy
    case NodeConfig
    case PhysicalPortsStoryboard
    case PublicWifiStoryboard
    case RecoveryOptions
    case RouterConfig
    case SdWanCellularStats
    case Services
    case SnapShoting
    case TestersMenu
    case TimeConfig
    case VmeshConfig
    case WanGatewayConfig
    case WifiApManagement
    case WifiApSecurity
    case WifiStats

    // HOME USERS
    case HomeUserLogin
    case HomeUserEnrollment
    case HomeUserDashboard
    case HomePreparing
    case MyAccount
    case WiFiSettings
    case ManageVeeaHubs
    case CellularUsage
    case SecuritySettings
}
