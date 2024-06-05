//
//  MeshHubState+Color.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 23/08/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

// MARK: - Mesh and hub state colors
extension UIColor {
    static var stateHealthy: UIColor {
        return UIColor(named: "stateHealthy")!
    }
    
    static var stateBusy: UIColor {
        return UIColor(named: "stateBusy")!
    }
    
    static var stateInstalling: UIColor {
        return UIColor(named: "stateInstalling")!
    }
    
    static var stateErrors: UIColor {
        return UIColor(named: "StateErroredYellow")!
    }
    
    static var stateOffLine: UIColor {
        return UIColor(named: "stateOffline")!
    }
    
    static var stateUnknown: UIColor {
        return UIColor(named: "stateErrors")!
    }
    
    static var stateNeedsReboot: UIColor {
        return UIColor(named: "stateNeedReboot")!
    }
}
