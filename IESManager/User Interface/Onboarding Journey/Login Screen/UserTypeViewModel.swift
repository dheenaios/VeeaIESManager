//
//  File.swift
//  IESManager
//
//  Created by Richard Stockdale on 23/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit
import SharedBackendNetworking

class UserTypeViewModel {

    // TODO: This is currently being used by the login view controller as we are
    // now using the target to decide the onboarding route. This may change.
    // Change the name if we decide the target method is the way to go

    private var maintainanceModeChecker = MaintainanceModeCheck()
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func homeUserRealm() -> VeeaRealmsManager.RealmDetails {
        
        // When the home realm is in place change the below for that realm
        return appDelegate.realmManager.allKnownRealms[0] // Will return the Veea Realm
    }

    func isInMaintainanceMode() async -> Bool {
        await maintainanceModeChecker.isInMaintainanceMode(sendMaintainaceModeNotification: true)
    }

}
