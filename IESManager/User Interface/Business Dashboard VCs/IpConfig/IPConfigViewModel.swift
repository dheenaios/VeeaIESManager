//
//  IPConfigViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class IPConfigViewModel: BaseConfigViewModel {
    
    var enabled: Bool {
        return !HubDataModel.shared.isMN
    }
    
    var showOnlyInternalPrefix: Bool {
        return HubDataModel.shared.isMN
    }
    
    private lazy var ipConfig: IpConfig? = {
        return HubDataModel.shared.baseDataModel?.ipConfig
    }()
    
    private var iesStatus: NodeStatus? = {
        HubDataModel.shared.baseDataModel?.nodeStatusConfig
    }()
    
    var ipAddr: String {
        get { return iesStatus?.ethernet_ipv4_addr ?? "?" }
        set {  }
    }
    
    var selectedGateway: String {
        get { return iesStatus?.border_gateway_selected ?? "?" }
        set {  }
    }
    
    var delegatePrefix: String {
        get { return ipConfig?.hncp_ext_delegated_prefix ?? "?" }
        set { ipConfig?.hncp_ext_delegated_prefix = newValue }
    }
    
    var meshAddr: String {
        get { return ipConfig?.hncp_men_mesh_address ?? "?" }
        set { ipConfig?.hncp_men_mesh_address = newValue }
    }
    
    
    var intPrefix: String {
        get { return ipConfig?.hncp_lmt_delegated_prefix ?? "?" }
        set { ipConfig?.hncp_lmt_delegated_prefix = newValue }
    }
    
    func update(completion: @escaping CompletionDelegate) {
        guard let c = ipConfig else {
            completion(nil, APIError.Failed(message: "No config"))
            return
        }
        
        ApiFactory.api.setConfig(connection: connectedHub!, config: c) { (result, error) in
            completion(result, error)
        }
    }
    
    func hasConfigChanged() -> Bool {
        guard let originalConfig = HubDataModel.shared.baseDataModel?.ipConfig else {
            return false
        }
        
        return ipConfig != originalConfig
    }
}

// MARK: - Validation
extension IPConfigViewModel {
    func dnsValid(value: String?) -> Bool {
        guard let value = value else {
            return true
        }
        
        if value.isEmpty {
            return true
        }
        
        return AddressAndPortValidation.isIPValid(string: value)
    }
}
