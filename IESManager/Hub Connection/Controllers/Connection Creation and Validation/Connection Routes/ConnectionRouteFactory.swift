//
//  ConnectionRouteFactory.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 14/10/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking


/// Generates the routes available to the VHM for connection
class ConnectionRouteFactory {
    
    private var hub: VeeaHubConnection?
    private var delegate: ConnectionProgressProtocol?
    
    /// Returns connection routes for the given device, its state, and the users settings
    /// - Returns: Connection routes. Might be empty
    func connectionRoutes(hub: VeeaHubConnection,
                          progressDelegate: ConnectionProgressProtocol) -> [ConnectionProtocol] {
        self.hub = hub
        self.delegate = progressDelegate
        var connections = [ConnectionProtocol]()
        
        //MAS CONNECTION ROUTES. Add to the AND start of the array. One for online, the other for offline
        if let c = getMasOnConnectionRoute(hubMustBeAvailable: true) {
            if routeIsPermitted(route: .hubAvailableOnMas) { connections.append(c) }
        }
        
        // LOCAL ROUTES
        if let routes = getLocalConnectionRoutes() {
            connections.append(contentsOf: routes)
        }
        
        // Hub off line mas route
        // This is currently not used. It will not be added except if a tester adds it in the tester menu
        if let c = allowAccessToMasWhenHubIsOffLine {
            connections.append(c)
        }

        return connections
    }


    private var allowAccessToMasWhenHubIsOffLine: ConnectionProtocol? {
        if !BackEndEnvironment.internalBuild { return nil } // No if prod
        if !TesterMenuDataModel.VeeaBackEndOptions.connectViaMasIfHubNotConnected { return nil } // Only if tester has turned on option
        if !routeIsPermitted(route: .hubAvailableOnMas) { return nil } // Do the tester defined route contain this route

        return getMasOnConnectionRoute(hubMustBeAvailable: false)
    }

    /// Is the route permitted by tester / build type
    private func routeIsPermitted(route: TesterDefinedConnectionRoutes.ConnectionRoute) -> Bool {
        if !BackEndEnvironment.internalBuild { return true }
        let testerSelectedRoutes = TesterDefinedConnectionRoutes.selectedRoutes

        return testerSelectedRoutes.contains(route)
    }
    
    private func getMasOnConnectionRoute(hubMustBeAvailable: Bool) -> ConnectionProtocol? {
        let testerSelectedRoutes = TesterDefinedConnectionRoutes.selectedRoutes
        
        // Check that the tester has allowed this route
        if (hubMustBeAvailable && !testerSelectedRoutes.contains(.hubAvailableOnMas)) {
            return nil
        }
        
        guard let hub = hub, let delegate = delegate else {
            return nil
        }
        
        guard let r = MasConnectionController.init(hub: hub,
                                                   connectionType: .MAS_API,
                                                   progressDelegate: delegate) else {
            return nil
        }
        
        r.doAvailablityCheck = hubMustBeAvailable
        
        return r
    }
    
    private func getLocalConnectionRoutes() -> [ConnectionProtocol]? {
        guard let hub = hub, let delegate = delegate else {
            return nil
        }
        
        if !hub.hasDefinedConnectionRoute {
            return nil
        }
        
        var connections = [ConnectionProtocol]()
        let testerSelectedRoutes = TesterDefinedConnectionRoutes.selectedRoutes
        
        // LOCAL AREA CONNECTIONS
        if hub.hasIpOnLan && testerSelectedRoutes.contains(.lan) {
            let dnsAddress = hub.hubDnsIp ?? ""
            
            if !dnsAddress.isEmpty {
                if let controller = HubLanConnectionController.init(hub: hub,
                                                                    connectionType: .DNS,
                                                                    progressDelegate: delegate) {
                    connections.append(controller)
                }
                
            }
            else {
                if !dnsAddress.isEmpty {
                    if let controller = HubLanConnectionController.init(hub: hub,
                                                                        connectionType: .DNS,
                                                                        progressDelegate: delegate) {
                        connections.append(controller)
                    }
                    
                }
            }
        }
        
        // AP CONNECTIONS
        if hub.hasApInRange && testerSelectedRoutes.contains(.ap) {
            if let controller = HubApConnectionController(hub: hub,
                                                          connectionType: .CURRENT_GATEWAY,
                                                          progressDelegate: delegate) {
                connections.append(controller)
            }
        }
        
        return connections
    }
}
