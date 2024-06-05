//
//  TesterMenuDataModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 22/05/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct TesterMenuDataModel {
    
    private enum TesterMenuDataModelKeys: String {
        case connectToBeaconButtonVisibleKey = "connectToBeaconButtonVisibleKey"
        case disableDestructiveOptionsKey = "disableDestructiveOptionsKey"
        case allowCountryChangeKey = "allowCountryChangeKey"
        
        var value: String {
            return self.rawValue
        }
    }
    
    // Options for the known backends. Same order as table
    //static var veeaUbBaseOptions = ["dweb.veea.co", "qa.veea.co", "dev.veeaplatform.net"]
    //static var veeaRealmOptions = ["https://auth.veea.co/auth/realms/veea", "https://qa-auth.veea.co/auth/realms/veea", "https://auth.dev.veeaplatform.net/auth/realms/veea"]
    
    //static var backendFooterText = "1. Ensure Auth URL looks like this... http://url:port/\nExample: https://10.40.16.45:8080\n2. Make sure the realm name in keycloak is set to 'veea'\n3. Set a client called 'vhm' on the keycloak server\n\n."
    
    private static let skipEnrolmentButtonVisibleKey = "skipEnrolmentButtonVisibleKey"
    
    struct UIOptions {
        @UserDefaultsBacked(key: TesterMenuDataModelKeys.disableDestructiveOptionsKey.value, defaultValue: true)
            static var disableDestructiveOptions: Bool
        
        @UserDefaultsBacked(key: TesterMenuDataModelKeys.allowCountryChangeKey.value, defaultValue: true)
            static var allowCountryChange: Bool
        
        static var connectOnlyViaBeacon: Bool {
            get { return UserSettings.connectOnlyViaBeacon }
            set { UserSettings.connectOnlyViaBeacon = newValue }
        }
    }
    
    struct VeeaBackEndOptions {
        static var connectViaMasIfHubNotConnected: Bool {
            get { return UserSettings.connectViaMasIfHubNotConnected }
            set { UserSettings.connectViaMasIfHubNotConnected = newValue }
        }
    }
    
}
