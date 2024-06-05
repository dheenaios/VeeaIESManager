//
//  HubApConnectionController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 20/08/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import UIKit


#if !arch(i386) && !arch(x86_64)
import NetworkExtension
#endif

public class HubApConnectionController: ConnectionProtocol {
    public var connectionDefinition: HubConnectionDefinition
        
    private let tag = "HubApConnectionController"
    
    public var veeaHub: VeeaHubConnection
    public var connectionState: HubConnectionState
    public var delegate: ConnectionProgressProtocol
    public var connectionType: ConnectionRoute
    
    private lazy var wifiConnectionTester: HubConnectionValidationObserver = {
        return HubConnectionValidationObserver()
    }()
    
    public required init?(hub: HubConnectionDefinition,
                          connectionType: ConnectionRoute,
                          progressDelegate: ConnectionProgressProtocol) {
        connectionDefinition = hub
        if let hub = connectionDefinition as? VeeaHubConnection {
            veeaHub = hub
        }
        else {
            return nil
        }
        
        connectionState = .NOT_STARTED
        self.delegate = progressDelegate
        self.connectionType = connectionType
    }
    
    
    public func startConnectionAttempt() {
        Logger.log(tag: tag, message: "Starting attempt for hub named: \(veeaHub.hubName ?? "Unknown")")
        // Disconnect from any existing AP
        WiFi.disconnectFromAllNetworks()
        
        let delay = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.beginConnectionAttempt()
        }
    }
    
    private func beginConnectionAttempt() {
        connectionState = .IN_PROGRESS
        veeaHub.connectionRoute = connectionType
        delegate.connectionAttemptStarted(connectionRoute: self)
        
        let topVc = UIApplication.topViewController()
        
        let alert = UIAlertController.init(title: "Changing Wi-Fi Network".localized(),
                                           message: "The VeeaHub Manager will try to connect using your VeeaHub Wi-Fi network. This will temporarily disconnect your phone from your current Wi-Fi network.".localized(),
                                           preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Cancel".localized(), style: .cancel, handler: { (alert) in
            self.stopConnectionAttempt()
            self.delegate.networkConnectionValidated(success: false,
                                                     message: "Could not connect to hub AP".localized(),
                                                     connectionRoute: self)
            
        }))
        
        alert.addAction(UIAlertAction.init(title: "Continue".localized(), style: .default, handler: { (alert) in
            self.connectToWifi()
        }))
        
        topVc?.present(alert, animated: true, completion: nil)
    }
    
    public func stopConnectionAttempt() {
        connectionState = .STOPPED
    }
}

// MARK: - WiFi connection
extension HubApConnectionController {
    private func connectToWifi() {
        logToGA(stage: .start)
        
        HubApWifiConnectionManager.shared.connectToHotSpot(veeaHub: veeaHub) { (success, errorMessage) in
            if self.connectionState == .STOPPED {
                return
            }
            
            if success {
                Logger.log(tag: self.tag, message: "Hotspot connection succeded")
                self.delegate.networkConnectionValidated(success: true, message: "wifi-connected", connectionRoute: self)
                
                self.waitForIP()
                
                return
            }
            
            self.logToGA(stage: .fail)
            Logger.log(tag: self.tag, message: "Hotspot connect failed with error: \(errorMessage ?? "Unknown")")

            if let errorMessage = errorMessage {
                self.delegate.networkConnectionValidated(success: false,
                                                         message: errorMessage,
                                                         connectionRoute: self)
            }
            else {
                self.delegate.networkConnectionValidated(success: false,
                                                         message: "Unknown error".localized(),
                                                         connectionRoute: self)
            }
        }
    }
    
    private func waitForIP() {
        wifiConnectionTester.beginNetworkTestsFor(connection: veeaHub, delegate: self)
    }
}

extension HubApConnectionController: HubApConnectionValidationObserverDelegate {
    func iesConnectionSucceded() {
        logToGA(stage: .succeed)
        if self.connectionState == .STOPPED {
            return
        }
        
        self.delegate.networkConnectionValidated(success: true, message: "got-ip", connectionRoute: self)
        
        testPing()
    }
    
    func iesConnectionFailed(userReadableDescription: String, failureReason: HubConnectionValidationObserver.FailureReason) {
        logToGA(stage: .fail)
        if self.connectionState == .STOPPED {
            return
        }
        
        self.delegate.networkConnectionValidated(success: false, message: "Could not get IP: \(failureReason)", connectionRoute: self)
        stopConnectionAttempt()
    }
}

// MARK: - Test ping and Get Data model
extension HubApConnectionController {
    fileprivate func testPing() {
        
        // Covers iOS 13
        guard let currentSsid = HubApWifiConnectionManager.currentSSID else {
            delegate.errorWithVeeaHub(errorMessage: "Connection to the VeeaHubs Wi-Fi was dropped (1)".localized())
            return
        }
        
        // Covers pre-iOS 13
        if currentSsid != veeaHub.ssid {
            delegate.errorWithVeeaHub(errorMessage: "Connection to the VeeaHubs Wi-Fi was dropped (1a)".localized())
            return
        }
        
        
        
        let ipToTest = veeaHub.getHubIp()
        
        // Give a 1 seconds delay to let the AP connection settle
        let delay = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            Logger.log(tag: self.tag, message: "Beginning ping test 1 to \(ipToTest)")
            
            HubReachabilityTests.canPingDevice(at: ipToTest) { (success, message) in
                if self.connectionState == .STOPPED {
                    return
                }
                
                Logger.log(tag: self.tag, message: "Ping 1 result \(success ? "passed. Moving on to get data" : "failed. Will try again in 1 second")")
                
                if success {
                    self.delegate.testPingResult(
                        success: success,
                        failMessage: "\(ipToTest): \(message)",
                        connectionRoute: self)
                    
                    self.getDataModel()
                }
                else { // Wait a seconds and try again
                    DispatchQueue.main.asyncAfter(deadline: delay) {
                        if self.connectionState == .STOPPED {
                            return
                        }
                        
                        HubReachabilityTests.canPingDevice(at: ipToTest) { (success, message) in
                            if self.connectionState == .STOPPED {
                                return
                            }
                            
                            Logger.log(tag: self.tag, message: "Ping 2 result \(success ? "passed. Moving on to get data" : "failed. Ending connection attempt")")
                            
                            if success {
                                self.delegate.testPingResult(
                                    success: success,
                                    failMessage: "\(ipToTest): \(message)",
                                    connectionRoute: self)
                                
                                self.getDataModel()
                            }
                            else {
                                self.logToGA(stage: .fail)
                                self.connectionState = .FAILED
                                self.stopConnectionAttempt()
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getDataModel() {
        guard let currentSsid = HubApWifiConnectionManager.currentSSID else {
            delegate.errorWithVeeaHub(errorMessage: "Connection to the VeeaHubs Wi-Fi was dropped (2)".localized())
            return
        }
        
        // Covers pre-iOS 13
        if currentSsid != veeaHub.ssid {
            delegate.errorWithVeeaHub(errorMessage: "Connection to the VeeaHubs Wi-Fi was dropped (2a)".localized())
            return
        }
        
        Logger.log(tag: tag, message: "Getting data model")
        self.connectionState = .IN_PROGRESS
        HubDataModel.shared.connectedVeeaHub = veeaHub
        HubDataModel.shared.updateConfigInfo(observer: self)
    }
}

extension HubApConnectionController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        if self.connectionState == .STOPPED {
            return
        }
        
        Logger.log(tag: tag, message: "Data model get completed: \(success ? "success" : "failed"). \(message ?? "")")
        
        self.connectionState = success ? .SUCCEDED : .FAILED
        delegate.getHubDataModelComplete(success: success,
                                         failMessage: message,
                                         connectionRoute: self)
    }
    
    func updateDidProgress(progress: Float, message: String?) {
        // No need to do anything here
    }
}

extension HubApConnectionController {
    private func logToGA(stage: AnalyticsEvents.ApiConnection.ConnectionStage) {
        let connectionDetails = AnalyticsEvents.ApiConnection(route: .ap, stage: stage)
        AnalyticsEventHelper.logConnection(connection: connectionDetails)
    }
}
