//
//  SecurityRuleCreateEditViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 31/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

class SecurityRuleCreateEditViewModel: HomeUserBaseViewModel {
    
    var rule: FirewallRule?
    var newId: Int?
    
    enum Mode {
        case new
        case editing
    }
    
    private(set) var mode: Mode!
    
    enum ActionType: Int {
        case accept
        case denyDrop
        case forward
        
        private static let acceptText = "Accept connection".localized()
        private static let denyText = "Deny / Drop Connection".localized()
        private static let forwardText = "Forward Port".localized()
        
        static var optionText = [ActionType.acceptText,
                                 ActionType.denyText,
                                 ActionType.forwardText]
        
        var description: String {
            switch self {
            case .accept:
                return ActionType.acceptText
            case .denyDrop:
                return ActionType.denyText
            case .forward:
                return ActionType.forwardText
            }
        }
        
        var equivelentFirewallActionType: FirewallRule.FirewallRuleActionType {
            switch self {
            case .accept:
                return FirewallRule.FirewallRuleActionType.ACCEPT
            case .denyDrop:
                return FirewallRule.FirewallRuleActionType.DROP
            case .forward:
                return FirewallRule.FirewallRuleActionType.FORWARD
            }
        }
    }
    
    enum ProtocolType: Int {
        case both
        case tcp
        case udp
        
        private static let bothText = "Both".localized()
        private static let tcpText = "TCP".localized()
        private static let udpText = "UDP".localized()
        
        static var optionText = [ProtocolType.bothText,
                                 ProtocolType.tcpText,
                                 ProtocolType.udpText]
        
        var description: String {
            switch self {
            case .both:
                return ProtocolType.bothText
            case .tcp:
                return ProtocolType.tcpText
            case .udp:
                return ProtocolType.udpText
            }
        }
        
        var stringValueForSending: String {
            switch self {
            case .both:
                return "all"
            case .tcp:
                return "tcp"
            case .udp:
                return "upd"
            }
        }
    }
    
    func populate() {
        if let rule = rule {
            mode = .editing
            showEndPort = !(rule.endString == nil)
        }
        else if let newId = newId {
            mode = .new
            rule = FirewallRule(with: newId)
            showEndPort = false
        }
        
        setInitialRuleActions(rule: rule!)
        setInitialRuleProtocol(rule: rule!)
        
        if rule == nil && newId == nil {
            assertionFailure("No rule or rule ID added")
        }
    }
    
    var actionTimePanelActive: Bool {
        return mode == .new
    }
    
    var selectedActiontype: ActionType = .accept
    var selectedProtocolType: ProtocolType = .both
    
    var cidrText: String {
        return rule!.mSource ?? ""
    }
    
    // MARK: - Ports
    var showEndPort = false
    
    var showDestinationPort: Bool {
        return selectedActiontype == .forward
    }
    
    var startPortText: String {
        return rule!.startPort
    }
    
    var endPortText: String {
        return rule!.endString ?? ""
        
        // TODO: Need to split this to cover ranges
    }
    
    /// Only use for fwd rules
    var destinationPortText: String? {
        return rule!.mLocalPort
    }
    
    var doneButtonText: String {
        if mode == .new {
            return "Add Rule".localized()
        }
        else {
            return "Edit Rule".localized()
        }
    }
    
    var showDelete: Bool {
        return mode == .editing
    }
    
    var validationIssues: String? {
        if let error = AddressAndPortValidation.validateRule(rule: rule!) {
            
            // We have a naming confict.
            let changed = error.replacingOccurrences(of: "Local Port", with: "Destination Port")
            
            return changed
        }
        
        return nil
    }
    
    private func setInitialRuleActions(rule: FirewallRule) {
        switch rule.ruleActionType {
        case .ACCEPT:
            selectedActiontype = .accept
            break
        case .none:
            selectedActiontype = .accept
            break
        case .DROP:
            selectedActiontype = .denyDrop
            break
        case .FORWARD:
            selectedActiontype = .forward
            break
        }
    }
    
    private func setInitialRuleProtocol(rule: FirewallRule) {
        // ‘all’, ‘tcp’, ‘udp’
        
        switch rule.mProtocol {
        case "all":
            selectedProtocolType = .both
            break
        case "tcp":
            selectedProtocolType = .tcp
            break
        case "udp":
            selectedProtocolType = .udp
            break
        default:
            assertionFailure("Unexpect protocol type \(rule.mProtocol ?? "None")")
        }
    }
}
