//
//  Data+Extensions.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/23/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
// MARK: - Hex
public extension Data {
    
    /// Returns the data as a hex string
    var hexadecimalString: NSString {
        var bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &bytes, count: count)
        
        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }
        
        return NSString(string: hexString)
    }
    
    var utf8String: String {
        return String(data: self, encoding: .utf8)!
    }
    
    
}

// MARK: - JSON
extension Data {
    func toJson () -> [String : Any]? {
        if let json = try? JSONSerialization.jsonObject(with: self,
                                                        options: .mutableContainers) as? [String : Any] {
            return json
        } else {
            return nil
        }
    }
    
    func printJson() -> String? {
        return String(data: self, encoding: String.Encoding.utf8)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
