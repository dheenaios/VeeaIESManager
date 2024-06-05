//
//  HomeDashboardDestinationManager.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

struct HomeDashboardDestinationManager {
    
    
    /// Destination names. The raw values are the names of the related view controllers
    enum Destinations: String {
        case WiFiSettings
        case ManageVeeaHubs
        case CellularUsage
        case SecuritySettings
        case NetworkSpeedTest
        case AdvancedNetworkSettings
        case MyAccount
        case Support
    }
    
    static func viewControllerFor(dashboardItem: HomeDashboardItem,
                                  mesh: VHMesh,
                                  meshDetailViewModel: MeshDetailViewModel) -> UIViewController? {
        guard let destination = Destinations(rawValue: dashboardItem.destinationId) else {
            return nil
        }
        
        var vc: UIViewController?
        
        switch destination {
        case .WiFiSettings:
            vc = WiFiSettingsViewController.new(mesh: mesh,
                                                meshDetailViewModel: meshDetailViewModel)
        case .ManageVeeaHubs:
            vc = ManageVeeaHubsViewController.new(mesh: mesh,
                                                  meshDetailViewModel: meshDetailViewModel)
        case .CellularUsage:
            vc = UIStoryboard(name: destination.rawValue, bundle: nil).instantiateInitialViewController() as! HomeCellularUsageViewController
        case .SecuritySettings:
            vc = SecuritySettingsTopLevelViewController.new()
        case .NetworkSpeedTest:
            vc = UIViewController()
        case .AdvancedNetworkSettings:
            vc = UIViewController()
        case .MyAccount:
            vc = UIStoryboard(name: destination.rawValue, bundle: nil).instantiateInitialViewController() as! MyAccountTableViewController
        case .Support:
            vc = GuidesViewController()
        }
        
        vc?.title = dashboardItem.pageTitle
        
        return vc
    }
}
