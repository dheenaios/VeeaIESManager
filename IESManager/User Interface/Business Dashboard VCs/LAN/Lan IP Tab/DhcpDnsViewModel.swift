//
//  DhcpDnsViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class DhcpDnsViewModel: BaseConfigViewModel {

    let parentVm: LanConfigurationViewModel

    private(set) var selectedIpManagementMode: IpManagementMode = .CLIENT

    public var numberOfLans: Int {
        return parentVm.nodeLanConfig.lans.count
    }
    
    public var meshLans: [MeshLan] {
        return parentVm.meshLanConfig.lans
    }
    
    var nodeLanConfigModels: [NodeLanConfigModel] {
        return parentVm.nodeLanConfig.lans
    }

    func viewEnabled(selectedLan: Int) -> Bool {
        if !parentVm.supportsBackpack { return true }
        let wanMode = parentVm.getWanMode(for: selectedLan)
        guard let ipManMode = parentVm.getIpManagementMode(for: selectedLan) else {
            return true // Return true, as over devices might not have these.
        }

        let controller = LanTabEnabledController(wanMode: wanMode,
                                                 ipManagementMode: ipManMode)

        return controller.lanIpEnabled
    }

    
    func applyUpdate(completion: @escaping CompletionDelegate) {
        guard let h = connectedHub else {
            let message = "Not connected to a VeeaHub"
            completion(message, APIError.Failed(message: message))
            return
        }

        Task {
            let result1 = await ApiFactory.api.setConfig(connection: h, config: parentVm.nodeLanConfig)
            if result1.1 != nil {
                handleResponse(result: result1, completion: completion)
                return
            }
            let result2 = await ApiFactory.api.setConfig(connection: h, config: parentVm.meshLanConfig)
            if result2.1 != nil {
                handleResponse(result: result2, completion: completion)
                return
            }

            completion(nil, nil)
        }
    }

    private func handleResponse(result: (String?, APIError?),
                                completion: @escaping CompletionDelegate) {
        DispatchQueue.main.async {
            completion(result.0, result.1)
        }
    }

    init(parentViewModel: LanConfigurationViewModel) {
        self.parentVm = parentViewModel
    }
}

// MARK: - Validation
extension DhcpDnsViewModel {
    func entriesHaveErrors(selectedMeshLan: MeshLan) -> String? {
        var errorMessage = ""

        for (index, lan) in nodeLanConfigModels.enumerated() {
            let lanNumber = index + 1

            if !AddressAndPortValidation.isIPValid(string: lan.dns_1) && !lan.dns_1.isEmpty {
                errorMessage.append("LAN\(lanNumber) \("dns1 is not a valid IP address".localized())\n")
            }
            if !AddressAndPortValidation.isIPValid(string: lan.dns_2) && !lan.dns_2.isEmpty {
                errorMessage.append("LAN\(lanNumber) \("dns2 is not a valid IP address".localized())\n")
            }
            if !AddressAndPortValidation.isIPValid(string: lan.start_ip) && !lan.start_ip.isEmpty {
                errorMessage.append("LAN\(lanNumber) \("starting IP is not a valid IP address".localized())\n")
            }
            if !AddressAndPortValidation.isIPValid(string: lan.end_ip) && !lan.end_ip.isEmpty{
                errorMessage.append("LAN\(lanNumber) \("end IP is not a valid IP address".localized())\n")
            }
            if lan.start_ip.isEmpty && !lan.end_ip.isEmpty {
                errorMessage.append("LAN\(lanNumber) \("needs a starting IP address".localized())\n")
            }
            if lan.end_ip.isEmpty && !lan.start_ip.isEmpty {
                errorMessage.append("LAN\(lanNumber) \("needs a ending IP address".localized())\n")
            }

            if !lan.start_ip.isEmpty && !lan.end_ip.isEmpty {
                let startInt = IPAddressCalculations.ipToInt(addrString: lan.start_ip)
                let endInt = IPAddressCalculations.ipToInt(addrString: lan.end_ip)

                if startInt == nil || endInt == nil {
                    errorMessage.append("LAN\(lanNumber) \("IPs are incorrectly formatted".localized())\n")
                }
                if startInt == endInt {
                    errorMessage.append("LAN\(lanNumber) \("Start and ending IPs are the same".localized())\n")
                }
                
                if startInt != nil && endInt != nil {
                    if startInt! > endInt! {
                        errorMessage.append("LAN\(lanNumber) \("Start IP > End IP".localized())\n")
                    }
                }              

                // Mask
                let subnet = selectedMeshLan.ip4_subnet
                let parts = subnet.split(separator: "/")
                if parts.count == 2 {
                    let mask = Int(parts.last!) ?? -1
                    if !AddressAndSubnetValidation.areBothIpsOnSameSubnet(ipA: lan.start_ip,
                                                                          ipB: lan.end_ip,
                                                                          mask: mask) {
                        errorMessage.append("LAN\(lanNumber) \("has IPs that are not within its subnet".localized())\n")
                    }
                }
            }
        }

        if errorMessage.isEmpty {
            return nil
        }

        return errorMessage
    }
}
