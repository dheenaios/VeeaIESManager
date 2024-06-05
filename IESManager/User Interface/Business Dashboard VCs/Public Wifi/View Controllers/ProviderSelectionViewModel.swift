//
//  ProviderSelectionViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class ProviderSelectionViewModel: BaseConfigViewModel {
    
    var publicWifiConfig = HubDataModel.shared.optionalAppDetails?.publicWifiOperatorsConfig
    
    var publicWifiSettings = HubDataModel.shared.optionalAppDetails?.publicWifiSettingsConfig
        
    enum OperatorOptions: Int {
        case Socifi = 0
        case Purple = 1
        case Hotspot = 2
        case GlobalReach = 3
        
        func supplierIdString() -> String {
            switch self {
            case .Socifi:
                return "socifi"
            case .Purple:
                return "purple"
            case .Hotspot:
                return "hotspot"
            case .GlobalReach:
                return "globalreach"
            }
        }
    }
}
