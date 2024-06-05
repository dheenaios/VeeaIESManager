//
//  IPSubnetCalculationModel.swift
//  Subnet Calculator
//
//  Created by Richard Stockdale on 20/11/2019.
//  Copyright © 2019 RGB Consulting. All rights reserved.
//

import Foundation

struct SubnetModel {
    public private(set) var ipv4Address: String
    public private(set) var subnetMask: String?
    public private(set) var prefix: Int?

    public private(set) var startHostAddress: String?
    public private(set) var endHostAddress: String?
    public private(set) var numberOfHosts: Int?
    public private(set) var networkClass: String?
    public private(set) var networkAddress: String?
    public private(set) var broadcastAddress: String?

    static func subnet(fromIpAndPrefix subnet: String) -> SubnetModel? {
        let components = subnet.split(separator: "/")
        
        if components.count != 2 { return nil }
        
        let ip = String(components.first!)
        let prefixString = String(components.last!)
        guard let prefix = Int(prefixString) else {
            return nil
        }
        
        return SubnetModel.init(ipv4: ip, prefix: prefix)
    }
    
    init(ipv4: String, subnetMask: String) {
        self.ipv4Address = ipv4
        self.subnetMask = subnetMask
        self.prefix = SubnetConversionHelper.maskToPrefix(mask: subnetMask)
        
        commonInit()
    }

    init(ipv4: String, prefix: Int) {
        self.ipv4Address = ipv4
        self.prefix = prefix
        self.subnetMask = SubnetConversionHelper.prefixToMask(prefix: prefix)
        
        commonInit()
    }
    
    private mutating func commonInit() {
        broadcastAddress = calcuateBroadcastAddress()
        networkAddress = calculateNetworkAddress()
        startHostAddress = calculateStartingHostAddress()
        endHostAddress = calculateEndingHostAddress()
        numberOfHosts = calculateMaxNumberOfHosts()
        networkClass = calculateNetworkClass()
    }
    
    func calculateStartingHostAddress() -> String? {
        guard let mask = subnetMask else {
            return nil
        }
        
        guard let networkAddress = SubnetConversionHelper.getFirstAddressInSubnet(ip: ipv4Address, mask: mask) else {
            return nil
        }
        
        guard var intArray: [Int] = SubnetConversionHelper.addressStringToIntArray(address: networkAddress) else {
            return nil
        }
        
        if intArray[3] < 256 {
            intArray[3] += 1
        } else {
            intArray[2] += 1
            intArray[3] = 0
        }
        
        let ip = SubnetConversionHelper.intArrayToIpString(arr: intArray)
        return ip
    }
    
    func calculateEndingHostAddress() -> String? {
        guard let broadcastAddr = broadcastAddress else {
            return nil
        }
        
        guard var intArray = SubnetConversionHelper.addressStringToIntArray(address: broadcastAddr) else {
            return nil
        }
        
        if intArray[3] < 0 {
            intArray[2] -= 1
            intArray[3] = 255
        } else {
            intArray[3] -= 1
        }
        
        guard let address = SubnetConversionHelper.intArrayToIpString(arr: intArray) else {
            return nil
        }
        
        return address
    }
    
    func calcuateBroadcastAddress() -> String? {
        guard let mask = subnetMask else {
            return nil
        }
        
        guard let reversedSubnet = SubnetConversionHelper.addressStringToReversedBinaryArray(mask: mask) else {
            return nil
        }
        
        guard let binaryIP = SubnetConversionHelper.addressStringToBinaryArray(mask: ipv4Address) else {
            return nil
        }
        
        var broadcastAddress: [String] = ["", "", "", ""]
        
        var part = 0
        
        while part < 4 {
            
            let numberSubnet: String = reversedSubnet[part]
            let numberIP: String = binaryIP[part]
            
            var i = 0
            
            while i < 8 {
                let indexIP = numberIP.index(numberIP.startIndex, offsetBy: i)
                let indexSubnet = numberSubnet.index(numberSubnet.startIndex, offsetBy: i)
                
                if Int(numberIP[indexIP].description)!.boolValue ||
                    Int(numberSubnet[indexSubnet].description)!.boolValue {
                    broadcastAddress[part].append("1")
                    
                } else {
                    broadcastAddress[part].append("0")
                }
                
                i += 1
            }
            
            part += 1
        }
        
        let address = SubnetConversionHelper.binaryArrayToIp(array: broadcastAddress)
        
        return address
    }
    
    private func calculateMaxNumberOfHosts() -> Int? {
        guard let maskLength = prefix else {
            return nil
        }
        let unmaskedBits = 32 - maskLength
        let maxHosts: Int = Int(pow(Double(2),Double(unmaskedBits))) - 2
        
        return maxHosts
    }
    
    private func calculateNetworkClass() -> String? {
        guard let ipAddress = SubnetConversionHelper.addressStringToIntArray(address: ipv4Address) else {
            return nil
        }
        
        switch ipAddress[0] {
        case 1...126:
            return "A"
        case 127:
            return "Reserved loop back"
        case 128...191:
            return "B"
        case 192...223:
            return "C"
        case 224...239:
            return "D"
        case 240...255:
            return "D"
        default:
            return nil
        }
    }
    
    private func calculateNetworkAddress() -> String? {
        guard let mask = subnetMask else {
            return nil
        }
        
        return SubnetConversionHelper.getFirstAddressInSubnet(ip: ipv4Address, mask: mask)
    }
    
    func description() -> String {
        var str = "========== IP DETAILS ==========\n"
        str.append("IP Address: \(ipv4Address)\n")
        str.append("Subnet mask: \(subnetMask ?? "None")\n")
        str.append("Prefix: \(prefix ?? -1)\n")
        str.append("Starting Host IP: \(startHostAddress ?? "Error")\n")
        str.append("Ending Host IP: \(endHostAddress ?? "Error")\n")
        str.append("Max Hosts: \(numberOfHosts ?? -1)\n")
        str.append("Broadcast address: \(broadcastAddress ?? "Error")\n")
        str.append("Network address: \(networkAddress ?? "Error")\n")
        str.append("Network class: \(networkClass ?? "Error")\n")
        
        str.append("================================")
        
        return str
    }
}

// MARK: - Helper methods
extension SubnetModel {
    
    
    /// Is the IP address the first IP in the subnet?
    var ipIsFirstInSubnet: Bool {
        get {
            return ipv4Address == networkAddress
        }
    }
}

