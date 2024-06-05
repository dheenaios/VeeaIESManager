//
//  SubnetConversionHelper.swift
//  Subnet Calculator
//
//  Created by Richard Stockdale on 20/11/2019.
//  Copyright © 2019 RGB Consulting. All rights reserved.
//

import Foundation


/// Helper methods for making various conversions relevent to subnet calculation
struct SubnetConversionHelper {
    
    // MARK: - Prefix to Mask
    
    
    /// Convert a prefix (e.g. /32) to a mask (e.g. 255.255.255.0)
    /// - Parameter prefix: The prefix as an int
    static func prefixToMask(prefix: Int) -> String? {
        let binary = prefixToBinary(prefix: prefix)
        let octets = binary.split(by: 8)
        
        var octetNums = [Int]()
        for octet in octets {
            if let number = Int(octet, radix: 2) {
                octetNums.append(number)
            }
            else {
                return nil
            }
        }
        
        return intArrayToIpString(arr: octetNums)
    }
    
    
    /// Takes an array of Ints and returns an IP address based on those balues
    /// - Parameter arr: Array of 4 Ints
    static func intArrayToIpString(arr: [Int]) -> String? {
        if arr.count != 4 {
            return nil
        }
        
        var result = ""
        for (index, octet) in arr.enumerated() {
            result.append(String(octet))
            
            if index < 3 {
                result.append(".")
            }
        }
        
        return result
    }
    
    /// Convert a prefix (e.g. /32 )to a binary representation (e.g. 11111111111111111111111100000000)
    /// - Parameter prefix: The prefix
    static func prefixToBinary(prefix: Int) -> String {
        
        var binaryString = ""
        for n in 0...31 {
            binaryString.append(n < prefix ? "1" : "0")
        }
        
        return binaryString
    }
    
    // MARK: - Mask to Prefix
    
    
    /// Convert a mask (e.g. 11111111111111111111111100000000) to a prefix (e.g. /32)
    /// - Parameter mask: The bit mask
    static func maskToPrefix(mask: String) -> Int? {
        guard let binary = addressToBinaryString(mask: mask) else {
            return nil
        }
        
        var count = 0
        for char in binary {
            if char == "1" {
                count += 1
            }
        }
        
        return count
    }
    
    // MARK: - Address or Mask Conversions
    
    /// Converts a mask or address (255.255.255.0) to a binary string
    /// - Parameter mask: The mask or IP
    static func addressToBinaryString(mask: String) -> String? {
        let componenets = mask.split(separator: ".")
        
        if componenets.count != 4 {
            return nil
        }
        
        var binaryString = ""
        for str in componenets {
            guard let result = octetToBinary(octet: String(str)) else {
                return nil
            }
            
            binaryString.append(result)
        }
        
        return binaryString
    }
    
    /// Convert a 4 octect address or mask to an array of ints
    /// - Parameter address: The address or mask
    static func addressStringToIntArray(address: String) -> [Int]? {
        let octets = address.split(separator: ".")
        
        if octets.count != 4 {
            return nil
        }
        
        var octetNums = [Int]()
        for octet in octets {
            if let number = Int.init(octet) {
                octetNums.append(number)
            }
            else {
                return nil
            }
        }
        
        return octetNums
    }
    
    /// Converts a mask or IP (255.255.255.0) an array of 4 binary strings
    /// - Parameter mask: the mask or IP
    static func addressStringToBinaryArray(mask: String) -> [String]? {
        let componenets = mask.split(separator: ".")
        
        if componenets.count != 4 {
            return nil
        }
        
        var binaryArray = [String]()
        for str in componenets {
            guard let result = octetToBinary(octet: String(str)) else {
                return nil
            }
            
            binaryArray.append(result)
        }
        
        return binaryArray
    }
    
    static func addressStringToReversedBinaryArray(mask: String) -> [String]? {
        guard let binaryAddress = addressStringToBinaryArray(mask: mask) else {
            return nil
        }
        
        var reversedSubnet: [String] = ["", "", "", ""]
        var part = 0
        
        while part < 4 {
            let numberSubnet: String = binaryAddress[part]
            var i = 0
            
            while i < 8 {
                let indexSubnet = numberSubnet.index(numberSubnet.startIndex, offsetBy: i)
                
                
                if let item = Int(numberSubnet[indexSubnet].description)?.boolValue {
                    if item {
                        reversedSubnet[part].append("0")
                    } else {
                        reversedSubnet[part].append("1")
                    }
                    
                    i += 1
                }
                else {
                    return nil
                }
            }
            
            part += 1
        }
        
        return reversedSubnet
    }
    
    
    /// Converts a binary array of strings to a usable address or mask (192.168.86.93)
    /// - Parameter array: Array of 4 binary strings
    static func binaryArrayToIp(array: [String]) -> String {
        
        var result: String = ""
        var i = 0
        while i < 4 {
            
            result.append(String(array[i].binaryToInt))
            if i < 3 {
                result.append(".")
            }
            
            i += 1
        }
        
        return result
        
    }
    
    // MARK: - Helpers
    
    /// Gets a network address for the given IP and Mask
    /// - Parameters:
    ///   - ip: IP as a string (192.168.86.96)
    ///   - mask: Mask as a string (255.255.255.0)
    static func getFirstAddressInSubnet(ip: String, mask: String) -> String? {
        
        guard let binaryIP = addressStringToBinaryArray(mask: ip),
            let binarySubnet = addressStringToBinaryArray(mask: mask) else {
                return nil
        }
        
        var networkAddress: [String] = ["", "", "", ""]
        var part = 0
        while part < 4 { // breaking down the array
            
            let numberIP: String = binaryIP[part]
            let numberSubnet: String = binarySubnet[part]
            
            var i = 0
            
            while i < 8 {
                let indexIP = numberIP.index(numberIP.startIndex, offsetBy: i)
                let indexSubnet = numberSubnet.index(numberSubnet.startIndex, offsetBy: i)
                
                
                if Int(numberIP[indexIP].description)?.boolValue ?? false &&
                    Int(numberSubnet[indexSubnet].description)?.boolValue ?? false {
                    networkAddress[part].append("1")
                    
                } else {
                    networkAddress[part].append("0")
                }
                
                i += 1
            }
            
            part += 1
        }
        
        // Convert network address in binary to a stirng
        let addr = binaryArrayToIp(array: networkAddress)
        
        return addr
    }
    
    
    /// Convert an octet string (192) to its binary representation (11110011)
    /// - Parameter octet: The octet string
    static func octetToBinary(octet: String) -> String? {
        guard let octetInt = Int(octet) else {
            return nil
        }
        if octetInt > 255 {
            return nil
        }
        let result = UInt8(octetInt).binaryDescription
        
        return result
    }
}

fileprivate extension BinaryInteger {
    var binaryDescription: String {
        var binaryString = ""
        var internalNumber = self
        var counter = 0

        for _ in (1...self.bitWidth) {
            binaryString.insert(contentsOf: "\(internalNumber & 1)", at: binaryString.startIndex)
            internalNumber >>= 1
            counter += 1
        }

        return binaryString
    }
}

extension Int {
    var boolValue: Bool {
        get {
            return self == 0 ? false : true
        }
    }
}

fileprivate extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }
    
    var binaryToInt: Int {
        return Int(strtoul(self, nil, 2))
    }
}
