//
//  BasicAuth.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 25/03/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

class BasicAuth {
    public static var basicAuthID: String {
        get {
            let defaultUserName = "iesUsername"
            let beaconEncryptKey = VeeaBeacon.getBeaconEncryptKey()
            let encodedKey = "\(defaultUserName):\(beaconEncryptKey)".toBase64()
            
            return "Basic \(encodedKey)"
        }
    }
}
