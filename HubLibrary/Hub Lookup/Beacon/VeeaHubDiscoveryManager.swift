//
//  VeeaHub Manager.swift
//  HubLibrary
//
//  Created by Al on 27/02/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

public protocol VeeaHubDiscoveryManagerProtocol {
    func iesListUpdated(iesList: [VeeaHubConnection])
}

/**
 This class is used to discover IESs.
 
 NOTE: only one instance of this class may be used in any client application.
 
 Use the `instance`, `get`, or `manager` accessors (all three are synonyms) to create and obtain the instance.
 
 The `Delegate` is used to notify client code when an IES is discovered (or lost).
 
 - important:
 Unlike the Android library, the `Delegate` does currently notify of IES connection status changes. 
 
 This functionality may be supported in a later version of this library.
 
 */
public class VeeaHubDiscoveryManager {
    
    //   From apples documentation:RSSI The current RSSI of peripheral, in dBm. A value of 127 is reserved and indicates the RSSI was not available.
    private let notAvailable = 127
    
    public typealias Delegate = VeeaHubDiscoveryManagerProtocol

    //
    // MARK: - Instance accessors
    //
    /// - instance: the IesManager instance
    public static let instance = createImplementation()

    /// - get: the IesManager instance
    public static let get = instance
    
    /// - manager: the IesManager instance
    public static let mananger = instance
    
    private let beaconScanner: BeaconScanner
    
    fileprivate var iesList: [String : VeeaHubConnection]
    fileprivate var delegate: Delegate?
    
    fileprivate var namespaceFilter = ""
    fileprivate var instanceIdFilter = ""
    
    public var numberOfHubsSeen: Int {
        get {
            return iesList.count
        }
    }
    
    private static func createImplementation() -> VeeaHubDiscoveryManager {
        return VeeaHubDiscoveryManager()
    }

    private init() {
        beaconScanner = BeaconScanner()
        beaconScanner.setFilters(namespace: namespaceFilter, instanceId: instanceIdFilter)

        iesList = [:]
        beaconScanner.setDelegate(delegate: self)
    }
    
    /**
     Start or stop scanning for IESs.
     */
    public func scan(enable: Bool) {
        if enable {
            beaconScanner.startScanning()
        } else {
            beaconScanner.stopScanning()
        }
    }
    
    /** 
     Sets a new `Delegate` to use for IES discovery.
     */
    public func setDelegate(delegate: Delegate) {
        self.delegate = delegate
    }
    
    /**
     Sets namespace and instanceId filters for IES discovery.
     
     - parameters:
        - namespace:    plaintext namespace string; e.g. "lab.virtuosys.com"
        - instanceId:   plaintext instance string; e.g. "826000000045"
     */
    public func setFilters(namespace: String, instanceId: String) {
        namespaceFilter = namespace
        instanceIdFilter = instanceId
        
        beaconScanner.setFilters(namespace: namespaceFilter, instanceId: instanceIdFilter)
    }
    
    /**
     Sets the instance filter used when scanning for IESs.
 
     Must be capable of being encoded as a 6-byte BCD hex number; e.g. "826000000045"
 
     An empty string is used as a wildcard, allowing all IESs regardless of their instance ID to be discovered.
     
     - parameters:
        - instanceId:   plaintext instance string; e.g. "826000000045"
     */
    public func setInstanceFilter(instanceId: String) {
        instanceIdFilter = instanceId
        
        beaconScanner.setFilters(namespace: namespaceFilter, instanceId: instanceIdFilter)
    }
    
    /**
     Sets the IES namespace filter used when scanning for IESs.
     
     An empty string is used as a wildcard, allowing all IESs regardless of their namespace ID to be discovered.
     Library
     - parameters:
        - namespace:    plaintext namespace string; e.g. "lab.virtuosys.com"
     */
    public func setNamespaceFilter(namespace: String) {
        namespaceFilter = namespace
        
        beaconScanner.setFilters(namespace: namespaceFilter, instanceId: instanceIdFilter)
    }
    
    public func setBeaconEncryptKey(key: String) {
        iesList = [:]
        beaconScanner.resetBeaconList()
        VeeaBeacon.setBeaconEncryptKey(key: key)
    }
    
    public func resetBeaconEncryptKeyToDefault() {
        iesList = [:]
        beaconScanner.resetBeaconList()
        VeeaBeacon.resetBeaconEncryptKeyToDefault()
    }
}

//
// MARK: - BeaconScanner.Delegate
//
extension VeeaHubDiscoveryManager : BeaconScanner.Delegate {
    func beaconsWereUpdated(beacons: [VeeaBeacon]) {
        for beacon in beacons {
            if let ies = iesList[beacon.ssid] {
                ies.updateBeacon(beacon: beacon)
                
            } else {
                let ies = VeeaHubConnection(beacon: beacon)
                iesList[beacon.ssid] = ies
            }
        }
        
        let sortedIesList = Array(iesList.values).sorted() { $0.ssid < $1.ssid }
        
        delegate?.iesListUpdated(iesList: sortedIesList)
    }
}
