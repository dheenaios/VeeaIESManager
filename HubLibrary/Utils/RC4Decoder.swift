//
//  RC4Decoder.swift
//  HubLibrary
//
//  Created by Al on 24/02/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

// based on https://opensource.apple.com/source/xnu/xnu-1456.1.26/bsd/crypto/rc4/rc4.c

class RC4Decoder {
    var i1 = 0
    var i2 = 0
    var perm: [UInt8] = Array(repeating: 0, count: 256)
    
    init(key: String) {
        let keyBytes = Array(key.utf8)
        let keyLength = keyBytes.count
        
        var i = 0
        repeat {
            perm[i] = UInt8(i)
            
            i = i + 1
        } while i < 256
        
        i = 0
        var j = 0
        repeat {
            let iVal = Int(perm[i])
            let kVal = Int(keyBytes[i % keyLength])
            j += iVal + kVal
            
            swapBytes(i: i, j: j)
            
            i = i + 1
        } while i < 256
    }
    
    func crypt(_ bytes: [UInt8]) -> String {
        let result = cryptBytes(bytes)
        
        guard let str = Utils.stringFromByteArray(result) else {
            return ""
        }
        
        return str
    }
    
    func cryptBytes(_ bytes: [UInt8]) -> [UInt8] {
        var result: [UInt8] = Array(repeating: 0, count: bytes.count)
        
        var i = 0
        var j = 0
        repeat {
            i1 = i1 + 1
            i2 = (i2 + Int(perm[i1])) % 256
            
            swapBytes(i: i1, j: i2)
            
            j = (Int(perm[i1]) + Int(perm[i2])) % 256
            result[i] = bytes[i] ^ perm[j]
            
            i = i + 1
        } while i < bytes.count
        
        return result
    }
    
    func swapBytes(i: Int, j : Int) {
        let ix = i % 256
        let jx = j % 256
        
        let temp = perm[ix]
        perm[ix] = perm[jx]
        perm[jx] = temp
    }
    
    static func decode(bytes: [UInt8], key: String) -> String {
        let decoder = RC4Decoder(key: key)
        return decoder.crypt(bytes)
    }
}

