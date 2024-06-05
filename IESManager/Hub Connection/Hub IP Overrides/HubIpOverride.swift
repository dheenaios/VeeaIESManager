//
//  OverrideHubManager.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 25/07/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation


class HubIpOverride {
    
    private static let ipKey = "ipKey"
    private static let shouldOverrideGateway = "shouldOverrideGateway"
    
    public static var overrideIpAddress: String? {
        get {
            return UserDefaults.standard.string(forKey: ipKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ipKey)
            WiFi.overrideIPAddress = newValue ?? "" // TODO: Remove this when we update the IES. to cover dns etc
        }
    }
    
    public static var shouldOverrideHubIp: Bool {
        get {
            return UserDefaults.standard.bool(forKey: shouldOverrideGateway)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: shouldOverrideGateway)
            WiFi.shouldOverideGateway = newValue
        }
    }
}
