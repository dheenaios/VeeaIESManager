//
//  PortAndIPValidation.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 21/09/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation


struct AddressAndPortValidation {

    /// Returns the number of components for a CIDR. Should be 2
    static func ipAndSubnetComponents(string: String) -> Int {
        let components = string.split(separator: "/")
        return components.count
    }

    static func simpleIpSubnetError(string: String?) -> String? {
        guard let components = string?.split(separator: "/") else {
            return "Static IP should have an IP address and subnet mask\n(xxx.xxx.xxx.xxx/xxx)".localized()
        }

        guard components.count == 2 else {
            return "Static IP should have an IP address and subnet mask\n(xxx.xxx.xxx.xxx/xxx)".localized()
        }

        let ip = components[0]
        let mask = components[1]

        if !isIPValid(string: String(ip)) {
            return "Invalid IP Address".localized()
        }

        if !isSubnetPrefixValid(mask: String(mask)) {
            return "Invalid mask".localized()
        }

        return nil
    }

    static func ipAndSubnetError(string: String?) -> String? {
        // Validate the IP and Subnets formatting
        guard let components = string?.split(separator: "/") else {
            return "Invalid IP Address".localized()
        }
        
        if components.count > 2 {
            return "Invalid IP Address".localized()
        }
        
        // Check the IP address is correct
        if let ip = components.first {
            if !isIPValid(string: String(ip)) {
                return "Invalid IP Address".localized()
            }
        }
        
        if components.count == 1 { return nil }
        
        // If there are 2 components check the subnet is correct
        if components.count == 2 {
            let mask = components.last
            if isSubnetPrefixValid(mask: String(mask!)) == false {
                return "Invalid Subnet Prefix".localized()
            }
        }
        
        // Now we have the valid strings, we can create a subnet model...
        guard let string = string,
              let model = SubnetModel.subnet(fromIpAndPrefix: string) else {
            return "Invalid IP Address"
        }
        
        if model.networkAddress == model.ipv4Address {
            return nil
        }
        
        if let address = model.networkAddress {
            return "CDIR IP address should be \(address)"
        }

        return "CDIR IP address incorrect"
    }
    
    static func isIPValid(string: String) -> Bool {
        if string.isEmpty { return false }

        let parts = string.components(separatedBy: ".")
        if parts.count != 4 { return false}
        for part in parts {
            if part.isEmpty {
                return false
            }
        }

        if parts.first == "0" { return false }

        let nums = parts.compactMap { Int($0) }
        return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 255}.count == 4
    }

    // xxx.xxx.xxx.xxx/xx
    static func isSubnetPrefixValid(mask: String) -> Bool {
        guard let maskInt = Int(mask) else {
            return false
        }
        
        if maskInt >= 0 && maskInt < 33 {
            return true
        }
        
        return false
    }
    // 255.255.255.254
    static func subnetMaskIsValid(mask: String) -> Bool {
        let parts = mask.components(separatedBy: ".")
        if parts.count != 4 {
            return false
        }
        
        let nums = parts.compactMap { Int($0) }
        
        var last: Int?
        for num in nums {
            if num > 255 || num < 0 {
                return false
            }
            
            if let last = last {
                if num > last {
                    return false
                }
            }
            
            last = num
        }
        
        return true
    }
    
    static func isPortRangeValid(string: String) -> Bool {
        if !rangeIsAccending(string: string) {
            return false
        }
        
        let pattern = "^*[0-9:]*$"
        
        // Does the whole string match?
        if let typeRange = string.range(of: pattern,
                                        options: .regularExpression) {
            
            let fullMatch = String(string[typeRange])
            if fullMatch.count == string.count {
                return true
            }
        }
        
        return false
    }
    
    
    /// // First port in range must lower than the last.
    /// - Parameter string: The port range (123:456)
    /// - Returns: True if accending
    static func rangeIsAccending(string: String) -> Bool {
        // Is it a single port
        if !string.contains(":") {
            return true
        }
        
        // Check the range
        let split  = string.split(separator: ":")
        if split.count != 2 { return false }
        guard let p1 = split.first, let p2 = split.last else { return false }
        if p1.isEmpty || p2.isEmpty { return false }
        guard let start = Int(p1), let end = Int(p2) else { return false }
        
        if start < end { return true }
        
        return false
    }
    
    static func isMacAddressValid(string: String) -> Bool {
        let macRegex = "([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})"
        if let macTest = NSPredicate(format: "SELF MATCHES %@", macRegex) as NSPredicate? {
            return macTest.evaluate(with: string)
        }
        return false
    }
    
    static func validateRule(rule: FirewallRule) -> String? {
        
        if rule.ruleActionType == FirewallRule.FirewallRuleActionType.FORWARD {
            return validateForwardRule(rule: rule)
        }

        if let errorString = validatePlaceholderRoute(cidr: rule.mSource) {
            return errorString
        }
        
        if let ipSubnetError = ipAndSubnetError(string: rule.mSource) {
            if !isValidPlaceholderRoute(cidr: rule.mSource) {
                return ipSubnetError
            }
        }
        
        if let portRange = rule.mPort {
            if isPortRangeValid(string: portRange) == false {
                return "Invalid port or port range".localized()
            }
        }
        
        if let errorString = remotePortAllowable(rule: rule) {
            return errorString
        }


        
        return nil
    }

    // VHM-1601: Firewall configuration should catch 0.0.0.0 and automatically apply /0 to prevent user misconfiguration
    /// This does not validate the CIDR. It only checks if it is a 0.0.0.0/0 and returns an error message
    static func validatePlaceholderRoute(cidr: String?) -> String? {
        guard let cidr else { return nil }
        let message = "Invalid CIDR subnet. \(cidr) is not a valid subnet for all IP addresses - do you mean \"0.0.0.0/0\"?"

        if isValidPlaceholderRoute(cidr: cidr) { return nil }

        return message
    }

    // VHM-1601: Firewall configuration should catch 0.0.0.0 and automatically apply /0 to prevent user misconfiguration
    /// This does not validate the CIDR. It only checks if it is a 0.0.0.0/0
    static func isValidPlaceholderRoute(cidr: String?) -> Bool {
        guard let cidr else { return false }

        if cidr == "0.0.0.0" { return false }
        let components = cidr.split(separator: "/")
        if components.count != 2 { return false }
        if let ip = components.first,
           let subnet = components.last {
            if ip == "0.0.0.0" && subnet == "0" { return true }
        }

        return false
    }
    
    private static func validateForwardRule(rule: FirewallRule) -> String? {
        guard let portRange = rule.mPort else {
            return "No port information added".localized()
        }
        
        // Check if the port is valid
        
        if !AddressAndPortValidation.isPortRangeValid(string: portRange) {
            return "The starting value in a port range is higher than the ending value".localized()
        }
        
        if let errorString = localPortAllowable(rule: rule) {
            return errorString
        }
        
        if let errorString = remotePortAllowable(rule: rule) {
            return errorString
        }
        
        return nil
    }
    
    static func localPortAllowable(rule: FirewallRule) -> String? {
        guard let portString = rule.mLocalPort,
              let port = Int(portString),
              let ruleID = rule.ruleID else {
                  return "Local Port is not valid".localized()
              }
        
        if portString.isEmpty {
            return "\("Rule".localized()) \(ruleID) \("local Port required".localized())"
        }
        
        if port.between(lowerValue: 1, and: 65535) {
            return nil
        }
        
        return "\("Rule".localized()) \(ruleID) \("local port must be between 1 and 65535".localized())"
    }
    
    // This can be a range
    static func remotePortAllowable(rule: FirewallRule) -> String? {
        guard let port = rule.mPort,
              let ruleID = rule.ruleID else {
                  return "Port or Port Range is not valid".localized()
              }
        
        let components = port.split(separator: ":")
        
        if components.count == 1 {
            if let i = Int(components.first!) {
                if i.between(lowerValue: 0, and: 65535) {
                    return nil
                }
                
                return "\("Rule".localized()) \(ruleID), \("port must be between 0 and 65535".localized())"
            }
            
            return "Port or Port Range is not valid".localized()
        }
        if components.count == 2 {
            let f = components.first!
            let l = components.last!
            
            guard let first = Int(f),
                  let last = Int(l) else {
                      return "\("Rule".localized()) \(ruleID), \("port Range is not valid".localized())"
                  }
            
            if !first.between(lowerValue: 0, and: 65535) || !last.between(lowerValue: 0, and: 65535) {
                return "\("Rule".localized()) \(ruleID), \("some ports out of the acceptable range (0 - 65535).".localized())"
            }
        }
        else {
            return "\("Rule".localized()) \(ruleID)\(", port range is incorrectly formatted".localized())"
        }
        
        return nil
    }
}
