//
//  MasConnectionController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 14/10/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking



public class MasConnectionController: ConnectionProtocol {
    public var connectionType: ConnectionRoute
    public var connectionState: HubConnectionState
    public var delegate: ConnectionProgressProtocol
    public var connectionDefinition: HubConnectionDefinition
    public var veeaHub: VeeaHubConnection
    
    /// Should we fail if the MAS is available but the hub is not currently connected?
    public var doAvailablityCheck = true
    
    private let tag = "MasConnectionController"
    
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
        logToGA(stage: .start)

        connectionState = .IN_PROGRESS
        veeaHub.connectionRoute = connectionType
        delegate.connectionAttemptStarted(connectionRoute: self)
    
        getMasInfo { (success, errorMessage) in

            self.logToGA(stage: success ? .succeed : .fail)

            if !success {
                self.connectionState = .FAILED
                self.delegate.getHubDataModelComplete(success: false,
                                                      failMessage: errorMessage ?? "Unknown Error".localized(),
                                                      connectionRoute: self)
                
                self.stopConnectionAttempt()
                
                return
            }
        }
    }
    
    private func getMasInfo(completion: @escaping(SuccessAndOptionalMessage) -> Void) {
        // Get the hub details
        guard let nodeSerial = veeaHub.hubId,
              let token = AuthorisationManager.shared.formattedAuthToken else {
            //print("Hub ID is missing")
                  completion((false, "Hub details missing. Could not connect".localized()))
            return
        }
        
        MasConnectionFactory.makeMasConnectionFor(nodeSerial: nodeSerial,
                                                  apiToken: token,
                                                  baseUrl: BackEndEnvironment.masApiBaseUrl) { (success, connection) in
            
            // TODO: The method above needs changing to return info about IF the hub is active.
            // We then branch from there depending in the doAvailablityCheck bool
            
            if !success {
                completion((false, "Could not get hub details".localized()))
                return
            }
            
            guard let connection = connection else {
                completion((false, "Could not get hub details (2)".localized()))
                return
            }
            
            if self.doAvailablityCheck && !connection.wasAvailable {
                // Then this failed as we want the hub to be available now
                completion((false, "Hub is not currently connected to the MAS".localized()))
                return
            }
            
            HubDataModel.shared.connectedVeeaHub = connection
            HubDataModel.shared.updateConfigInfo(observer: self)
        }
    }
    
    public func stopConnectionAttempt() {
        connectionState = .STOPPED
    }
}

extension MasConnectionController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        if self.connectionState == .STOPPED {
            return
        }
        
        Logger.log(tag: tag, message: "MAS Data model get completed: \(success ? "success" : "failed"). \(message ?? "")")
        
        self.connectionState = success ? .SUCCEDED : .FAILED
        delegate.getHubDataModelComplete(success: success,
                                         failMessage: message,
                                         connectionRoute: self)
    }
    
    func updateDidProgress(progress: Float, message: String?) {
        // No need to do anything here
    }
}

extension MasConnectionController {
    private func logToGA(stage: AnalyticsEvents.ApiConnection.ConnectionStage) {
        let connectionDetails = AnalyticsEvents.ApiConnection(route: .mas, stage: stage)
        AnalyticsEventHelper.logConnection(connection: connectionDetails)
    }
}
