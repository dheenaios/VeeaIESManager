//
//  MeshDetailViewModel+Bluetooth.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 5/7/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import CoreBluetooth

extension MeshDetailViewModel: CBCentralManagerDelegate {
    
    private struct BLE {
        static var manager: CBCentralManager?
    }
    
    func checkIfBLEnabled() {
        BLE.manager = CBCentralManager()
        BLE.manager?.delegate = self
    }
    
    func stopBLScanner() {
        BLE.manager?.delegate = nil
        BLE.manager?.stopScan()
        BLE.manager = nil
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            self.isBluetoothEnabled.data = false
        case .poweredOn:
            self.isBluetoothEnabled.data = true
            
        default:
            break
        }
    }
}
