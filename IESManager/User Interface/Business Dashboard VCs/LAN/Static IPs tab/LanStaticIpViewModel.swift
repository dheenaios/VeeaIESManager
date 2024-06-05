//
//  LanStaticIpViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 27/04/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation

class LanStaticIpViewModel: BaseConfigViewModel {
    let parentVm: LanConfigurationViewModel
    var selectedLan: Int
    private(set) var config: NodeLanConfigStaticIp?
    private let isMn = HubDataModel.shared.isMN

    /// The currently selected config, based on the selected lan
    public var selectedConfig: LanWanStaticIpConfig? {
        get {
            return config?.lanStaticIpConfig[selectedLan]
        }
        set {
            if let newValue {
                var n = newValue
                n.use = lanStaticIPInUse
                config?.update(lan: n,
                               lanIndex: selectedLan)
                if let config {
                    parentVm.nodeLanConfigStaticIpDetails = config
                }
            }
        }
    }

    func applyUpdate(completion: @escaping CompletionDelegate) {
        guard let h = connectedHub else {
            let message = "Not connected to a VeeaHub"
            completion(message, APIError.Failed(message: message))
            return
        }

        guard let config = parentVm.nodeLanConfigStaticIpDetails else {
            let message = "Configuration object error"
            completion(message, APIError.Failed(message: message))
            return
        }

        ApiFactory.api.setConfig(connection: h,
                                 config: config) { (result, error) in
            completion(nil, error)
        }
    }

    func entriesHaveErrors() -> String? {
        guard let config else {
            return "No Static IP information available for this hub"
        }
        

        var errorMessage = ""
        for (index, config) in config.lanStaticIpConfig.enumerated() {
            if let error = validateLanConfiguration(config: config,
                                                    lanIndex: index) {
                errorMessage.append(error)
            }
        }

        if !errorMessage.isEmpty { return errorMessage }

        return nil
    }
    
    func checkingForStaticIP() -> Bool {
        if wanModeForSelectedLan == .ISOLATED {
            if ipManagmentModeForSelectedLan == .SERVER { return false }
            if ipManagmentModeForSelectedLan == .CLIENT { return false }
            if ipManagmentModeForSelectedLan == .STATIC {
                return true
            }
        }
        else if wanModeForSelectedLan == .ROUTED {
            if ipManagmentModeForSelectedLan == .SERVER { return false }
            if ipManagmentModeForSelectedLan == .STATIC { return true }
        }
        else if wanModeForSelectedLan == .BRIDGED {
            if ipManagmentModeForSelectedLan == .CLIENT { return false }
            if ipManagmentModeForSelectedLan == .STATIC { return true }
        }
        return false
    }

    private func validateLanConfiguration(config: LanWanStaticIpConfig, lanIndex: Int) -> String? {
        let lanText = "LAN " + "\(lanIndex + 1): "

        let ipv4 = config.ip4_address
        let gateway = config.ip4_gateway
        let dns1 = config.ip4_dns_1
        let dns2 = config.ip4_dns_2

        if config.use { // All must be filled
            if ipv4.isEmpty {
//                let ipV4FromLanStatusIpSubnet = staticIpShouldReflectLanStatusIpSubnet && !lanStatusSubnet.isEmpty
//                if !ipV4FromLanStatusIpSubnet {
                    return lanText + "is active. The static IP should have a value\n"
            //    }
            }
        }

        // Is an MEN, then Static IP needs a value
        // Gateway and DNS servers are optional (see MAS-1534)
        if !ipv4.isEmpty && !isMn {
            if let message = AddressAndPortValidation.simpleIpSubnetError(string: ipv4) {
                return lanText + "\(message)\n"
            }
        }
        if !gateway.isEmpty && !AddressAndPortValidation.isIPValid(string: gateway) {
            return lanText + "gateway address is not valid\n"
        }
        if !dns1.isEmpty && !AddressAndPortValidation.isIPValid(string: dns1) {
            return lanText + "dns1 address is not valid\n"
        }
        if !dns2.isEmpty && !AddressAndPortValidation.isIPValid(string: dns2) {
            return lanText + "dns2 address is not valid\n"
        }
        
        if checkingForStaticIP() && lanStaticIPInUse {
            if ipv4.isEmpty {
                if lanIndex == selectedLan {
                    return lanText + "is active. The static IP should have a value\n"
                }
            }
        }
        return nil
    }

    public var isChanged: Bool {
        parentVm.nodeLanConfigStaticIpDetailsChanges
    }

    init(parentViewModel: LanConfigurationViewModel, selectedLan: Int) {
        self.parentVm = parentViewModel
        self.config = parentViewModel.nodeLanConfigStaticIpDetails
        self.selectedLan = selectedLan
    }
}

// Settings conditional on other settings
extension LanStaticIpViewModel {
    // From MAS 1534: The IP Subnet on the lan page should reflect the subnet from the CIDR
    // formatted IP address on the LAN Static IP page when isolated is selected
    var staticIpShouldReflectLanStatusIpSubnet: Bool {
        guard let ip = selectedConfig?.ip4_address else { return false }
        return wanModeForSelectedLan == .ISOLATED && ip.isEmpty
    }

    var staticIpFieldShouldBeEditable: Bool {
//        if viewEnabled {
//            return HubDataModel.shared.isMN//!staticIpShouldReflectLanStatusIpSubnet || HubDataModel.shared.isMN
//        }
//        return false
         return viewEnabled
    }

    private var viewEnabled: Bool {
        if !parentVm.supportsBackpack { return true }
        let selected = parentVm.meshLanConfig.lans[selectedLan]
        guard var ipManMode = selected.ipManagementMode else {
            return true // Return true, as over devices might not have these.
        }
        
        // Check the iPManMode is valid. If not, set to the default
        //
        
        if !parentVm.isIpModeValidForWanMode(ipMode: ipManMode, for: selectedLan) {
            ipManMode = parentVm.defaultIpManagementMode(lan: selectedLan)
        }
        
        
        let controller = LanTabEnabledController(wanMode: selected.wanMode,
                                                 ipManagementMode: ipManMode)

        return controller.staticIpsEnabled(lan: config?.lanStaticIpConfig[selectedLan])
    }

    var lanStatusSubnet: String {
        let config = parentVm.meshLanConfig.lans[selectedLan]
        return config.ip4_subnet
    }

    private var wanModeForSelectedLan: WanMode {
        let config = parentVm.meshLanConfig.lans[selectedLan]
        return config.wanMode
    }

    // From MAS 1534: Do not show Use on Static IP tab. When static mode is set set set static ip use to true
    private var ipManagmentModeForSelectedLan: IpManagementMode? {
        let config = parentVm.meshLanConfig.lans[selectedLan]
        return config.ipManagementMode
    }

    var lanStaticIPInUse: Bool {
        /*
         MAS-1534
         On loading the Node Manager, the...
         **Static IP Use field should be set to true if LAN Use is set and the IP Mode is Static.**
         For an MN, the Static IP fields are not mesh-wide so each VeeaHub will have its own set.

         Clarification from Rob D...
         The node_lan_config_static_ip table is not passed around the mesh to each hub because each hub can define the table,
         because it is a "node_" table. In Node Manager, when ip mode is set to static, the use field in the mesh_lan_config table
         is examined and the the node_lan_config_static_ip use field is set to the same value.
         On loading the node manager, the node_lan_config_static_ip use fields are set to the same value as the mesh_lan_config use
         fields if the ip mode is set to static.”
         */

        let lanInUse = parentVm.meshLanConfig.lans[selectedLan].use
        return ipManagmentModeForSelectedLan == .STATIC && lanInUse
    }

}
