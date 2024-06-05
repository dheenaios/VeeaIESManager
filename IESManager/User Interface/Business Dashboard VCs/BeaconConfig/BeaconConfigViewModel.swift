//
//  BeaconConfigViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class BeaconConfigViewModel: BaseConfigViewModel {
    private var beaconConfig: BeaconConfig!  = {
        return HubDataModel.shared.baseDataModel?.beaconConfig
    }()
    
    private var nodeConfig: NodeConfig!  = {
        return HubDataModel.shared.baseDataModel?.nodeConfig
    }()
    
    private var nodeInfo: NodeInfo!  = {
        return HubDataModel.shared.baseDataModel?.nodeInfoConfig
    }()
    
    var locked: Bool {
        get { return beaconConfig.beacon_locked }
        set { beaconConfig.beacon_locked = newValue }
    }
    
    var subDomain: String {
        get { return beaconConfig.beacon_sub_domain }
        set { beaconConfig.beacon_sub_domain = newValue }
    }

    var instanceId: String {
        get { return beaconConfig.beacon_instance_id }
        set { beaconConfig.beacon_instance_id = newValue }
    }
    
    var btMacAddress: String {
        get { return nodeInfo.bluetooth_address }
    }
    
    var beaconDecryptKey: String {
        get { return nodeConfig.beaconDecryptKey ?? "" }
        set { nodeConfig.beaconDecryptKey = newValue }
    }
    
    func applyBeaconKeyUpdate() {
        guard let h = connectedHub else {
            return
        }
        
        ApiFactory.api.setConfig(connection: h, config: nodeConfig) { (result, error) in
            NSLog("got result: \(String(describing: result)), error: \(String(describing: error))") // TODO
        }
    }
    
    func applyUpdate(completion: @escaping CompletionDelegate) {
        guard let h = connectedHub else {
            return
        }
        
        ApiFactory.api.setConfig(connection: h, config: beaconConfig) { (result, error) in
            NSLog("got result: \(String(describing: result)), error: \(String(describing: error))") // TODO
            
            
            if error != nil {
                completion(nil, error)
                
                return
            }
            
            completion(nil, nil)
        }
    }
}
