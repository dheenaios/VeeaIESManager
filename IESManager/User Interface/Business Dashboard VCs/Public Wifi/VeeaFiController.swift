//
//  VeeaFiController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 20/03/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation


class VeeaFiController {
    
    private static let publicWifiApp = "public_wifi"
    
    static func providerBrandingShouldBeVeeaFi(provider: String) -> Bool {
        guard (HubDataModel.shared.baseDataModel?.installedAppsConfig?.installedAppKeys) != nil else {
            return false
        }
        

        let config = HubDataModel.shared.baseDataModel?.installedAppsConfig?.getAppConfigForAppId(appID: publicWifiApp) as! PublicWifiInstalledAppConfig
        if provider == config.operatorName {
            return config.isVeeaFi
        }
    
        return false
    }
}
