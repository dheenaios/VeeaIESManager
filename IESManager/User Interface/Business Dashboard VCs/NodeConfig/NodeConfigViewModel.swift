//
//  NodeConfigViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class NodeConfigViewModel: BaseConfigViewModel {
    
    // MARK: - Models
    private var updatedTime: String?
    
    private var nodeInfo = HubDataModel.shared.baseDataModel!.nodeInfoConfig!
    private var nodeConfig = HubDataModel.shared.baseDataModel!.nodeConfig!
    private var nodeStatus = HubDataModel.shared.baseDataModel!.nodeStatusConfig!
    private var locationConfig =  HubDataModel.shared.baseDataModel?.locationConfig
    
    // MARK: - Model Values
    
    var nodeName: String {
        get {
            return nodeConfig.node_name
        }
        set {
            nodeConfig.node_name = newValue
        }
    }
    
    var nodeSerial: String {
        return nodeInfo.unit_serial_number
    }
    
    var veeaHubUnitSerialNumber: String {
        return nodeInfo.unit_serial_number
    }
    
    var nodeType: String {
        get {
            return nodeConfig.node_type
        }
        set {
            nodeConfig.node_type = newValue
        }
    }
    
    var softwareVersion: String {
        return nodeInfo.sw_version
    }
    
    var osVersion: String {
        return nodeInfo.os_version
    }
    
    var hardwareVersion: String {
        return nodeInfo.unit_hardware_version
    }
    
    var hardwareRev: String {
        return nodeInfo.unit_hardware_revision
    }
    
    var locale: String {
        get {
            return nodeConfig.node_locale
        }
        set {
            nodeConfig.node_locale = newValue
        }
    }
    
    var restartTime: String {
        return nodeInfo.reboot_time
    }
    
    var rebootRequired: Bool {
        return nodeStatus.reboot_required
    }
    
    var lastRestartReason: String {
        return nodeInfo.reboot_reason
    }
    
    var restartRequiredReason: String {
        return nodeStatus.reboot_required == true ? self.nodeStatus.reboot_required_reason : "No restart needed".localized()
    }
    
    func hasConfigChanged() -> Bool {
        guard let originalConfig = HubDataModel.shared.baseDataModel?.nodeConfig else {
            return false
        }
        
        return nodeConfig != originalConfig
    }

    // MARK: - Update
    func update(completion: @escaping CompletionDelegate) {
        ApiFactory.api.setConfig(connection: connectedHub!, config: nodeConfig) { (result, error) in
            completion(result, error)
        }
    }
}

// MARK: - Time
extension NodeConfigViewModel {
    var nodeTime: String {
        guard let updatedTime = updatedTime else {
            return Utils.localTimeStringFromUTC(string: nodeInfo.node_time)
        }
        
        return updatedTime
    }
    
    func refreshTime(completion: @escaping CompletionDelegate) {
        guard let h = connectedHub else {
            let message = "Not connected to a VeeaHub".localized()
            completion(message, APIError.Failed(message: message))
            return
        }
                
        ApiFactory.api.refreshTime(connection: h) { (ok, error) in
            if let time = ok {
                
                self.updatedTime = Utils.localTimeStringFromUTC(string: time.node_time)
                completion(nil, nil)
                return
            }
            
            completion(nil, error)
        }
    }
}

// MARK: - Location
extension NodeConfigViewModel {
    var locationText: String {
        guard let config = locationConfig else {
            return "Unknown".localized()
        }
        
        let city = config.configuredLocation.city.replacingOccurrences(of: "_", with: " ")
        return "\(city), \(config.configuredLocation.countryCode)"
    }
}

