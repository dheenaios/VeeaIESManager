//
//  IESConnectionManager.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 04/07/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation


#if !arch(i386) && !arch(x86_64)
import NetworkExtension
#endif

import SystemConfiguration.CaptiveNetwork


/// Manages creation of a wifi connection to a hub
/// You should then use HubConnectionValidationObserver to validate the connection
class HubApWifiConnectionManager {
    let tag = "IESConnectionManager"
    
    static let shared = HubApWifiConnectionManager()
    
    public var currentlyConnectedHub: VeeaHubConnection? {
        didSet {
            Logger.log(tag: tag, message: "Veea Hub ssid changed to: \(currentlyConnectedHub?.ssid ?? "No captured network")")
        }
    }
    
    #if !arch(i386) && !arch(x86_64)
    private var currentConfig: NEHotspotConfiguration?
    #endif

    // iOS 13 returns null if the SSID connection was not created by this app.
    // iOS 12 returns the name of the connected SSID
    public static var currentSSID: String? {
        get {
            guard let ssid = WiFiHelpers.getDeviceSSID() else {
                return nil
            }
            
            return ssid
        }
    }
    
    public func isCurrentWifiNetworkAsExpected() -> Bool {
        
        // If we dont know what the connected hub is then we have nothing to compare, so default to expected
        if currentlyConnectedHub == nil {
            return true
        }
        
        // If we are connected via lan we do not need to check this. Return true.
        guard let connectionRoute = HubDataModel.shared.connectedVeeaHub?.connectionRoute else {
            return true
        }
        
        if connectionRoute != .CURRENT_GATEWAY {
            return true
        }

        // Check we have an ssid accociated with the hub hardware.
        // If we do not then the SSID looks like it has changed
        guard let ssid = currentlyConnectedHub?.ssid else {
            return false
        }

        // If we have all the needed info then do the comparison
        return HubApWifiConnectionManager.currentSSID == ssid ? true : false
    }
}

// MARK: - Creation of Connection
extension HubApWifiConnectionManager {
    public func connectToHotSpot(veeaHub: VeeaHubConnection, completion: @escaping (SuccessAndOptionalMessage) -> Void) {
        Logger.log(tag: tag, message: "Starting connection attempt for \(veeaHub.ssid)")
        
        self.currentlyConnectedHub = veeaHub
        
        #if !arch(i386) && !arch(x86_64)
        currentConfig = NEHotspotConfiguration(ssid: veeaHub.ssid, passphrase: veeaHub.psk, isWEP: false)
        
        NEHotspotConfigurationManager.shared.apply(currentConfig!) {(error) in
            if let error = error {
                self.currentlyConnectedHub = nil
                
                var message = error.localizedDescription
                switch error.code {
                case NEHotspotConfigurationError.alreadyAssociated.rawValue:
                    message = "Already connected to AP"
                case NEHotspotConfigurationError.invalid.rawValue:
                    message = "Invaid connection details"
                case NEHotspotConfigurationError.invalidSSID.rawValue:
                    message = "Invalid SSID"
                case NEHotspotConfigurationError.invalidWPAPassphrase.rawValue:
                    message = "Invalid WPA passphrase"
                case NEHotspotConfigurationError.invalidWEPPassphrase.rawValue:
                    message = "Invalid WEP passphrase"
                case NEHotspotConfigurationError.invalidEAPSettings.rawValue:
                    message = "Invalid EAP settings"
                case NEHotspotConfigurationError.invalidHS20Settings.rawValue:
                    message = "Invaid HS20 settings"
                case NEHotspotConfigurationError.invalidHS20DomainName.rawValue:
                    message = "Invalid domain name"
                case NEHotspotConfigurationError.userDenied.rawValue:
                    message = "User denied connection request"
                case NEHotspotConfigurationError.internal.rawValue:
                    message = "OS Error. Restart device"
                case NEHotspotConfigurationError.pending.rawValue:
                    message = "pending error"
                case NEHotspotConfigurationError.systemConfiguration.rawValue:
                    message = "system configuration error"
                case NEHotspotConfigurationError.unknown.rawValue:
                    message = "unknown error"
                case NEHotspotConfigurationError.joinOnceNotSupported.rawValue:
                    message = "Join once not supported"
                case NEHotspotConfigurationError.applicationIsNotInForeground.rawValue:
                    message = "Appication is not in the foreground"
                case NEHotspotConfigurationError.invalidSSIDPrefix.rawValue:
                    message = "Invalid ssid prefix"
                default:
                    message = "unknown error (code \(error.code)"
                }

                Logger.log(tag: self.tag, message: "Error connecting: \(message)")

                NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: veeaHub.ssid)
                
                completion((false, message))
            }
            else {
                completion((true, nil))
            }
        }
        #endif
    }
}
