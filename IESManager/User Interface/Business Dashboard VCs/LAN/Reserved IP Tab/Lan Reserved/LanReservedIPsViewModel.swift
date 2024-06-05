//
//  StaticIPsViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

class LanReservedIPsViewModel: BaseConfigViewModel {

    var parentVm: LanConfigurationViewModel

    lazy var staticIpDetails: NodeLanStaticIpConfig = {
        return parentVm.staticIpDetails
    }()

    init(parentViewModel: LanConfigurationViewModel) {
        self.parentVm = parentViewModel
    }
}

// MARK: - Validation
extension LanReservedIPsViewModel {

    func tableViewDisabled(lan: Int) -> Bool {
        if !parentVm.supportsBackpack { return false }

        guard parentVm.getIpManagementMode(for: lan) != nil else { return false }
        return !viewEnabled(selectedLan: lan)
    }
    
    // MARK: - Validation
    static func validateAgainstDHCPSettings(hostIpAddress: String, lanNumber: Int) -> String {
        var warning = ""
        
        if hostIpAddress.isEmpty { return "" }
        if !AddressAndPortValidation.isIPValid(string: hostIpAddress) {
            return "Invalid IP address".localized()
        }
        if !IPConflictionHelper.areDhcpIpSettingsForLan(lanIndex: lanNumber) {
            return ""
        }
        
        if !hostIPIsValid(hostIpAddress: hostIpAddress, lanNumber: lanNumber) {
            if let config = HubDataModel.shared.optionalAppDetails?.nodeLanConfig {
                let lan = config.lans[lanNumber]
                var starting = lan.start_ip
                var ending = lan.end_ip
                
                if starting.isEmpty || ending.isEmpty {
                    let defaultLan = DefaultLanHelper()
                    let lanDetails = defaultLan.getDefultRangeDetails(selectedLanNumber: lanNumber)
                    
                    starting = lanDetails.0
                    ending = lanDetails.1
                    
                    if starting.isEmpty || ending.isEmpty {
                        return "Host IP address is outside the DHCP Range".localized()
                    }
                }
                
                warning = "\("Host IP address should be between".localized()) \(starting) \("and".localized()) \(ending)"
            }
        }
        
        return warning
    }
    
    static func hostIPIsValid(hostIpAddress: String, lanNumber: Int) -> Bool {
        guard let config = HubDataModel.shared.optionalAppDetails?.nodeLanConfig else {
            return false
        }
        
        let lan = config.lans[lanNumber]
        var starting = lan.start_ip
        var ending = lan.end_ip
        
        if starting.isEmpty || ending.isEmpty {
            let defaultLan = DefaultLanHelper()
            let lanDetails = defaultLan.getDefultRangeDetails(selectedLanNumber: lanNumber)
            
            starting = lanDetails.0
            ending = lanDetails.1
            
            if starting.isEmpty || ending.isEmpty {
                return true
            }
        }
        
        return IPAddressCalculations.isIP(ip: hostIpAddress, between: starting, and: ending)
    }

    func viewEnabled(selectedLan: Int) -> Bool {
        if !parentVm.supportsBackpack { return true }
        let wanMode = parentVm.getWanMode(for: selectedLan)
        guard let ipManMode = parentVm.getIpManagementMode(for: selectedLan) else {
            return true // Return true, as over devices might not have these.
        }

        let controller = LanTabEnabledController(wanMode: wanMode,
                                                 ipManagementMode: ipManMode)

        return controller.reservedIpsEnabled
    }
}
