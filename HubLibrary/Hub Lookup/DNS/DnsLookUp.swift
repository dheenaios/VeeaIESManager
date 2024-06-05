//
//  DnsLookUp.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 24/07/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public class DnsLookUp {
    public static func getIPFrom(dnsName: String) -> String? {
        Logger.log(tag: "DNS Lookup", message: "DNS Lookup for host \(dnsName)")
        if dnsName.isEmpty { return nil }
        
        let host = CFHostCreateWithName(nil, dnsName.lowercased() as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? {
            Logger.log(tag: "DNS Lookup", message: "Got addresses for \(dnsName)")
            for case let theAddress as NSData in addresses {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                               &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let numAddress = String(cString: hostname)
                    
                    if numAddress.contains("127.0.1.1") {
                        Logger.log(tag: "DNS Lookup", message: "DNS Lookup Error. Returned: \(numAddress) for \(dnsName)")
                        return nil
                    }
                    
                    return numAddress
                }
            }
        }
        
        return nil
    }
}
