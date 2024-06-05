//
//  SHA1.swift
//  HubLibrary
//
//  Created by Al on 05/06/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

class SHA1 {
    class func hashBytesFromBytes(_ bytes: [UInt8]) -> [UInt8] {
        let data = Data(bytes)
        let result = CryptoWrapper.hashBytes(fromBytes: data)
        return [UInt8](result)
    }
    
    class func hashBytesFromString(_ string: String) -> [UInt8] {
        let data = Data(Utils.stringToByteArray(string))
        let result = CryptoWrapper.hashBytes(fromBytes: data)
        return [UInt8](result)
    }
    
    class func hexStringFromBytes(_ bytes: [UInt8]) -> String {
        return hexStringFromString(Utils.stringFromByteArray(bytes)!)
    }
    
    class func hexStringFromString(_ string: String) -> String {
        let bytes = hashBytesFromString(string)
        return Utils.hexStringFromBytes(bytes)
    }
    
    class func truncatedHashBytesFromBytes(_ bytes: [UInt8]) -> [UInt8] {
        let hashBytes = hashBytesFromBytes(bytes)
        return Array(hashBytes[0..<10])
    }
    
    class func truncatedHashBytesFromString(_ string: String) -> [UInt8] {
        let hashBytes = hashBytesFromString(string)
        return Array(hashBytes[0..<10])
    }
    
    class func truncatedHexStringFromBytes(_ bytes: [UInt8]) -> String {
        let hexString = hexStringFromBytes(bytes)
        
        let index = hexString.index(hexString.startIndex, offsetBy: 20)
        let subString = hexString[index...]
        return String(subString)
    }
    
    class func truncatedHexStringFromString(_ string: String) -> String {
        let hexString = hexStringFromString(string)
        
        let index = hexString.index(hexString.startIndex, offsetBy: 20)
        let subString = hexString[index...]
        return String(subString)
    }
}
