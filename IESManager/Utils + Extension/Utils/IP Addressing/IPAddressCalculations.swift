//
//  IPAddressCalculations.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 31/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public class IPAddressCalculations {
    
    /// Creates an Int32 representation of an IP address
    /// - Parameter addrString: The candidate IP
    public static func ipToInt(addrString: String) -> Int? {
        if addrString.isEmpty {
            return nil
        }
        
        let ipStringsArray = addrString.split(separator: ".")
        
        if ipStringsArray.count != 4 {
            return nil
        }
        
        var ipIntsArray = [Int]()
        
        for str in ipStringsArray {
            if let integer = Int(str) {
                ipIntsArray.append(integer)
            }
        }
        
        if ipIntsArray.count != 4 {
            return nil
        }
        
        let val = (ipIntsArray[0]<<24) + (ipIntsArray[1]<<16) + (ipIntsArray[2]<<8) + (ipIntsArray[3]);
        
        return val
    }
    
    /// The number of IPs between a starting and an ending address
    /// - Parameters:
    ///   - addr1: The bottom IP in the range
    ///   - addr2: The ending IP in the Range
    public static func calculateIpRange(addr1: String, addr2: String) -> Int? {
        let startInt = IPAddressCalculations.ipToInt(addrString: addr1)
        let endInt = IPAddressCalculations.ipToInt(addrString: addr2)
        
        if startInt == nil || endInt == nil {
            return nil
        }
               
        if startInt! > endInt! {
            return nil
        }
        
        let diff = endInt! - startInt!
        return diff
    }
    
    /// Gets the number of IPs between two IP addresses as a string.
    /// An error description is returned if there is a a problem with the input
    /// - Parameters:
    ///   - addr1: The bottom IP in the range
    ///   - addr2: The ending IP in the Range
    public static func calculateIpRangeDescription(addr1: String, addr2: String) -> String {
        let startInt = IPAddressCalculations.ipToInt(addrString: addr1)
        let endInt = IPAddressCalculations.ipToInt(addrString: addr2)
        
        if startInt == nil || endInt == nil {
            return "-"//"Bad format".localized()
        }
               
        if startInt! > endInt! {
            return "Start IP > End IP".localized()
        }
        
        let diff = endInt! - startInt!
        return "\(diff + 1)"
    }
    
    /// Check is a given IP is between two other IPs
    /// - Parameters:
    ///   - ip: The IP to check
    ///   - startingIP: The bottom IP in the range
    ///   - endingIP: The ending IP in the Range
    public static func isIP(ip: String, between startingIP: String, and endingIP: String) -> Bool {
        guard let ipInt = ipToInt(addrString: ip),
            let startingIpInt = ipToInt(addrString: startingIP),
            let endingIpInt = ipToInt(addrString: endingIP) else {
            return false
        }
        
        if ipInt >= startingIpInt && ipInt <= endingIpInt {
            return true
        }
        
        return false
    }
}
