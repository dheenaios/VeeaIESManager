//
//  PublicWifiNavigationController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 06/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit


class PublicWifiNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // If there is only one allowed operator then just show the config screen
        showSoloConfigIfNeeded()
    }
    
    /// If there is only one operator then show that without need for selection
    private func showSoloConfigIfNeeded() {
        let dm = HubDataModel.shared
        let optionalApps = dm.optionalAppDetails
        
        guard let operators = optionalApps?.publicWifiOperatorsConfig,
            let publicWifiSettings = optionalApps?.publicWifiSettingsConfig else {
            return
        }
        
        let allowedOperators = publicWifiSettings.allowed_operators
        
        if allowedOperators.count == 1 {
            let operatorName = allowedOperators.first
            
            let operatorConfigs = operators.wifiOperators
            for config in operatorConfigs {
                if config.supplierName == operatorName {
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "PublicWifiStoryboard", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "ProviderConfigurationTableViewController") as? ProviderConfigurationTableViewController
                    
                    if let vc = vc {
                        vc.selectedDefaultProviderDetails = config
                        vc.isTheCurrentlySelectedProvider = publicWifiSettings.selected_operator == operatorName
                        
                        setViewControllers([vc], animated: false)
                    }
                }
            }
        }
    }
}
