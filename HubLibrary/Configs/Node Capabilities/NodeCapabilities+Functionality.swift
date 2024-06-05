//
//  NodeCapabilities+Functionality.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 03/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

extension NodeCapabilities {
    
    public var hasWifiSecurity: Bool {
        return functionality.contains("wifi-security")
    }
    
    public var isWpa2Only: Bool {
        return functionality.contains("wifi-wpa2-only")
    }
    
    public var wifi802_11rAvailable: Bool {
        return functionality.contains("wifi-80211r")
    }
    
    public var hasWifiRadioAcs: Bool {
        return functionality.contains("wifi-radio-acs")
    }
    
    public var hasWifiRadioBkgndScan: Bool {
        return functionality.contains("wifi-radio-bkgnd-scan")
    }
}
