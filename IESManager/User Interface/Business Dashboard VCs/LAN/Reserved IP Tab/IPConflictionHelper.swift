//
//  IPConflictionHelper.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 04/11/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

class IPConflictionHelper {
    
    
    /// Has the user committed settings for Dhcp for a given Lan?
    /// - Parameter lan: The Lan in question. Zero indexed. So Lan 1 = 0. Lan 4 = 3
    public static func areDhcpIpSettingsForLan(lanIndex: Int) -> Bool {
        guard let config = HubDataModel.shared.optionalAppDetails?.nodeLanConfig else {
            return false
        }
        
        let lan = config.lans[lanIndex]
        var starting = lan.start_ip
        var end = lan.end_ip
        
        if starting.isEmpty || end.isEmpty {
            let defaultLan = DefaultLanHelper()
            let lanDetails = defaultLan.getDefultRangeDetails(selectedLanNumber: lanIndex)
            
            starting = lanDetails.0
            end = lanDetails.1
            
            if starting.isEmpty || end.isEmpty {
                return false
            }
        }
        
        return true
    }
    
    /// Has the user commited settings for Reserved IP addresses for a given Lan?
    /// - Parameter lan: The Lan in question. Zero indexed. So Lan 1 = 0. Lan 4 = 3
    public static func areStaticIpSettingsForLan(lan: Int) -> Bool {
        guard let config = HubDataModel.shared.optionalAppDetails?.nodeLanStaticIpConfig else {
            return false
        }
        
        let lanModels = config.lans[lan]
        
        for item in lanModels {
            if !item.ip.isEmpty {
                return true
            }
        }
        
        return false
    }
}
