//
//  TesterDefinedConnectionRoutes.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/10/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking


/// A class that should only be used in internal builds.
/// Provides and stores information about which connection routes should be used
/// The purpose is to allow testers to test specific routes.
class TesterDefinedConnectionRoutes {
    
    private static let key = "TesterDefinedConnectionRoutes"
    
    enum ConnectionRoute: Int {
        case hubAvailableOnMas = 0
        case lan = 1
        case ap = 2
        
        static func routeFromRaw(int: Int) -> ConnectionRoute? {
            switch int {
            case 0:
                return .hubAvailableOnMas
            case 1:
                return .lan
            case 2:
                return .ap
            default:
                return nil
            }
        }
    }
    
    static var selectedRoutes: Set<ConnectionRoute> {
        get {
            let defaultRules: Set = [ConnectionRoute.hubAvailableOnMas,
                                  ConnectionRoute.lan,
                                  ConnectionRoute.ap]
            
            if BackEndEnvironment.internalBuild {
                if let routes = UserDefaults.standard.array(forKey: key) as? [Int] {
                    var s = Set<ConnectionRoute>()
                    
                    for r in routes {
                        if let route = ConnectionRoute.routeFromRaw(int: r) {
                            s.insert(route)
                        }
                    }
                    
                    return s
                }
            }
            
            return defaultRules
        }
        set {
            var i = [Int]()
            for route in newValue {
                i.append(route.rawValue)
            }
            
            UserDefaults.standard.setValue(i, forKey: key)
        }
    }
    
    static func resetRoutes() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
