//
//  IESScanner.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/25/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation


///
/// IESScannerDelegate
///
/// Implement this to receive notification s about IES.
protocol HubBeaconScannerDelegate {
    func didFindIes(_ device: VeeaHubConnection)
    func didUpdateIes(_ device: VeeaHubConnection)
    func didLooseIes(_ device: VeeaHubConnection)
}

class HubBeaconScanner: NSObject {
    
    static let shared = HubBeaconScanner()
    
    fileprivate let veeaHubDiscoveryManager = VeeaHubDiscoveryManager.instance
    
    /** How long we should go without a beacon sighting before considering it "lost". In seconds. */
    fileprivate let refreshTimeRate: Double = 3
    
    /** Current cache of the IES devices found. */
    public var iesCache: [VeeaHubConnection] = []
    private var iesCacheLastUpdate: Date?
    
    public var isIesCacheFresh: Bool {
        get {
            guard let iesCacheLastUpdate = iesCacheLastUpdate else {
                return false
            }
            
            if iesCacheLastUpdate.timeIntervalSinceNow > -15 {
                return true
            }
            
            return false
        }
    }
    
    fileprivate var lastSent: [String: VeeaHubConnection] = [:]
    
    var delegate: HubBeaconScannerDelegate?
    
    var timer: Timer?
    
    override init() {
        super.init()
        veeaHubDiscoveryManager.setDelegate(delegate: self)
    }


    /// Start a scan for a given beacon.
    /// - Parameter beacon: The beacon to be scanned for. Each mesh has a beacon accociated with it.
    func startScan(for beacon: VHBeacon) {
        stopScan()

        // Set the encryption ID
        veeaHubDiscoveryManager.setBeaconEncryptKey(key:  beacon.encryptKey)
        veeaHubDiscoveryManager.setFilters(namespace: beacon.subdomain,
                                           instanceId: beacon.instanceID)
        
        veeaHubDiscoveryManager.scan(enable: true)
        
        self.refreshList()
        timer = Timer.scheduledTimer(timeInterval: refreshTimeRate, target: self, selector: #selector(HubBeaconScanner.refreshList), userInfo: nil, repeats: true)
    }
    
    func stopScan() {
        veeaHubDiscoveryManager.scan(enable: false)
        timer?.invalidate()
    }
    
    @objc private func refreshList() {
        for ies in self.iesCache {
            if let _ = self.lastSent[ies.ssid] {
                self.delegate?.didUpdateIes(ies)
            } else {
                self.lastSent[ies.ssid] = ies
                self.delegate?.didFindIes(ies)
            }
        }
        
        // Finding lost nodes here
        let cachedKeys = self.lastSent.keys
        let lostNodes = cachedKeys.filter{ key in !iesCache.contains(where: { (ies) -> Bool in
            return key == ies.ssid
        })}
        for ssid in lostNodes {
            if let lostNode = self.lastSent[ssid] {
                self.delegate?.didLooseIes(lostNode)
                self.lastSent[ssid] = nil
            }
        }
    }
}

extension HubBeaconScanner: VeeaHubDiscoveryManager.Delegate {
    
    func iesListUpdated(iesList: [VeeaHubConnection]) {
        self.iesCacheLastUpdate = Date()
        self.iesCache = iesList
    }
}
