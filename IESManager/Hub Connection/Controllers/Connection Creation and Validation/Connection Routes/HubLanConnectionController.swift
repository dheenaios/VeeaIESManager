//
//  HubLanConnectionController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 20/08/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation


public class HubLanConnectionController: ConnectionProtocol {
    public var connectionDefinition: HubConnectionDefinition
    
    private let tag = "HubLanConnectionController"
    
    public var veeaHub: VeeaHubConnection
    public var connectionState: HubConnectionState
    public var delegate: ConnectionProgressProtocol
    public var connectionType: ConnectionRoute
    
    public required init?(hub: HubConnectionDefinition,
                          connectionType: ConnectionRoute,
                          progressDelegate: ConnectionProgressProtocol) {
        connectionDefinition = hub
        if let hub = hub as? VeeaHubConnection {
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
        logToGA(stage: .start)
        
        connectionState = .IN_PROGRESS
        veeaHub.connectionRoute = connectionType
        delegate.connectionAttemptStarted(connectionRoute: self)
        
        // Check we are on a network
        if !HubReachabilityTests.doesDeviceHaveDefaultGateway() {
            logToGA(stage: .fail)
            connectionState = .FAILED
            delegate.networkConnectionValidated(success: false,
                                                message: "No default gateway".localized(),
                                                connectionRoute: self)
            Logger.log(tag: tag, message: "Phone has no default gateway. Stopping)")
            stopConnectionAttempt()
            
            return
        }
        
        testPing()
    }
    
    public func stopConnectionAttempt() {
        connectionState = .STOPPED
    }
}

extension HubLanConnectionController {
    fileprivate func testPing() {
        var ip: String?
        
        if connectionType == .DNS {
            ip = veeaHub.hubDnsIp
        }
        
        guard let ipToTest = ip else {
            let start = "The VeeaHub did not have a".localized()
            let end = "IP".localized()
            
            delegate.errorWithVeeaHub(errorMessage: "\(start) \(connectionType.getDescription()) \(end)")
            Logger.log(tag: tag, message: "Error, no IP address")

            logToGA(stage: .fail)
            
            return
        }
        
        Logger.log(tag: tag, message: "Beginning ping test to \(ipToTest)")
        
        HubReachabilityTests.canPingDevice(at: ipToTest) { (success, message) in
            if self.connectionState == .STOPPED {
                return
            }
            
            self.delegate.testPingResult(success: success,
                                       failMessage: message,
                                       connectionRoute: self)
            
            if !success {
                self.connectionState = .FAILED
                self.logToGA(stage: .fail)
                return
            }
            Logger.log(tag: self.tag, message: "Ping result \(success ? "passed" : "failed")")
            self.getDataModel()
        }
    }
    
    private func getDataModel() {        
        self.connectionState = .IN_PROGRESS
        HubDataModel.shared.connectedVeeaHub = veeaHub
        HubDataModel.shared.updateConfigInfo(observer: self)
        Logger.log(tag: tag, message: "Getting data model")
    }
}

extension HubLanConnectionController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        if self.connectionState == .STOPPED {
            return
        }
        
        Logger.log(tag: tag, message: "Data model get completed: \(success ? "success" : "failed"). \(message ?? "")")
        
        self.connectionState = success ? .SUCCEDED : .FAILED
        logToGA(stage: success ? .succeed : .fail)
        delegate.getHubDataModelComplete(success: success,
                                         failMessage: message,
                                         connectionRoute: self)
    }
    
    func updateDidProgress(progress: Float, message: String?) {
        // No need to do anything here
    }
}

extension HubLanConnectionController {
    private func logToGA(stage: AnalyticsEvents.ApiConnection.ConnectionStage) {
        let connectionDetails = AnalyticsEvents.ApiConnection(route: .lan, stage: stage)
        AnalyticsEventHelper.logConnection(connection: connectionDetails)
    }
}

