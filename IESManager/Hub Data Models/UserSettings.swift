//
//  UserSettings.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 16/08/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation
import SharedBackendNetworking

fileprivate enum UserSettingKeys: String {
    case disconnectForIESSetting = "disconnectForIESSettingKey"
    case beaconEncryptionKeyValueKey = "beaconEncryptionKeyValueKey"
    case hideWeakSignalsKey = "hideWeakSignalsKey"
    case sortHubsByNameKey = "sortHubsByNameKey"
    case sortAutomaticallyKey = "sortAutomaticallyKey"
    case filterSubDomainKey = "FilterSubDomain"
    case filterInstanceKey = "FilterInstanceId"
    case connectOnlyByBeacon = "connectOnlyByBeacon"
    case connectViaMasIfHubNotConnectedKey = "connectViaMasIfHubNotConnectedKey"
    case beacons = "meshBeaconDetails"
    
    var value: String {
        return self.rawValue
    }
}

struct UserSettings {
    
    @UserDefaultsBacked(key: UserSettingKeys.disconnectForIESSetting.value, defaultValue: true)
    static var disconnectFromHubWhenDone: Bool
    
    @UserDefaultsBacked(key: UserSettingKeys.hideWeakSignalsKey.value, defaultValue: false)
    static var hideWeakSignals: Bool
    
    @UserDefaultsBacked(key: UserSettingKeys.sortHubsByNameKey.value, defaultValue: false)
    static var sortHubsByName: Bool
    
    @UserDefaultsBacked(key: UserSettingKeys.connectOnlyByBeacon.value, defaultValue: false)
    static var connectOnlyViaBeacon: Bool
    
    /// Connect to Hub via MAS even if the hub is not connected or health
    static var connectViaMasIfHubNotConnected: Bool {
        get {
            // If production always return false
            if BackEndEnvironment.internalBuild { return alwaysConnectToHubViaMas }
            return false
        }
        set { alwaysConnectToHubViaMas = newValue }
    }
    
    // Backing var for connectViaMasIfHubNotConnected. Do not use directly, always use connectViaMasIfHubNotConnected
    @UserDefaultsBacked(key: UserSettingKeys.connectViaMasIfHubNotConnectedKey.value, defaultValue: false)
    private static var alwaysConnectToHubViaMas: Bool
}

// Beacon info for test menu purposes
extension UserSettings {

    // Each mesh has an encryption key of its own
    static var beacons: [VHBeacon] {
        get {
            let storage: UserDefaults = .standard
            var beacons = [VHBeacon]()
            if let arr = storage.object(forKey: UserSettingKeys.beacons.rawValue) as? [[String : String]] {
                for dict in arr {
                    if let beacon = VHBeacon.init(dict: dict) {
                        beacons.append(beacon)
                    }
                }
            }

            return beacons
        }
        set {
            let storage: UserDefaults = .standard
            var arr = [[String : String]]()
            for beacon in newValue {
                arr.append(beacon.asDict)
            }

            storage.set(arr,
                        forKey: UserSettingKeys.beacons.rawValue)
        }
    }
}
