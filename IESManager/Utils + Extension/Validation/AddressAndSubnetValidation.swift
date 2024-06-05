//
//  AddressAndSubnetValidation.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 03/02/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

class AddressAndSubnetValidation {
    
    private static var tag = "AddressAndSubnetValidation"
    
    /// Is the address the first IP of the subnet?
    /// Returns none if there is no issue. If there is an issue a user presentable message is returned
    /// - Parameter addressSubnetString: the address and subnet in the format xxx.xxx.xxx.xxx/xx
    static func isFirstAddressAndPrefixValid(addressSubnetString: String) -> String? {
        if addressSubnetString.isEmpty {
            return nil
        }
        
        if StringValidation.doesStringContainLetters(candidate: addressSubnetString) {
            return "The IP you entered contains letters.".localized()
        }
        
        let components = addressSubnetString.split(separator: "/")
        
        if components.count != 2 {
            Logger.log(tag: tag, message: "\("String is malformed -".localized()) \(addressSubnetString)")
            return "IP and Subnet value is badly formed. Please use the format xxx.xxx.xxx.xxx/xxx".localized()
        }
        
        let ip = String(components.first!)
        let subnet = String (components.last!)
        
        // Check the IP is valid
        if !AddressAndPortValidation.isIPValid(string: ip) {
            return "Invalid IP address entered".localized()
        }
        
        guard let subnetInt = Int(subnet) else  {
            return "Could not parse the subnet".localized()
        }
        
        if !isSubnetValid(subnet: subnetInt) {
            return "Invalid Subnet".localized()
        }
                
        let ipModel = SubnetModel.init(ipv4: ip, prefix: subnetInt)

        if let networkIp = ipModel.networkAddress {
            if !ipModel.ipIsFirstInSubnet {
                return "\("The provided IP is not the first IP in the subnet. It should be".localized()) \(networkIp) \("for the prefix".localized()) \(subnetInt)"
            }
        }
        
        return nil
    }
    
    static func isSubnetValid(subnet: Int) -> Bool {
        return subnet < 32 && subnet > -1
    }
    
    static func areBothIpsOnSameSubnet(ipA: String, ipB: String, mask: Int) -> Bool {
        // Get the mask and IPs binary representations
        let mask = SubnetConversionHelper.prefixToBinary(prefix: mask)
        let ipABinary = SubnetConversionHelper.addressToBinaryString(mask: ipA)
        let ipBBinary = SubnetConversionHelper.addressToBinaryString(mask: ipB)
        
        // Get the index of the first 0 from the mask.
        // If there is no 0 then the mask will be 255.255.255.255
        // In which case its a subnet of 0 hosts
        guard let termIndex = mask.firstIndex(of: "0") else {
            return false
        }
        
        // Get everything under the mask from ipA and ipB
        let underA = ipABinary?.prefix(upTo: termIndex)
        let underB = ipBBinary?.prefix(upTo: termIndex)
        
        // If everything under the mask is the same, then the 2 ips are on the same subnet
        return underA == underB
    }
    
    /// Do the address and subnet prefix appear to be valid
    /// - Parameter addressSubnetString: The address and prefix. E.g. xxx.xxx.xxx.xxx/xx
    /// - Returns: True false
    static func isAddressAndPrefixValid(addressSubnetString: String) -> Bool {
        let components = addressSubnetString.split(separator: "/")
        
        if addressSubnetString.isEmpty ||
            StringValidation.doesStringContainLetters(candidate: addressSubnetString) ||
            components.count != 2 {
            return false
        }
        
        let ip = String(components.first!)
        let subnet = String (components.last!)
        
        if !AddressAndPortValidation.isIPValid(string: ip) {
            return false
        }
        
        guard let subnetInt = Int(subnet) else  {
            return false
        }
        
        if !isSubnetValid(subnet: subnetInt) {
            return false
        }
        
        return true
    }
}
