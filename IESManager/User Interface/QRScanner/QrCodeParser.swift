//
//  QrCodeParser.swift
//  IESManager
//
//  Created by Richard Stockdale on 28/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

struct QrCodeParser {
    
    
    /// Get the device name from the QR code
    /// - Parameter code: The scanned QR code
    /// - Returns: The default device name
    static func getDefaultDeviceName(from code: String) -> String {
        // Gets the last 4 digits from serial provided by the QR code
        return code.split(from: code.count - 19, to: code.count - 16)
    }
    
    
    /// Get the serial number from the QR code
    /// - Parameter code: The scanned QR code
    /// - Returns: The devices Serial number
    static func getSerielNumberOfDevice(from code: String) -> String {
        // Gets the last 4 digits from serial provided by the QR code
        
        let serial = code.split(from: 2, to: code.count - 16)
        return serial
    }
    
}
