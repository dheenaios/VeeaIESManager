//
//  ConnectionQueueManager.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 21/08/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation


/// Takes an array of ConnectionProtocol objects and tries to connect to them
/// The first route will be tried upon init.
/// Call tryNextRoute to call the next
class ConnectionQueueManager {
    private let tag = "ConnectionQueueManager"
    
    private let connectionRoutes: [ConnectionProtocol]
    private var routeIndex = 0
    public private(set) var routeInProgress: ConnectionProtocol?
    
    /// Are there more routes to test after the current?
    public var hasMore: Bool {
        get {
            let next = routeIndex  + 1
            return next < connectionRoutes.count
        }
    }
    
    public func stop() {
        for route in connectionRoutes {
            route.stopConnectionAttempt()
        }
    }
    
    /// Init object and starts the first attempt
    ///
    /// - Parameter routes: The routes to be tries
    init(routes: [ConnectionProtocol]) {
        connectionRoutes = routes
        
        if connectionRoutes.isEmpty {
            Logger.log(tag: tag, message: "No connection routes supplied. Stopping")
            return
        }
        
        Logger.log(tag: tag, message: "Connection queue create with \(routes.count) routes")
        
        tryRoute()
    }

    /// Call to try the next route. Check hasMore before calling
    public func tryNextRoute() {
        routeInProgress?.stopConnectionAttempt()
        
        if !hasMore {
            return
        }
        
        routeIndex += 1
        tryRoute()
    }
    
    private func tryRoute() {
        let route = connectionRoutes[routeIndex]
        routeInProgress = route
        
        Logger.log(tag: tag, message: "Trying route \(routeIndex). \(route.connectionType.getDescription())")
        
        route.startConnectionAttempt()
    }
}
