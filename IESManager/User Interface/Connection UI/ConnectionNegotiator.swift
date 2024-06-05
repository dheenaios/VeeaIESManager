//
//  ConnectionProgressAlertViewModel.swift
//  ConnectionProgressView
//
//  Created by Richard Stockdale on 13/10/2020.
//

import Foundation


public protocol ConnectionNegotiatorCallbacks {
    func shouldUpdateUI()
    func connectionAttemptsFinishedSuccessfully()
    func connectionAttemptsFinishedFailed(message: String)
}

class ConnectionNegotiator {
    
    private let tag = "ConnectionNegotiator"
    
    private var delegate: ConnectionNegotiatorCallbacks
    private(set) var connection: VeeaHubConnection?
    private var routes: [ConnectionProtocol]?
    private var connectionQueueManager: ConnectionQueueManager?
    fileprivate var currentRouteInProgress: ConnectionProtocol?

    public var connectUsingLabelText: String {
        guard let cr = currentRouteInProgress else {
            return "Contacting hub".localized()
        }
        
        return "Connecting using ".localized() + cr.connectionType.getDescription()
    }
    
    // Will return nil if not relevent (i.e. we have connected to the mas)
    public var progress: Float? {
        guard let route = currentRouteInProgress?.connectionType else {
            return nil
        }
        
        if route == .MAS_API {
            return nil
        }
        
        return _progress
    }
    
    private var _progress: Float = 0.0
    
    init(withModel model: VeeaHubConnection,
         updateDelegate: ConnectionNegotiatorCallbacks) {
        
        self.connection = model
        self.delegate = updateDelegate
    }
    
    func startConnectionAttempts() {
        let factory = ConnectionRouteFactory()
        routes = factory.connectionRoutes(hub: connection!, progressDelegate: self)
        
        if routes == nil || routes!.isEmpty {
            delegate.connectionAttemptsFinishedFailed(message: "No available ways to connect to the VeeaHub".localized())
            
            return
        }
        currentRouteInProgress = nil
        connectionQueueManager = ConnectionQueueManager(routes: routes!)
        delegate.shouldUpdateUI()
    }
    
    func stopConnection() {
        connectionQueueManager?.stop()
    }
    
    fileprivate func tryNextConnection() {
        guard let cqm = connectionQueueManager else {
            return
        }
        
        if cqm.hasMore {
            _progress = 0.1
            cqm.tryNextRoute()
            
            if let cr = cqm.routeInProgress {
                currentRouteInProgress = cr
                delegate.shouldUpdateUI()
            }
            
            delegate.shouldUpdateUI()
        }
        else {
            delegate.connectionAttemptsFinishedFailed(message: "Could not make a connection to the Veea Hub".localized())
        }
    }
}

extension ConnectionNegotiator: ConnectionProgressProtocol {
    func errorWithVeeaHub(errorMessage: String) {
        guard let hasMore = connectionQueueManager?.hasMore else {
            return
        }
        
        if hasMore {
            delegate.connectionAttemptsFinishedFailed(message: errorMessage)
        }
    }
    
    func connectionAttemptStarted(connectionRoute: ConnectionProtocol) {
        currentRouteInProgress = connectionRoute
        delegate.shouldUpdateUI()
    }
    
    func networkConnectionValidated(success: Bool, message: String?, connectionRoute: ConnectionProtocol) {
        if !success {
            tryNextConnection()
        }
        else {
            _progress = 0.3
        }
        
        currentRouteInProgress = connectionRoute
        delegate.shouldUpdateUI()
    }
    
    func testPingResult(success: Bool, failMessage: String?, connectionRoute: ConnectionProtocol) {
        if !success {
            tryNextConnection()
        }
        else {
            _progress = 0.6
        }
        
        currentRouteInProgress = connectionRoute
        delegate.shouldUpdateUI()
    }
    
    func getHubDataModelComplete(success: Bool, failMessage: String?, connectionRoute: ConnectionProtocol) {
        currentRouteInProgress = connectionRoute
        
        if success {
            _progress = 1.0
            
            let isMN = HubDataModel.shared.isMN
            let typeString = isMN ? "and it is an MN" : "and it is an MEN"
            
            let logString = "Data model get succeded. Connected hub is \(connection?.hubName ?? "Unknown name") \(typeString)"
            Logger.log(tag: tag, message: logString)
            
            self.delegate.connectionAttemptsFinishedSuccessfully()
        }
        else {
            tryNextConnection()
        }
    }
}
