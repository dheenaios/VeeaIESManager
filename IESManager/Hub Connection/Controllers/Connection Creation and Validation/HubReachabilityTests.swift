//
//  LanConnectionController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 08/08/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking



/// Checks that the hub is reachable
public class HubReachabilityTests {
    
    private static let TAG = "HubReachabilityTests"
    private static var ping: PingProtocol?
    
    /// Call back for async responses
    /// Bool for success. String for message
    public typealias HubReachabilityTestCompletionBlock = (Bool, String) -> Void
    
    public static func canPingDevice(at ip: String, completion: @escaping HubReachabilityTestCompletionBlock) {
        Logger.log(tag: TAG, message: "Making test ping too \(ip)")
        ping = PingFactory.newPing(hostName: ip)
        ping?.sendPing(stateChange: { result in
            if result == .pingDidSucceed {
                Logger.log(tag: TAG, message: "Ping to \(ip) succeded")
                completion(true, "Succeeded");
            }
            else if result == .pingDidTimeOut {
                Logger.log(tag: TAG, message: "Ping to \(ip) failed as  \(result.description())")
                completion(false, "Ping Timedout");
            }
            else {
                Logger.log(tag: TAG, message: "Ping to \(ip) failed as  \(result.description())")
                completion(false, "Ping Failed");
            }
        })
    }
}

// MARK: - Local (on device) Checks
extension HubReachabilityTests {
    public static func doesDeviceHaveIP() -> Bool {
        if Platform.isSimulator {
            return true
        }
        
        guard let wifiAddress = WiFi.getWiFiAddress() else {
            return false
        }
        
        if  wifiAddress.isEmpty  {
            return false
        }
        
        return true
    }
    
    public static func doesDeviceHaveDefaultGateway() -> Bool {
        if Platform.isSimulator {
            return true
        }
        
        let gateway = WiFi.getGatewayAddress()
        if gateway == "0.0.0.0" {
            return false
        }
        
        return true
    }
}
