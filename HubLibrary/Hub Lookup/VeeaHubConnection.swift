//
//  IES.swift
//  HubLibrary
//
//  Created by Al on 27/02/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation
import SharedBackendNetworking
import UIKit

public protocol VeeaHubChangeObserver {
    func lanIpDetailsChanged(sender: VeeaHubConnection)
    
    // TODO: Add a method for beacon changes
}

/// Describes the the LOCAL connection options for the VeeaHub
/// This calls used to only cover connection via Beacon and AP
/// It has been extended to add support for Override IP, DNS and mDNS
/// Given the availability some variables may be empty. For example...
/// A hub might be available via DNS but not be within wireless connection range
open class VeeaHubConnection: HubConnectionDefinition {
    public var delegate: VeeaHubChangeObserver?
    
    private let tag = "VeeaHub"
    private let validationThreshold: TimeInterval = 20
    var pings = [PingProtocol]()
    
    public var connectionRoute: ConnectionRoute = .CURRENT_GATEWAY
    
    /// Returns true if the hub has a beacon, dns ip or mdns ip
    public var hasDefinedConnectionRoute: Bool {
        get {
            if beacon != nil && signalStrength != .NO_SIGNAL {
                let timeout = 15 // timeout 15 seconds
                let timeSinceSeen = Int(Date().timeIntervalSince(beacon!.lastSeen as Date))
                return timeSinceSeen <= timeout
            }
            
            return hasIpOnLan
        }
    }
    
    public var hasApInRange: Bool {
        if beacon != nil && signalStrength != .NO_SIGNAL {
            return true
        }
        
        return false
    }
    
    public var hasIpOnLan: Bool {
        if let ip = hubDnsIp {
            if dnsValidated {
                return !ip.isEmpty
            }
        }
        
        return false
    }
    
    private let kHttps = "https://"
    private let notAvailable = 127
    
    /// The full name of the Hub used when looking up DNS and mDNS records
    public var hubId: String?
    
    /// The name of the hub. This is  based on the hubId
    public var hubName: String?
    
    /// Returns a name for the hub. Guaranteed to return something.
    /// This is intended for display in the UI
    public var hubDisplayName: String {
        get {
            if let n = hubName {
                return n
            }
            else if !ssid.isEmpty {
                return ssid
            }
            
            return "Veea Hub"
        }
    }
    
    /// The hubs DNS IP
    public var hubDnsIp: String? {
        didSet {
            if hubDnsIp == "127.0.1.1" {
                hubDnsIp = nil
                delegate?.lanIpDetailsChanged(sender: self)
            }
            
            if hubDnsIp != oldValue {
                dnsValidated = false
                validateIp(ip: hubDnsIp)
                
                return
            }
            
            if timeToCheckIp(last: dnsLastValidated) {
                validateIp(ip: hubDnsIp)
            }
        }
    }
    
    private var dnsValidated: Bool {
        didSet {
            if oldValue != dnsValidated {
                self.delegate?.lanIpDetailsChanged(sender: self)
            }
        }
    }
    
    private var dnsLastValidated: TimeInterval
    
    fileprivate var beacon: VeeaBeacon?
    
    // MARK: - AP properties
    
    /// The SSID of the AP if one is within range
    public var ssid: String {
        get {
            return beacon?.ssid ?? ""
        }
        set {
            beacon?.setSsid(ssid: newValue)
        }
    }
    
    /// The PSK of the AP if one is within range
    public var psk: String {
        return beacon?.psk ?? ""
    }
    
    // MARK: - Init Methods
    
    /// Create and populate from Beacon Details
    ///
    /// - Parameter beacon: The beacon
    init(beacon: VeeaBeacon) {
        self.beacon = beacon
        dnsValidated = false
        
        let now = Date().timeIntervalSince1970
        dnsLastValidated = now
    }
    
    /// Create an Empty IES
    public init() {
        dnsValidated = false
        
        let now = Date().timeIntervalSince1970
        dnsLastValidated = now
    }
    
    /// Create an Empty IES
    public init(veeaHubId: String, veeaHubName: String) {
        hubId = veeaHubId
        hubName = veeaHubName
        
        dnsValidated = false

        let now = Date().timeIntervalSince1970
        dnsLastValidated = now
    }
}

extension VeeaHubConnection: Equatable {
    public static func == (lhs: VeeaHubConnection, rhs: VeeaHubConnection) -> Bool {
        let same = lhs.ssid == rhs.ssid && lhs.signalStrength == rhs.signalStrength
        
        // The RSSI changes all the time and will result in constant changes to the UI that can cause issues
        
        return same
    }
}

// MARK: - API URLS
extension VeeaHubConnection {
    
    /// The IP of the hubs AP
    ///
    /// - Returns: The hubs AP IP address. Unless overriden
    public func getHubIp() -> String {
        if WiFi.shouldOverideGateway {
            return WiFi.getHubAddress()
        }
        
        if connectionRoute == .DNS {
            if hubDnsIp != nil && !hubDnsIp!.isEmpty {
                return hubDnsIp!
            }
        }
        
        return WiFi.getHubAddress()
    }
    
    public func getBaseURL() -> String {
        return "\(kHttps)\(getHubIp()):21200/api/v1/"
    }
}

// MARK: - Beacon
extension VeeaHubConnection {
    public enum SignalStrength: Int {
        case POOR
        case OK
        case GOOD
        case NO_SIGNAL
        
        public func getSignalStrengthDescription() -> String {
            switch self {
            case .GOOD:
                return "Good"
            case .OK:
                return "Ok"
            case .POOR:
                return "Poor"
            default:
                return "No Signal"
            }
        }
        
        public func getColorForStrength() -> UIColor {
            switch self {
            case .GOOD:
                return UIColor(red:0.30, green:0.69, blue:0.31, alpha:1.0)
            case .OK:
                return UIColor(red:1.00, green:0.76, blue:0.03, alpha:1.0)
            case .POOR:
                return UIColor(red:0.96, green:0.20, blue:0.21, alpha:1.0)
            default:
                return UIColor.lightGray
            }
        }
    }
    
    func updateBeacon(beacon: VeeaBeacon) {
        self.beacon = beacon
    }
    
    public func removeBeacon() {
        self.beacon = nil
    }
    
    /// - rssi: the RSSI of the IES's Eddystone beacon
    public var rssi: Int {
        guard let beacon = beacon else {
            return -127
        }
        
        if beacon.rssi.intValue == notAvailable {
            return -127
        }
        
        return beacon.rssi.intValue
    }
    
    public var veeaHubHasBeacon: Bool {
        get {
            if beacon == nil {
                return false
            }
            
            return true
        }
    }
    
    public var signalStrength: SignalStrength {
        get {
            if beacon == nil {
                return .NO_SIGNAL
            }
            
            switch rssi {
            case -50 ..< 0:
                return .GOOD
            case -60 ..< -50:
                return .OK
            default:
                return .POOR
            }
        }
    }
}

// MARK: - Validation
extension VeeaHubConnection {
    
    private func timeToCheckIp(last: TimeInterval) -> Bool {
        let now = Date().timeIntervalSince1970
        let diff = now - last
        
        if diff > validationThreshold {
            return true
        }
        
        return false
    }
    
    private func validateIp(ip: String?) {
        guard let ip = ip else {
            return
        }
        
        // Check if we are pinging this address already
        if let p = pings.first(where: {$0.host == ip}) {
            if p.pingState == .pinging {
                return
            }
            else {
                // Remove the last ping and move on to pinging again
                if let i = pings.firstIndex(where: {$0 === p}) {
                    pings.remove(at: i)
                }
            }
        }

        let ping = PingFactory.newPing(hostName: ip)
        pings.append(ping)
        ping.sendPing { result in
            if result == .pingDidFail {
                Logger.log(tag: self.tag, message: "Validation of '\(ip) failed.")

                if self.hubDnsIp == ip {
                    self.dnsValidated = false
                    self.dnsLastValidated = Date().timeIntervalSince1970
                }
            }
            else if result == .pingDidTimeOut {
                Logger.log(tag: self.tag, message: "Validation of '\(ip) timed out")

                if self.hubDnsIp == ip {
                    self.dnsValidated = false
                    self.dnsLastValidated = Date().timeIntervalSince1970
                }
            }
            else if result == .pingDidSucceed {
                Logger.log(tag: self.tag, message: "Validation of '\(ip) succeded")
                if self.hubDnsIp == ip {
                    self.dnsValidated = true
                    self.dnsLastValidated = Date().timeIntervalSince1970
                }
            }
        }
    }
}

// MARK: - Debug
extension VeeaHubConnection : CustomDebugStringConvertible {
    public var debugDescription: String {
        var description = "\n\n**Hub Name: \(hubDisplayName)**  \n"
        description.append("Hub IP for session is: \(getHubIp())  \n")
        
        if hasApInRange {
            description.append("Has a beacon showing SSID: \(beacon?.ssid ?? "Unknown SSID"). Signal Strength: \(beacon?.rssi ?? 0)  \n")
        }
        
        description.append("Connection route is: \(connectionRoute.getDescription())\n")
        
        if hasIpOnLan {
            if let ip = hubDnsIp {
                description.append("DNS record shows hub at: \(ip)")
            }
        }
        else {
            description.append("No IP on Lan  \n")
        }
        
        description.append("\n\n")
        
        return description
    }
}
