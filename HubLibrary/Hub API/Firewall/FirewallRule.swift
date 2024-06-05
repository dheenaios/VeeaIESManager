//
//  FirewallRule.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 14/05/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation


/// This class describes a firewall rule or type ACCEPT, DROP, and FORWARD
public class FirewallRule {
    
    // MARK: - Enums
    public enum FirewallRuleUpdateState {
        case CURRENT    // The rule has not been changed since it was fetched from the firewall
        case NEW        // The rule has just been created. Send to create API
        case NEW_DELETED// A new rule that has not been uploaded but has been deleted
        case DELETE     // The rule should be deleted. Send to delete API
        case UPDATE     // The rule has been upddated locally and needs to be sent to the update API
        
        var updateState: String? {
            switch self {
            case .CURRENT:
                return nil
            case .NEW:
                return "New rule"
            case .NEW_DELETED:
                return "To be deleted"
            case .DELETE:
                return "To be deleted"
            case .UPDATE:
                return "Updated"
            }
        }
    }

    public enum NetworkProtocol {
        case UDP, TCP, ICMP, ALL

        static func protocolFromString(protocolString: String) -> NetworkProtocol {
            switch protocolString {
            case "all":
                return .ALL
            case "udp":
                return .UDP
            case "icmp":
                return .ICMP
            default:
                return .TCP
            }
        }
    }

    public enum FirewallRuleActionType {
        case ACCEPT
        case DROP
        case FORWARD
        
        func getActionTypeAsString() -> String {
            switch self {
            case .DROP:
                return "drop"
            case .FORWARD:
                return "forward"
            default:
                return "accept"
            }
        }
    }
    
    public var originalJson: JSON?
    
    // MARK: - JSON Keys
    
    internal let idKey = "id"
    internal let actionKey = "action"
    internal let protocolKey = "protocol"
    internal let portKey = "port"
    internal let localPortKey = "localport"
    internal let sourceKey = "source"
    internal let localIpKey = "localip"
    internal let uriKey = "uri"
    internal let urlKey = "url"
    
    private let uriPrefix = "https://localhost:21300/firewall/api/v1.0/"
    
    // MARK: - Action Type Descriptions
    
    private let acceptAction = "accept";
    private let dropAction = "drop";
    private let forwardAction = "forward";
    
    // MARK: - Globals]
    
    /// numeric ID used in URL, e.g. https://10.0.156.50:21300/firewall/api/v1.0/rule/1
    /// If using the MAS API, you need to create this.
    /// If using the HUB API, this will be set for you
    public private(set) var ruleID: Int?
    
    /// Action can be ‘drop’, ‘accept’, and probably ‘forward’.
    public var ruleActionType: FirewallRuleActionType?
    
    public var actionTypeDescription: String? {
        get {
            guard let action = ruleActionType else {
                return nil
            }
        
            return action.getActionTypeAsString()
        }
        set {
            switch newValue {
            case acceptAction:
                ruleActionType = .ACCEPT
                break
            case dropAction:
                ruleActionType = .DROP
                break
            case forwardAction:
                ruleActionType = .FORWARD
                break
            default:
                break
            }
        }
    }

    public var networkProtocol: NetworkProtocol? {
        guard let protocolString = mProtocol else {
            return nil
        }

        return NetworkProtocol.protocolFromString(protocolString: protocolString)
    }
    
    /// Protocol can be ‘all’, ‘tcp’, ‘udp’, ‘icmp’ or numeric
    public var mProtocol: String?
    
    /// Rule URI
    public private(set) var mURI: String?
    
    /// Port can be numeric, numeric string or to provide a range of ports a string as <lower number>:<upper number>
    public var mPort: String?
    
    /// The source IP. Also acts as local IP for Forwarding rules
    public var mSource: String?
    
    /// Local port for forwarding
    public var mLocalPort: String?
    
    /// Is the rule valid
    public var isValid: Bool {
        get {
            // TODO: Add validation
            
            return true
        }
    }
    
    ///Current state of the rule
    public var mUpdateState: FirewallRuleUpdateState? {
        get {
            return _updateState
        }
        set {
            if _updateState == .NEW {
                if newValue == .DELETE {
                    _updateState = .NEW_DELETED
                    return
                }
                
                if newValue == .UPDATE {
                    return
                }
            }
            
            _updateState = newValue
        }
    }
    
    // Backing variable for mUpdateState
    private var _updateState: FirewallRuleUpdateState?
    
    internal var json: JSON {
        get {
            if ruleActionType == .FORWARD {
                return forwardJSON()
            }

            return acceptDenyJSON()
        }
    }
    
    /// Forward JSON for the Hub API
    private func forwardJSON() -> JSON {
        var json = JSON()
        if let originalJson = originalJson {
            json = originalJson
        }
        else { // This is a new rule, create the extra items needed by the MAS API
            json[idKey] = ruleID
            json[uriKey] = "\(uriPrefix)fwdrule/\(ruleID!)"
        }
        
        if mUpdateState == .NEW {
            json[actionKey] = actionTypeDescription
        }
        
        let source = mSource?.count == 0 ? "0.0.0.0/0" : mSource
        
        json[protocolKey] = mProtocol
        json[portKey] = portInfoForProtocol() // Remote Port if forwarding rule
        json[localIpKey] = source
        json[localPortKey] = mLocalPort

        return json;
    }
    
    /// Accept Deny JSON for the Hub API
    private func acceptDenyJSON() -> JSON {
        var json = JSON()
        if let originalJson = originalJson {
            json = originalJson
        }
        else { // This is a new rule, create the extra items needed by the MAS API
            json[idKey] = ruleID
            json[uriKey] = "\(uriPrefix)rule/\(ruleID!)"
        }
        
        if mUpdateState == .NEW {
            json[actionKey] = actionTypeDescription
        }

        json[protocolKey] = mProtocol
        json[portKey] = portInfoForProtocol() // Remote Port if forwarding rule
        
        let source = mSource?.count == 0 ? "0.0.0.0/0" : mSource
        json[sourceKey] = source
        
        return json;
    }
    
    func portInfoForProtocol() -> String {
        guard let port = mPort else {
            return ""
        }
        
        return port
    }
    
    public func ruleDescription() -> String {
        let description = "Firewall Rule: \(String(describing: ruleID)) \r Action Type: \(String(describing: ruleActionType)) \r Protocol: \(String(describing: mProtocol)) \r URI: \(String(describing: mURI)) \r Port: \(String(describing: mPort)) \r Local Port \(String(describing: mLocalPort)) \r State: \(String(describing: mUpdateState)) \r Source: \(String(describing: mSource))"
        return description
    }
    
    // MARK: - Init
    
    
    /// The ID of the rule being created. If being created for the hub API this can be nil
    /// - Parameter id: ID being create
    public init(with id: Int?) {
        if let idInt = id {
            ruleID = idInt
        }
        else {
            ruleID = 0
        }
        
        ruleActionType = .ACCEPT
        mProtocol = "tcp"
        mPort = ""
        mLocalPort = ""
        mSource = ""
        _updateState = FirewallRuleUpdateState.NEW
    }
    
    init(json: JSON) {
        originalJson = json
        
        if let ip = json[sourceKey] as? String {
            mSource = ip
        }
        
        mURI = json[uriKey] as? String
        
        // Some work arounds for the differences in the MAS and Hub APIs
        if let ruleId = json[idKey] as? Int {
            ruleID = ruleId
        }
        else {
            if let ruleIDString = idFromURI(uri: mURI) {
                ruleID = Int(ruleIDString) ?? 0
            }
            
            // If there is no URI then were getting json from MAS. Look for the URL
            if ruleID == nil {
                if let url = json[urlKey] as? String {
                    if let ruleIDString = idFromURI(uri: url) {
                        ruleID = Int(ruleIDString) ?? 0
                    }
                }
            }
        }
        
        mProtocol = json[protocolKey] as? String
        mPort = json[portKey] as? String
        
        setActionFromDescription(action: json[actionKey] as? String)
        if ruleActionType == FirewallRuleActionType.FORWARD {
            populateForwardRule(ruleJSON: json)
        }
        
        mUpdateState = FirewallRuleUpdateState.CURRENT
    }
    
    private func populateForwardRule(ruleJSON: JSON) {
        mLocalPort = ruleJSON[localPortKey] as? String
        
        if let ip = ruleJSON[localIpKey] as? String {
            mSource = ip
        }
    }
    
    private func setActionFromDescription(action: String?) {
        switch action {
        case forwardAction:
            ruleActionType = FirewallRuleActionType.FORWARD
            break
        case dropAction:
            ruleActionType = FirewallRuleActionType.DROP
            break
        case acceptAction:
            ruleActionType = FirewallRuleActionType.ACCEPT
            break
        default:
            break
        }
    }
    
    private func idFromURI(uri: String?) -> String? {
        guard let uri = uri else {
            return nil
        }
        
        let url = URL(string: uri)
        let componenets = url?.pathComponents
        
        return componenets?.last
    }
}

// MARK: - Port helpers
extension FirewallRule {
    var startPort: String {
        guard let p = ports else { return "" }
        
        return p.first ?? ""
    }
    
    // If there is a range
    var endString: String? {
        guard let p = ports else { return nil }
        if p.count < 2 { return nil }
        
        return p[1]
    }
    
    var portRangeDescription: String {
        guard let endString = endString else {
            return startPort
        }
        
        return startPort + " to " + endString
    }
    
    
    /// Set a port range
    /// - Parameters:
    ///   - start: The first port
    ///   - end: The last port if there is a range. Nil if no range
    func setPortRange(start: String, end: String?) {
        guard let end = end else {
            mPort = start
            return
        }
        
        mPort = "\(start):\(end)"
    }
    
    private var ports: [String]? {
        guard let p = mPort else { return nil }
        return p.components(separatedBy: ":")
    }
}
