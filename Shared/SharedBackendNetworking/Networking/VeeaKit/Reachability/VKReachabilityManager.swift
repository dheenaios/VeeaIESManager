//
//  VKReachabilityManager.swift
//  VeeaKit
//
//  Created by Atesh Yurdakul on 12/15/17.
//  Copyright © 2017 Max2. All rights reserved.
//

import Foundation
import SystemConfiguration

// See also ConnectivityMonitor.

public enum ReachabilityType {
    case wwan,
    wiFi,
    notConnected
}

open class VKReachabilityManager {
    
    fileprivate static weak var delegate: VKReachabilityManagerDelegate?
    
    /**
     :see: Original post - http://www.chrisdanielson.com/2009/07/22/iphone-network-connectivity-test-example/
     */
    /// Returns true if connected to a network.
    open class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    internal class func isConnectedToNetworkOfType() -> ReachabilityType {
        
        
        //MARK: - TODO Check this when I have an actual iOS 9 device.
        if !self.isConnectedToNetwork() {
            return .notConnected
        }
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notConnected
        }
        
        var flags : SCNetworkReachabilityFlags = []
        
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return .notConnected
        }
        
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        if isReachable && isWWAN {
            return .wwan
        }
        
        if isReachable && !isWWAN {
            return .wiFi
        }
        
        return .notConnected
    }
    
    /// Starts monitoring network changes.
    /// Updates you using the delegation.
    public class func monitorNetworkChanges(delegate: VKReachabilityManagerDelegate? = nil) {
        
        self.delegate = delegate
        
        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!
        
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, info) in
            
            if !flags.contains(SCNetworkReachabilityFlags.connectionRequired) && flags.contains(SCNetworkReachabilityFlags.reachable) {
                VKReachabilityManager.delegate?.reachabilityStatusChanged(status: VKReachabilityManagerStatus.connected)
            } else {
                VKReachabilityManager.delegate?.reachabilityStatusChanged(status: VKReachabilityManagerStatus.disconnected)
            }
            
        }, &context)
        
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
    }
    
}
