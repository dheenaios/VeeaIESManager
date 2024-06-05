//
//  Firewall+Mas.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 24/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

// MARK: - Firewall MAS
extension FirewallRule {
    
    func getMasUpdateJson() -> JSON? {
        
        // Add some MAS specific data
        var j = json
        
        if let action = actionTypeDescription {
            j[actionKey] = action
        }
        
        let ruleId = ruleID ?? 0
        j[idKey] = ruleId
        
        if let uri = mURI {
            j[uriKey] = uri
        }
        
        return j
    }
}
