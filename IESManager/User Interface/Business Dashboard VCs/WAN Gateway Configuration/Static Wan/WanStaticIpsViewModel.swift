//
//  WanStaticIpsViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 16/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class WanStaticIpsViewModel {
    
    // TODO: THis method can be removed when the MVVM changes are added. Make this class a baseViewModel sub class
    var connectedHub: HubConnectionDefinition? {
        return HubDataModel.shared.connectedVeeaHub
    }
    
    let lans: [Int]?
    
    var updatedConfig: NodeWanStaticIpConfig? {
        guard let m = models, var c = HubDataModel.shared.optionalAppDetails?.nodeWanStaticIpConfig else {
            return nil
        }
        
        c.wanStaticIpConfig = m
        
        return c
    }
    
    var models: [LanWanStaticIpConfig]?
    
    var editableModels: [LanWanStaticIpConfig] {
        var m = [LanWanStaticIpConfig]()
        
        if let models = models {
            for model in models {
                // VHM: 642
                m.append(model)
            }
        }
        
        return m
    }
    
    /// Why is the functionality not available. If it is, nil returned
    var reasonNotToShow: String? {
        let isMN = HubDataModel.shared.isMN
        
        if isMN {
            return "An MEN must be used to edit these details".localized()
        }
        
        if lans == nil {
            return "This hub does not support this capability. Please update you hubs software.".localized()
        }
        
        return nil
    }
    
    func apply() {
        
    }
    
    init() {
        lans = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.wanStaticIps
        let config = HubDataModel.shared.optionalAppDetails?.nodeWanStaticIpConfig
        
        guard let l = lans, var m = config?.wanStaticIpConfig else {
            models = [LanWanStaticIpConfig]()
            return
        }
        
        for (index, _) in m.enumerated() {
            let lan = index + 1
            
            if l.contains(lan) {
                m[index].availableForEditing = true
                m[index].portNumber = lan
            }
        }
        
        models = m
    }
}

// MARK: - Validation
extension WanStaticIpsViewModel {
    
    var needsUpdate: Bool {
        guard let oldConfig = HubDataModel.shared.optionalAppDetails?.nodeWanStaticIpConfig else {
            return false
        }
        
        if oldConfig.wanStaticIpConfig.count != updatedConfig?.wanStaticIpConfig.count {
            return false
        }
        
        for (index, oM) in oldConfig.wanStaticIpConfig.enumerated() {
            let nM = updatedConfig?.wanStaticIpConfig[index]
            
            if nM != oM {
                return true
            }
        }
        
        return false
    }
    
    var validationErrorMessage: String? {
        var errorText = ""
        
        for model in editableModels {
            var modelError = ""
            
            if model.use {
                modelError.append(cdirInvalidReason(cdir: model.ip4_address))
                
                if !ipInvalid(ip: model.ip4_gateway).isEmpty {
                    modelError.append("\("Gateway IP".localized()): \(ipInvalid(ip: model.ip4_gateway))\n")
                }
                
                if model.ip4_dns_1.isEmpty && model.ip4_dns_2.isEmpty {
                    modelError.append("Enter at least 1 DNS IP".localized())
                }
                else {
                    if !model.ip4_dns_1.isEmpty && !ipInvalid(ip: model.ip4_dns_1).isEmpty {
                        modelError.append("\("DNS 1".localized()): \(ipInvalid(ip: model.ip4_dns_1))\n")
                    }
                    if !model.ip4_dns_2.isEmpty && !ipInvalid(ip: model.ip4_dns_2).isEmpty {
                        modelError.append("\("DNS 2".localized()): \(ipInvalid(ip: model.ip4_dns_2))\n")
                    }
                }
                
                modelError.append(cdirAndGateWayOnSameSubnetErrorReason(cdir: model.ip4_address,
                                                                       gwIp: model.ip4_gateway))
                
                if !modelError.isEmpty {
                    if let lanNumber = model.portNumber {
                        errorText.append("\("WAN".localized()) \(lanNumber) \("errors".localized()):\n\(modelError)")
                    }
                }
            }
        }
        
        return errorText.isEmpty ? nil : errorText
    }
    
    private func cdirAndGateWayOnSameSubnetErrorReason(cdir: String, gwIp: String) -> String {
        
        let parts = cdir.split(separator: "/")
        if parts.count != 2 {
            return "CDIR address requires a mask".localized()
        }
        
        let cidrIp = String(parts.first!)
        let cidrMask = Int(parts.last!) ?? -1
        
        if cidrMask == -1 {
            return "CDIR mask is invalid".localized()
        }
        
        let valid = AddressAndSubnetValidation.areBothIpsOnSameSubnet(ipA: cidrIp, ipB: gwIp, mask: cidrMask)
        
        return valid ? "" : "CDIR and Gateway IP are not on the same subnet".localized()
    }
    
    private func cdirInvalidReason(cdir: String) -> String {
        if cdir.isEmpty {
            return "CDIR address is empty\n".localized()
        }
        
        if !AddressAndSubnetValidation.isAddressAndPrefixValid(addressSubnetString: cdir) {
            return "CDIR address is not valid\n".localized()
        }
        
        return ""
    }
    
    private func ipInvalid(ip: String) -> String {
        if ip.isEmpty {
            return "IP Address is empty\n".localized()
        }
        
        if !AddressAndPortValidation.isIPValid(string: ip) {
            return "IP Address is not valid\n".localized()
        }
        
        return ""
    }
}
