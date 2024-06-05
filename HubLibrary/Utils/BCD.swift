//
//  BCD.swift
//  HubLibrary
//
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

class BCD {
    class func stringToBCD(string: String) -> [UInt8] {
        let number = Int64(string)
        return Int64ToBCDBytes(number: number!)
    }
    
    class func Int64ToBCDBytes(number: Int64) -> [UInt8] {
        var digits = 0
        var num = number
        var temp = number
        while temp != 0 {
            digits += 1
            temp /= 10
        }
        
        let byteLen = digits % 2 == 0 ? digits / 2 : (digits + 1) / 2;
        let isOdd = digits % 2 != 0
        
        var bcd = [UInt8](repeating: 0, count: byteLen)
        for i in 0..<digits {
            let tmp = UInt8(num % 10) //as! UInt8
            
            if i == digits-1 && isOdd {
                bcd[i/2] = tmp
            } else if i % 2 == 0 {
                bcd[i/2] = tmp
            } else {
                let foo = tmp << 4
                bcd[i/2] |= foo
            }

            num /= 10
        }
        
        for i in 0..<byteLen/2 {
            let tmp = bcd[i]
            bcd[i] = bcd[byteLen-i-1]
            bcd[byteLen-i-1] = tmp
        }
        
        return bcd
    }
}
