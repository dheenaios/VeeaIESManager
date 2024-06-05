//
//  VirtuosysBeacon.swift
//  HubLibrary
//
//  Created by Al on 23/02/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

class VeeaBeacon  {
    private(set) var id: UUID            // iOS doesn't have an API to access beacon MAC address, so we'll have to use UUID
    var rssi: NSNumber
    var lastSeen: NSDate
    private(set) var ssid: String = "no SSID"
    private(set) var psk: String = "no PSK"
    
    
    /// Beacon Encryption Key with default value of "Virtu0sysLtd"
    internal static let beaconEncryptKeyDefault = "Virtu0sysLtd"
    private static var beaconEncryptKey = beaconEncryptKeyDefault
    
    
    private let kVirtuosysSsidMarker: UInt8 = 1
    
    private let kMarkerIndex = 2
    private let kSsidLengthIndex = 3
    
    // FIXME: temporary bodge for placeholder IES while NEHotspotHelper is pending
    init() {
        id = UUID()
        rssi = 0
                
        lastSeen = NSDate()
    }
    
    init(id: UUID, rssi: NSNumber) {
        self.id = id
        self.rssi = rssi
        
        self.lastSeen = NSDate()
    }

    func setSsid(ssid: String) {
        self.ssid = ssid
    }
    
    func extractManufacturerSpecificData(advertisementData ad: NSData) {
        if ad.length == 0 {
            NSLog("ERROR 0601")
            return
        }
        
        let adBytes = Utils.getByteArray(ad)
        if adBytes[kMarkerIndex] != kVirtuosysSsidMarker {
            NSLog("ERROR 0602")
            return
        }
        
        let ssidLength = Int(adBytes[kSsidLengthIndex])
        let pskLengthIndex = kSsidLengthIndex+1+ssidLength
        let ssidBytes = adBytes[kSsidLengthIndex+1 ..< pskLengthIndex]
        ssid = RC4Decoder.decode(bytes: Array(ssidBytes), key: VeeaBeacon.beaconEncryptKey)
        
        let pskLength = Int(adBytes[pskLengthIndex])
        let pskBytes = adBytes[pskLengthIndex+1 ..< pskLengthIndex+1+pskLength]
        psk = RC4Decoder.decode(bytes: Array(pskBytes), key: VeeaBeacon.beaconEncryptKey)
    }
    
    // MARK: - Beacon Encryption Key Management
    
    public static func getBeaconEncryptKey() -> String {
        return beaconEncryptKey
    }
    
    public static func setBeaconEncryptKey(key: String) {
        //print("BEACON: Setting beacon key to \(key)")
        
        if key.isEmpty {
            resetBeaconEncryptKeyToDefault()
            
            return
        }
        beaconEncryptKey = key
        
        //print("BEACON: New beacon key is \(beaconEncryptKey)")
    }
    
    public static func resetBeaconEncryptKeyToDefault() {
        //print("BEACON: Returning to default")
        beaconEncryptKey = beaconEncryptKeyDefault
    }
}

//
// MARK: - Equatable
//
extension VeeaBeacon : Equatable {
    static func == (lhs: VeeaBeacon, rhs: VeeaBeacon) -> Bool {
        return lhs.id == rhs.id
    }
}

//
// MARK: - Debug
//
extension VeeaBeacon : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(ssid)"
    }
}
