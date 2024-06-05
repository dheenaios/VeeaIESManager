//
//  DashboardItemState.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 09/12/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import UIKit

public enum WarningIconState {
    case NONE
    case AMBER
    case RED
    
    
    func colorForIconState() -> UIColor? {
        switch self {
        case .NONE:
            return nil
        case .AMBER:
            return UIColor.orange
        case .RED:
            return UIColor.red
        }
    }
}

// TODO: Move the more complex logic from the Dashboard View controller to here
public class DashboardItemState {
    static var portState: WarningIconState {
        get {
            if let iconState = getPortIconState() {
                return iconState
            }
            
            return .NONE
        }
    }
}

// MARK: - Ports
extension DashboardItemState {
    private static func getPortIconState() -> WarningIconState? {
        if isErrorReasonPresent() {
            return .RED
        }
        
        if arePortsLockedAndInUse() {
            return .AMBER
        }
        
        return nil
    }
    
    private static func arePortsLockedAndInUse() -> Bool {
        guard let nodeConfig = HubDataModel.shared.optionalAppDetails?.nodePortConfig,
            let meshConfig = HubDataModel.shared.optionalAppDetails?.meshPortConfig else {
                return false
        }
        
        for (index, nConfig) in nodeConfig.ports.enumerated() {
            let mConfig = meshConfig.ports[index]
            
            if nConfig.locked && nConfig.use {
                return true
            }
            else if mConfig.locked && mConfig.use {
                 return true
            }
        }
        
        return false
    }
    
    private static func isErrorReasonPresent() -> Bool {
        guard let status = HubDataModel.shared.optionalAppDetails?.nodePortStatusConfig else {
            return false
        }
        
        for port in status.ports {
            if !port.reason.isEmpty {
                return true
            }
        }
        
        return false
    }
}
