//
//  FirewallRules.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 31/01/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

/*
 
 We need to refactor the file wall rules. The API has changed and there are simplifications that can be made
 to make use of the structure returned by the API
 
 */

struct FirewallRules: ApiRequestConfigProtocol, TopLevelJSONResponse {
    
    private static let kTable = "node_firewall"
    private let kFirewall = "firewall_rules"
    private let kForward = "forward_rules"

    var originalJson: JSON {
        let firewallJson = getOriginalFirewallRules()
        let forwardJson = getOriginalForwardRules()
        
        var json = JSON()
        json[kFirewall] = firewallJson
        json[kForward] = forwardJson
        
        return json
    }
    
    var firewall_rules: [FirewallRule]
    var forward_rules: [FirewallRule]
    
    /// Until we update the architecture we need to have the original json and the changed rules in order to make the diff.
    init(updatedRules: [FirewallRule]) {
        
        // Update rules
        firewall_rules = [FirewallRule]()
        forward_rules = [FirewallRule]()
        
        for rule in updatedRules {
            if rule.ruleActionType == .FORWARD {
                forward_rules.append(rule)
            }
            else {
                firewall_rules.append(rule)
            }
        }
    }
    
    static func getTableName() -> String {
        return kTable
    }
    
    func getHubApiUpdateJSON() -> SecureUpdateJSON {
        let firewallJson = getUpdateFirewallRules()
        let forwardJson = getUpdateForwardRules()
        
        var rulesJson = JSON()
        rulesJson[kFirewall] = firewallJson
        rulesJson[kForward] = forwardJson
        
        var json = SecureUpdateJSON()
        json[FirewallRules.getTableName()] = rulesJson
        
        return json
    }
    
    
    
    func getMasUpdate() -> MasUpdate? {
        return nil // MAS will use its own methods for the moment
    }
}

// MARK: - JSON
extension FirewallRules {
    // MARK: Original json
    private func getOriginalFirewallRules() -> [JSON] {
        var json = [JSON]()
        for firewall_rule in firewall_rules {
            if let originalJson = firewall_rule.originalJson {
                json.append(originalJson)
            }
        }
        
        return json
    }
    
    private func getOriginalForwardRules() -> [JSON] {
        var json = [JSON]()
        for forward_rule in forward_rules {
            if let originalJson = forward_rule.originalJson {
                json.append(originalJson)
            }
        }
        
        return json
    }
    
    // MARK: Updated JSON
    private func getUpdateFirewallRules() -> [JSON] {
        var json = [JSON]()
        for firewall_rule in firewall_rules {
            if firewall_rule.mUpdateState != .DELETE {
                json.append(firewall_rule.json)
            }
        }
        
        return json
    }
    
    private func getUpdateForwardRules() -> [JSON] {
        var json = [JSON]()
        for forward_rule in forward_rules {
            if forward_rule.mUpdateState != .DELETE {
                json.append(forward_rule.json)
            }
        }
        
        return json
    }
}
