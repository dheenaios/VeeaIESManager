//
//  NewRealmViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 07/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

class NewRealmViewModel {
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var realmManager: VeeaRealmsManager {
        return appDelegate.realmManager
    }
    
    
    /// Returns an error message if there is an issue
    /// - Parameter entry: The realm name
    /// - Returns: Error message. Nil if no issue
    func validateEntry(entry: String?) -> String? {
        guard let entry = entry else {
            return "Please enter an organization name".localized()
        }
        
        if !realmManager.isKnownRealm(realmName: entry) {
            return "Invalid organization name".localized()
        }
        
        return nil
    }
    
    /// Returns an error message if there is an issue
    /// - Parameter entry: The realm name
    /// - Returns: Error message. Nil if no issue
    func addRealmFrom(entry: String?) -> VeeaRealmsManager.RealmDetails? {
        guard let realmName = entry else {
            return nil
        }
        
        realmManager.addRealmWith(name: realmName)
        
        guard let realm = realmManager.realmDetailsFrom(realmName: realmName) else {
            return nil
        }
        
        return realm
    }
}
