//
//  IESAuthorisationAndInitialUpdateController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 05/11/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation


protocol HubApConnectionValidationObserverDelegate: AnyObject {
    
    /// The connection to the Hub was a success
    func iesConnectionSucceded()
    
    /// The connection to the IES Failed
    ///
    /// - Parameters:
    ///   - userReadableDescription: An error description to be presented to the user and logged
    ///   - failureReason: The failure reason as an enum so we can take action of the type of failure
    func iesConnectionFailed(userReadableDescription: String, failureReason: HubConnectionValidationObserver.FailureReason)
}

/// Performs checks to ensure the network is set up in such a way that the hub can be reached
class HubConnectionValidationObserver {
    
    public enum FailureReason {
        case NoDefaultGateway
        case NoIPAssigned
        case ConnectionIssue
    }
    
    private static let tag = "IESAuthorisationController"
    
    private var attemptCounter = 0 // Running check
    private let maxIPAssigmentTests = 10 // Number of times we check we have a gateway and IP
    
    private let waitTime = 2 // Time between test attempts
    
    private weak var delegate: HubApConnectionValidationObserverDelegate?
    private var selectedConnection: VeeaHubConnection?
    
    
    /// Perform network tests to ensure the Hub can be reached. Note that this process does not check the API
    ///
    /// - Parameters:
    ///   - connection: The connection to be tested
    ///   - delegate: Callback for test results
    func beginNetworkTestsFor(connection: VeeaHubConnection, delegate: HubApConnectionValidationObserverDelegate) {
        
        self.delegate = delegate
        self.selectedConnection = connection
        
        attemptCounter = 0
        
        checkForDefaultGateway()
    }
    
    private func checkForDefaultGateway() {
        if !HubReachabilityTests.doesDeviceHaveDefaultGateway() {
            if attemptCounter < maxIPAssigmentTests {
                attemptCounter += 1
                
                Logger.log(tag: HubConnectionValidationObserver.tag, message: "No default gateway assigned yet. Waiting 2 seconds then will check again")
                
                let delay = DispatchTime.now() + .seconds(waitTime)
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.checkForDefaultGateway()
                }
            }
            else {
                let message = "No default gateway assigned ending connection attempt".localized()
                self.reportError(message: message, reason: .NoDefaultGateway)
            }
        }
        else {
            // We have the Default Gateway, check to make sure the AP is correct?
            
            if apIsAsExpected() {
                Logger.log(tag: HubConnectionValidationObserver.tag, message: "Default gateway is \(WiFi.getGatewayAddress())")
                attemptCounter = 0
                checkForAssignedIP()
            }
            else {
                let message = "Default gateway assigned but AP is not as expected. Looks like connection was dropped.".localized()
                self.reportError(message: message, reason: .NoDefaultGateway)
            }
        }
    }

    /// Checks if the AP is the same as the the hub AP
    /// - Returns: is it the same
    private func apIsAsExpected() -> Bool {
        if selectedConnection?.connectionRoute != .CURRENT_GATEWAY {
            return true
        }
        
        guard let expectedSsid = selectedConnection?.ssid else {
            return false
        }
        
        return HubApWifiConnectionManager.currentSSID == expectedSsid ? true : false
    }
    
    private func checkForAssignedIP() {
        if HubReachabilityTests.doesDeviceHaveIP() == false {
            if attemptCounter < maxIPAssigmentTests {
                attemptCounter += 1
                
                Logger.log(tag: HubConnectionValidationObserver.tag, message: "No device IP assigned yet. Waiting 2 seconds then will check again")
                
                let delay = DispatchTime.now() + .seconds(waitTime)
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.checkForAssignedIP()
                }
            }
            else {
                let message = "No IP address assigned to this device".localized()
                self.reportError(message: message, reason: .NoIPAssigned)
            }
        }
        else {
            Logger.log(tag: HubConnectionValidationObserver.tag, message: "Device IP is \(WiFi.getWiFiAddress() ?? "ERROR!!!"). Beginning reachability checks")
            attemptCounter = 0
            testHubReachability()
        }
    }
    
    private func testHubReachability() {
        Logger.log(tag: HubConnectionValidationObserver.tag, message: "Testing hub reachability")
        
        if HubApWifiConnectionManager.shared.isCurrentWifiNetworkAsExpected() == true {
            guard let ipAddress = self.selectedConnection?.getHubIp() else {
                let message = "No IP gateway IP address".localized()
                reportError(message: message, reason: .ConnectionIssue)
                
                return
            }
            
            HubReachabilityTests.canPingDevice(at: ipAddress) { (success, message) in
                if success == true {
                    self.delegate?.iesConnectionSucceded()
                }
                else {
                    let delay = DispatchTime.now() + .seconds(1)
                    DispatchQueue.main.asyncAfter(deadline: delay) {
                        HubReachabilityTests.canPingDevice(at: ipAddress) { (success, message) in
                            if success == true {
                                self.delegate?.iesConnectionSucceded()
                            }
                            else {
                                let message = "Could not ping the hub at".localized()
                                self.reportError(message: "\(message)  \(ipAddress)", reason: .ConnectionIssue)
                            }
                        }
                    }
                }
            }
        }
        else {
            let start = "This device is no longer connected to the hub. It is now connected to".localized()
            
            let message = "\(start) \(HubApWifiConnectionManager.currentSSID ?? "unknown SSID")"
            reportError(message: message, reason: .ConnectionIssue)
        }
    }
}

// MARK: - Reporting helper methods
extension HubConnectionValidationObserver {
    private func reportError(message: String, reason: FailureReason) {
        Logger.log(tag: HubConnectionValidationObserver.tag, message: message)
        delegate?.iesConnectionFailed(userReadableDescription: message, failureReason: reason)
        delegate = nil
    }
}
