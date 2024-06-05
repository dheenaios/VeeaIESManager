//
//  NodeTableCellModel.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 4/10/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import UIKit


final class NodeTableCellModel: VUITableCellModelProtocol {
    
    let id: String!
    var icon = Observable<String>("default-device-icon")
    var titleText: Observable<String>!
    var detailText: Observable<String>!
    var rightImage: UIImage?
    
    var isPreparing = false
    var isPreparingFailed = false
    
    var signalStrength = Observable<VHNodeSignalStrength>(.noSignal)
    var isAccessoryEnabled = Observable<Bool>(false)
    var isActivityEnabled = Observable<Bool>(false)
    private(set) var isEnabled = Observable<Bool>(false)
    
    var isAvailableOnLan = Observable<Bool>(false)
    var isAvailableOnMas = Observable<Bool>(false)
    
    var healthState = Observable<MeshNodeHealthState>(MeshNodeHealthState.unknown)
    
    var device: VHMeshNode
    
    var veeaHub: VeeaHubConnection
    
    init(device: VHMeshNode) {
        self.device = device
        self.id = device.id
        self.icon.data = "default-device-icon"
        self.titleText = Observable<String>("Loading...")
        self.detailText = Observable<String>("")
        
        veeaHub = VeeaHubConnection.init(veeaHubId: device.id, veeaHubName: device.name)
        veeaHub.delegate = self
        
        self.update(with: device)
    }
    
    func updateState() {
        setEnabledState()
    }
    
    func update(with device: VHMeshNode) {
        self.device = device
        
        // Constructing detail text
        var detail = healthState.data.stateTitle
        if device.status == .error {
            self.isPreparing = false
            self.isPreparingFailed = true
            
            if let error = device.error?.message {
                detail = error
            }
        }
        else if device.status != .ready {
            self.isPreparing = true
            self.isPreparingFailed = false
            if detail == MeshNodeHealthState.healthy.stateTitle || detail == MeshNodeHealthState.offline.stateTitle {
                self.isPreparing = false
                self.isPreparingFailed = false
            }
        }
        else {
            self.isPreparing = false
            self.isPreparingFailed = false
            if detail == MeshNodeHealthState.updating.stateTitle {
                self.isPreparing = true
            }
        }
        
        self.detailText.data = detail
        
        if isPreparing {
            self.isActivityEnabled.data = true
            self.isAccessoryEnabled.data = true

            self.isAvailableOnLan.data = false
            self.isAvailableOnMas.data = false
        } else if isPreparingFailed {
            self.isActivityEnabled.data = false
            self.isAccessoryEnabled.data = true
            self.isAvailableOnLan.data = false
            self.isAvailableOnMas.data = false
        } else {
            setDetailsForAvailableHub()
        }
       
        if healthState.data == .offline {
            self.icon.data = "unavailable-device-icon"
       }else if  healthState.data == .unknown {
             self.icon.data = "unavailable-device-icon"
        }else {
            self.icon.data = "default-device-icon"
        }

        setEnabledState()
    }
    
    private func setDetailsForAvailableHub() {
        self.isActivityEnabled.data = false
        self.isAvailableOnLan.data = veeaHub.hasIpOnLan
        

        if isAvailableOnLan.data || isAvailableOnMas.data || self.signalStrength.data != .noSignal {
            self.isAccessoryEnabled.data = true
        }
    }
    
    private func setEnabledState() {
        // TODO: THIS NEEDS CHANGING TO MAKE USE OF THE ConnectionInfo class. Logic in the Mesh Detail View is the same
        
        // Is it preparing
        if isPreparing && isPreparingFailed {
            isEnabled.data = false
            return
        }
        
        // Check if a connection is available and enable if it is. If this is the QA build then
        // Check the route has been enabled. See VHM 1358
        if Target.currentTarget == .QA {
            isEnabled.data = enableDisableForTesterPermittedRoutes()
            return
        }
        
        if veeaHub.hasDefinedConnectionRoute {
            isEnabled.data = true
            return
        }
        
        if isAvailableOnMas.data {
            isEnabled.data = true
            return
        }
        
        isEnabled.data = false
    }
    
    private func enableDisableForTesterPermittedRoutes() -> Bool {
        // What are the permitted connection routes
        let allowedRoutes = TesterDefinedConnectionRoutes.selectedRoutes
        
        if isAvailableOnMas.data && allowedRoutes.contains(.hubAvailableOnMas){
            return true
        }
        if veeaHub.signalStrength != .NO_SIGNAL && allowedRoutes.contains(.ap) {
            return true
        }
        
        if veeaHub.hasIpOnLan && allowedRoutes.contains(.lan){
            return true
        }
        
        return false
    }
    
    public func updateVeeaHubDetails(updatedHub: VeeaHubConnection) {
        
        // Make sure we are getting updated with the correct record
        if updatedHub.ssid == getSSID() {
            updateDetails(updatedHub: updatedHub)
            
            return
        }
        
        if updatedHub.hubId == id {
            updateDetails(updatedHub: updatedHub)
            
            return
        }
        
        fatalError("This hub should not be here.")
    }
    
    private func updateDetails(updatedHub: VeeaHubConnection) {
        // The initial veea hub will be created before a beacon is available
        // dns and mdns will be added
        // When the beacon comes into range the hub will be updated, but will have
        // no dns or mdns info attached
        // this will only be updated upon the next dns and mdns update
        // So to save momentary loss of ip info, just pass it to the new hub if it has none
        if updatedHub.hubDnsIp == nil {
            updatedHub.hubDnsIp = veeaHub.hubDnsIp
        }
        if updatedHub.hubId == nil {
            updatedHub.hubId = veeaHub.hubId
        }
        if updatedHub.hubName == nil {
            updatedHub.hubName = veeaHub.hubName
        }
        
        veeaHub = updatedHub
        isAvailableOnLan.data = veeaHub.hasIpOnLan
        
        updateSignal(signal: veeaHub.signalStrength)
    }
    
    public func signalBeaconLost() {
        veeaHub.removeBeacon()
        updateSignal(signal: .NO_SIGNAL)
    }
    
    private func updateSignal(signal: VeeaHubConnection.SignalStrength?) {
        if isPreparing {
            // Don't update signal if we are preparing the node
            return
        }
        
        if let signal = signal {
            if let s_ = VHNodeSignalStrength.init(rawValue: signal.rawValue) {
                self.signalStrength.data = s_
            }
        } else {
            self.signalStrength.data = .noSignal
        }
        
        self.isActivityEnabled.data = false
        // Disable accessory view when there is no signal
        if self.signalStrength.data == .noSignal {
            self.isAccessoryEnabled.data = false
        } else {
            self.isAccessoryEnabled.data = true
        }
        
        setEnabledState()
    }
    
    public func getSSID() -> String {
        let first4 = id.split(from: 0, to: 3)
        let last8 = id.split(from: id.count-8, to: id.count-1)
        return first4 + last8
    }
}

extension NodeTableCellModel: VeeaHubChangeObserver {
    func lanIpDetailsChanged(sender: VeeaHubConnection) {
        isAvailableOnLan.data = sender.hasIpOnLan
    }
}
