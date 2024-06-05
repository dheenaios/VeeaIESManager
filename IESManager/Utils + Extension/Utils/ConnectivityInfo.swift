//
//  ConnectivityInfo.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 14/12/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol ConnectivityInfoDidChangeProtocol {
    func connectivityStateDidChange()
}

class ConnectivityInfo: NSObject {
    
    private var btManager: CBCentralManager
    private var stateChangeDelegate: ConnectivityInfoDidChangeProtocol?
    
    var isBluetoothOn: Bool
    
    init(withDelegate delegate: ConnectivityInfoDidChangeProtocol) {
        isBluetoothOn = true
        stateChangeDelegate = delegate
        btManager = CBCentralManager()
        
        super.init()

        btManager.delegate = self
    }
}

extension ConnectivityInfo: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        Logger.log(tag: "ConnectivityInfo", message: "\("Bluetooth connectivity state changed") \(central.state)")
        
        switch central.state {
        case .poweredOff:
            isBluetoothOn = false
            break
        default:
            isBluetoothOn = true
            break
        }
        
        stateChangeDelegate?.connectivityStateDidChange()
    }
}
