//
//  WiFi.swift
//  HubLibrary
//
//  Created by Al on 01/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork


#if !arch(i386) && !arch(x86_64)
import NetworkExtension
#endif

public class WiFi {
    
    private static let TAG = "WiFi"
    
    public static var shouldOverideGateway = false
    public static var overrideIPAddress = ""
    
    
    /// Returns the address of the hub we are talking to. This may be a override value
    ///
    /// - Returns: The hub IP address
    public static func getHubAddress() -> String {
        if shouldOverideGateway == true {
            if overrideIPAddress.isEmpty == false {                
                return overrideIPAddress
            }
        }
        
        return getGatewayAddress()
    }
    
    public static func getGatewayAddress() -> String {
        var gatewayaddr: in_addr = in_addr()
        getdefaultgateway(&gatewayaddr.s_addr)
        
        let gatewayAddress = String(format: "%s", inet_ntoa(gatewayaddr))
        
        return gatewayAddress
    }
    
    // http://stackoverflow.com/questions/30748480/swift-get-devices-ip-address
    public static func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
}

// MARK: - Disconnection
extension WiFi {
    
    public static func disconnectFrom(ssid: String) {
        Logger.log(tag: TAG, message: "Request received to disconnect from \(ssid)")
        
        #if !arch(i386) && !arch(x86_64)
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
        
        #endif
    }
    
    public static func disconnectFromAllNetworks() {
        guard let ssid = WiFiHelpers.getDeviceSSID() else {
            return
        }
        
        disconnectFrom(ssid: ssid)
    }
}
