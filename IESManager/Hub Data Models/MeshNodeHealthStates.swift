//
//  MeshNodeHealthState.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 23/08/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

public enum MeshNodeHealthState {
    
    // In order of severity
    case healthy
    case busy
    case errors
    case updating
    case needsReboot
    case offline
    case unknown
    
    var stateTitle: String {
        switch self {
        case .healthy:
            return "Healthy".localized()
        case .busy:
            return "Busy".localized()
        case .errors:
            return "Errored".localized()
        case .offline:
            return "Offline".localized()
        case .updating:
            return "Updating".localized()
        case .needsReboot:
            return "Reboot Required".localized()
        case .unknown:
            return "Unknown"
        }
    }
        
    /// Description if the enum is for a mesh. Use nodeDescription if enum of for a node
    var meshDescription: String {
        switch self {
        case .healthy:
            return "This mesh is working properly".localized()
        case .busy:
            return "Some VeeaHubs on this mesh are busy".localized()
        case .errors:
            return "One or more VeeaHubs are experiencing errors or are currently offline within this mesh".localized()
        case .offline:
            return "Please ensure that your Gateway VeeaHub(MEN) is powered on and has an active internet connection".localized()
        case .updating:
            return "Some VeeaHubs on this mesh are updating".localized()
        case .needsReboot:
            return "Some VeeaHubs on this mesh need rebooting".localized()
        case .unknown:
            return "Unknown".localized()
        }
    }
    
    var color: UIColor {
        switch self {
        case .healthy:
            return .stateHealthy
        case .busy:
            return .stateBusy
        case .errors:
            return .stateErrors
        case .offline:
            return .stateOffLine
        case .updating:
            return .stateInstalling
        case .needsReboot:
            return .stateNeedsReboot
        case .unknown:
            return .stateUnknown
        }
    }
    
    /// Get the state of the mesh
    /// - Parameters:
    ///   - mesh: The mesh in question
    ///   - connectionStates: Connection states for the nodes in the mesh
    /// - Returns: The health state
    static func getMeshState(mesh: VHMesh,
                             hubInfo: [HubInfo]) -> MeshNodeHealthState {        
        var aliveCount = 0
        var problematicCount = 0
        var busyCount = 0
        var needsRebootCount = 0
        
        guard let devices = mesh.devices else {
            return .unknown
        }
        if devices.isEmpty { return .errors }
        
        for device in devices {
            if let connection = hubInfo.filter({ $0.UnitSerial == device.id}).first {
                if connection.Connected { aliveCount += 1 }
                if connection.NodeState.RebootRequired { needsRebootCount += 1 }
                if !connection.NodeState.Healthy { problematicCount += 1 }
                
                if device.status != .ready {
                    if device.status == .error { problematicCount += 1 }
                    else { busyCount += 1 }
                }
                if device.error != nil { problematicCount += 1 }
            }
            
            if device.status != .ready {
                if device.status == .error { problematicCount += 1 }
                else { busyCount += 1 }
            }
            if device.error != nil { problematicCount += 1 }
        }

        if busyCount > 0 { return .busy }
        if problematicCount > 0 { return .errors }
        if aliveCount == 0 { return .offline }
        if needsRebootCount > 0 { return .needsReboot }
        
        return healthy
    }
    static func getNodeState(device: VHMeshNode,
                             hubInfo: HubInfo?) -> MeshNodeHealthState {
        var state = MeshNodeHealthState.healthy
        let status = device.status
        
        if status != .ready {
            state = .updating
        }
        
        if status == .error {
            state = .errors
        }
        
        if status == .bootstrapping || (device.status == .ready && hubInfo == nil) {
            state = .updating
            return state
        }
        
        if let hubInfo = hubInfo {
            if !hubInfo.Connected {
                state = .offline
                return state
            }
            
            if hubInfo.NodeState.RebootRequired {
                state = .needsReboot
                return state
            }
            else if !hubInfo.NodeState.Healthy {
                state = errors
                return state
            }
        }
        
        return state
    }

  
    static func getStateFromStatus(status:String) -> MeshNodeHealthState {
        switch status.lowercased() {
        case "healthy":
            return .healthy
        case "busy":
            return .busy
        case "errored":
            return .errors
        case "offline":
            return .offline
        case "updating":
            return .updating
        case "needsReboot":
            return .needsReboot
        case "unknown":
            return .unknown
        default:
            return .unknown
        }
    }
   
}

