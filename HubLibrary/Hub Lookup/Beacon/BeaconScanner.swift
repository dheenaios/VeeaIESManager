//
//  BeaconScanner.swift
//  HubLibrary
//
//  Created by Al on 21/02/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BeaconScannerDelegate {
    func beaconsWereUpdated(beacons: [VeeaBeacon])
}

class BeaconScanner : NSObject {
    
    fileprivate var startRequested: Bool
    fileprivate var delegate: Delegate?
    
    fileprivate var centralManager: CBCentralManager!
    fileprivate var beacons = [VeeaBeacon]()
    
    fileprivate var instanceFilter: [UInt8]?
    fileprivate var namespaceFilter: [UInt8]?
    
    private let kEddystoneServiceUuid = "0000FEAA-0000-1000-8000-00805F9B34FB"
    
    override init() {
        startRequested = false
        
        super.init()
        
        NSLog("new BeaconScanner")
        
        centralManager = CBCentralManager()
        centralManager.delegate = self
    }
    
    public func resetBeaconList() {
        beacons = [VeeaBeacon]()
    }
    
    fileprivate func foundBeacon(id: UUID, rssi: NSNumber, advertisementData ad: NSData, serviceData: NSData) {
        if isVirtuosysBeacon(advertisementData: ad) {
            var valid = false
            
            let serviceDataBytes = Utils.getByteArray(serviceData)
            if serviceDataBytes.count == 18 {
                let namespaceBytes = Array(serviceDataBytes[2..<12])
                let instanceIdBytes = Array(serviceDataBytes[12..<18])
                
                valid = isValidNamespace(bytes: namespaceBytes)
                if valid {
                    valid = isValidInstanceId(bytes: instanceIdBytes)
                }
                
                if valid {
                    let beacon = VeeaBeacon(id: id, rssi: rssi)
                    
                    if beacon.ssid.contains("2083") {
                        //print("Found")
                    }
                    
                    if let found = beacons.first(where: {$0.id == id}) {
                        found.rssi = rssi
                        found.lastSeen = NSDate()
                        
                    } else {
                        beacon.extractManufacturerSpecificData(advertisementData: ad)
                        beacons.append(beacon)
                        
                        if beacon.ssid.contains("2083") {
                            //print("Found 2")
                        }
                    }
                    
                    delegate?.beaconsWereUpdated(beacons: beacons)
                }
                    
                else {
                    
                    //print("Invalid UUID: \(id.description)")
                }
            }
        }
        else {
            //print("Non Veea UUID: \(id.description)")
        }
    }
    
    private func isValidInstanceId(bytes: [UInt8]) -> Bool {
        if instanceFilter == nil || instanceFilter?.count == 0 {
            return true // no filter -> any instance is valid
        }
        
        if bytes.count != instanceFilter!.count {
            return false
        }
        
        var valid = true
        for i in 0..<instanceFilter!.count {
            valid = bytes[i] == instanceFilter![i]
        }
        
        return valid
    }
    
    private func isValidNamespace(bytes: [UInt8]) -> Bool {
        if namespaceFilter == nil || namespaceFilter?.count == 0 {
            return true
        }
        
        if bytes.count != namespaceFilter!.count {
            return false
        }
        
        var valid = true
        for i in 0..<namespaceFilter!.count {
            valid = bytes[i] == namespaceFilter![i]
        }
        
        return valid
    }
    
    private func isVirtuosysBeacon(advertisementData: NSData) -> Bool {
        let byteArray = Utils.getByteArray(advertisementData)
        return byteArray[0] == 0x3c && byteArray[1] == 0x03
    }
    
    fileprivate func startScan() {
        let serviceId = CBUUID(string: kEddystoneServiceUuid)
        centralManager.scanForPeripherals(withServices: [serviceId], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        NSLog("started")
    }
}

//
// MARK: - API
//
extension BeaconScanner {
    typealias Delegate = BeaconScannerDelegate
    
    func setDelegate(delegate: Delegate) {
        self.delegate = delegate
    }
    
    func startScanning() {
        NSLog("startScanning: ")
        
        if centralManager.state == .poweredOn {
            startScan()
            
        } else {
            NSLog("NOT started: state=\(stateString(centralManager.state))")
            startRequested = true
        }
    }
    
    func stopScanning() {
        NSLog("stopScanning")
        centralManager.stopScan()
    }
    
    func setFilters(namespace: String, instanceId: String) {
        if namespace.count > 0 {
            namespaceFilter = SHA1.truncatedHashBytesFromString(namespace)
        } else {
            namespaceFilter = [UInt8]()
        }
        
        if instanceId.count > 0 {
            instanceFilter = BCD.stringToBCD(string: instanceId)
        } else {
            instanceFilter = [UInt8]()
        }
        
        NSLog("namespaceFilter=\(String(describing: namespaceFilter)), instanceFilter=\(String(describing: instanceFilter))")
    }
}

//
// MARK: - CBCentralManagerDelegate
//
extension BeaconScanner : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn && startRequested) {
            startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] {
            let dict = advertisementData[CBAdvertisementDataServiceDataKey] as! [NSObject:NSData]
            if let serviceData = dict[CBUUID(string: "FEAA")] {
                foundBeacon(id: peripheral.identifier, rssi: RSSI, advertisementData: data as! NSData, serviceData: serviceData)
            }
        }
    }
    
    func stateString(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "unknown"
            
        case .resetting:
            return "resetting"
            
        case .unsupported:
            return "unsupported"
            
        case .unauthorized:
            return "unauthorized"
            
        case .poweredOff:
            return "poweredOff"
            
        case .poweredOn:
            return "poweredOn"
        @unknown default:
            return "Unknown State"
        }
    }
}
