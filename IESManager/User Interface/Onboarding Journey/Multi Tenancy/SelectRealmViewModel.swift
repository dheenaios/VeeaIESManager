//
//  SelectRealmViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 07/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

class SelectRealmViewModel {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var usersRealmsCount: Int {
        return appDelegate.realmManager.allKnownRealms.count
    }
    
    func selectedRealm(at index: Int) -> VeeaRealmsManager.RealmDetails {
        if index > usersRealmsCount {
            return appDelegate.realmManager.allKnownRealms[0]
        }
        
        return appDelegate.realmManager.allKnownRealms[index]
    }
}
