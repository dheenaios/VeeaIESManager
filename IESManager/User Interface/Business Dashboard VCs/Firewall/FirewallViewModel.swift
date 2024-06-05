//
//  FirewallViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class FirewallViewModel: BaseConfigViewModel {
    
    // NOTE: You may find forward rules in accept deny and
    // vice versa as the user changes rules in the UI
    var acceptDenyRules = [FirewallRule]()
    var forwardRules = [FirewallRule]()
    
    var acceptDenyFiltered: [FirewallRule] {
        var allRules = [FirewallRule]()
        for rule in acceptDenyRules {
            if rule.mUpdateState != .DELETE && rule.mUpdateState != .NEW_DELETED {
                allRules.append(rule)
            }
        }
        
        return allRules
    }
    
    var forwardFiltered: [FirewallRule] {
        var allRules = [FirewallRule]()
        
        for rule in forwardRules {
            if rule.mUpdateState != .DELETE && rule.mUpdateState != .NEW_DELETED {
                allRules.append(rule)
            }
        }
        
        return allRules
    }
    
    func fetchRules(completion: @escaping CompletionDelegate) {
        guard let ies = connectedHub else {
            return
        }
        
        ApiFactory.get.getAllFirewallRules(connection: ies) { (rules, error) in
            guard let rules = rules else {
                completion("Error getting firewall rules".localized(), error)
                return
            }
            
            var fRules = [FirewallRule]()
            var adRules = [FirewallRule]()
            
            for rule in rules {
                if rule.ruleActionType == FirewallRule.FirewallRuleActionType.FORWARD {
                    fRules.append(rule)
                }
                else {
                    adRules.append(rule)
                }
            }
            
            self.forwardRules = fRules
            self.acceptDenyRules = adRules
            
            completion("", nil)
        }
    }
    
    /// Returns the highest value ID from the forward and rules arrays. Returns 0 if they're empty
    /// - Returns: The current highest ID value
    func getTopId() -> Int {
        var t = 0
        
        var allRules = [FirewallRule]()
        allRules.append(contentsOf: acceptDenyRules)
        allRules.append(contentsOf: forwardRules)
        
        for item in allRules {
            let id = Int(item.ruleID ?? 0)
            if id > t {
                t = id
            }
        }
        
        return t
    }
}


// MARK: - Forward Rule Validation
extension FirewallViewModel {

    func areRulePortsAreAvailable(rule: FirewallRule) -> Bool {
        let hosts = currentHostPortRecords()

        // The IP should be xxx for all of these. So there will only be one entry.
        for host in hosts {
            for ports in host.portsUsed {
                guard let mPort = rule.mPort,
                      let rulePort = Int(mPort) else {
                    return false
                }

                if rule.networkProtocol == ports.networkProtocol && rulePort == ports.port {
                    return false
                }
            }
        }

        return true
    }

    fileprivate func currentHostPortRecords() -> [HostsPortRecord] {
        var hosts = [HostsPortRecord]()
        let blankIp = "xxx" // IP not important here

        for r in acceptDenyRules {
            if r.ruleActionType == .FORWARD && r.mLocalPort != nil {
                if let ports = r.mPort {
                    if let host  = hostForIp(hosts: hosts, newIp: blankIp) {
                        host.addPorts(range: ports,
                                      networkingProtocol: r.networkProtocol)
                    }
                    else {
                        guard let networkingProtocol = r.networkProtocol else {
                            continue
                        }

                        let host = HostsPortRecord(hostIp: blankIp,
                                                   ports: ports,
                                                   networkingProtocol: networkingProtocol)
                        hosts.append(host)
                    }
                }
            }
        }

        for r in forwardRules {
            if r.ruleActionType == .FORWARD && r.mLocalPort != nil {
                if let ports = r.mPort {
                    if let host  = hostForIp(hosts: hosts, newIp: blankIp) {
                        host.addPorts(range: ports,
                                      networkingProtocol: r.networkProtocol)
                    }
                    else {
                        guard let networkingProtocol = r.networkProtocol else {
                            continue
                        }

                        let host = HostsPortRecord(hostIp: blankIp,
                                                   ports: ports,
                                                   networkingProtocol: networkingProtocol)
                        hosts.append(host)
                    }
                }
            }
        }

        return hosts

    }

    func forwardRulesHaveUniquePorts() -> Bool {

        // VHM-792: Range must be LOWER:HIGHER and the range or single port must not be the same or cover
        // any other Port or Port Range in the Forward Firwall Rules configuration
        var hosts = [HostsPortRecord]()
        let blankIp = "xxx" // IP not important here
        
        for r in acceptDenyRules {
            if r.ruleActionType == .FORWARD && r.mLocalPort != nil {
                if let ports = r.mPort {
                    if let host  = hostForIp(hosts: hosts, newIp: blankIp) {
                        let added = host.addPorts(range: ports,
                                                  networkingProtocol: r.networkProtocol)
                        if !added { return false }
                    }
                    else {
                        guard let networkingProtocol = r.networkProtocol else {
                            return false
                        }

                        let host = HostsPortRecord(hostIp: blankIp,
                                                   ports: ports,
                                                   networkingProtocol: networkingProtocol)
                        hosts.append(host)
                    }
                }
            }
        }
        
        for r in forwardRules {
            if r.ruleActionType == .FORWARD && r.mLocalPort != nil {
                if let ports = r.mPort {
                    if let host  = hostForIp(hosts: hosts, newIp: blankIp) {
                        let added = host.addPorts(range: ports,
                                                  networkingProtocol: r.networkProtocol)
                        if !added { return false }
                    }
                    else {
                        guard let networkingProtocol = r.networkProtocol else {
                            return false
                        }

                        let host = HostsPortRecord(hostIp: blankIp,
                                                   ports: ports,
                                                   networkingProtocol: networkingProtocol)
                        hosts.append(host)
                    }
                }
            }
        }
        
        return true
    }
    
    func forwardRulesHaveUniqueLocalPorts() -> Bool {
        
        // Currently only interested in forward rules having unique ids
        var localPortSet:Set<String> = []
        var count = 0
        
        for r in acceptDenyRules {
            if r.ruleActionType == .FORWARD && r.mLocalPort != nil {
                localPortSet.insert("\(r.mLocalPort!)\(r.mSource!)")
                count += 1
            }
        }
        
        for r in forwardRules {
            if r.ruleActionType == .FORWARD && r.mLocalPort != nil {
                localPortSet.insert("\(r.mLocalPort!)\(r.mSource!)")
                count += 1
            }
        }
        
        return count == localPortSet.count
    }
    
    private func hostForIp(hosts: [HostsPortRecord], newIp: String) -> HostsPortRecord? {
        for host in hosts {
            if host.hostIp == newIp {
                return host
            }
        }
        
        return nil
    }
}



/// Used to keep track of the ports used by each host
fileprivate class HostsPortRecord {

    struct UsedPortRecord {
        let port: Int
        let networkProtocol: FirewallRule.NetworkProtocol
    }

    var hostIp: String
    var portsUsed = [UsedPortRecord]()

    init(hostIp: String,
         ports: String,
         networkingProtocol: FirewallRule.NetworkProtocol) {
        self.hostIp = hostIp
        addPorts(range: ports,
                 networkingProtocol: networkingProtocol)
    }

    @discardableResult func addPorts(range: String,
                                     networkingProtocol: FirewallRule.NetworkProtocol?) -> Bool {
        guard let networkingProtocol = networkingProtocol else {
            return false
        }

        if !range.contains(":") { // Is it a single port
            if let p = Int(range) {
                return addPort(port: p, networkingProtocol: networkingProtocol)
            }

            return false
        }

        let split = range.split(separator: ":")
        if split.count != 2 { return false }
        guard let sStr = split.first, let eStr = split.last else { return false }
        guard let start = Int(sStr), let end = Int(eStr) else { return false }

        return addPortsInRange(start: start,
                               end: end,
                               networkingProtocol: networkingProtocol)
    }

    /// Add a port to the machine
    /// - Parameter port: The port the user wants to add
    /// - Returns: Returns true if the port is not in use and has been added.
    /// Returns false if the port is in use
    private func addPort(port: Int,
                         networkingProtocol: FirewallRule.NetworkProtocol) -> Bool {
        if !canAddPort(port: port,
                      networkingProtocol: networkingProtocol) {
            return false
        }

        portsUsed.append(UsedPortRecord(port: port,
                                        networkProtocol: networkingProtocol))
        return true
    }

    private func addPortsInRange(start: Int, end: Int,
                                 networkingProtocol: FirewallRule.NetworkProtocol) -> Bool {
        for port in start...end {
            if !addPort(port: port,
                        networkingProtocol: networkingProtocol) {
                return false
            }
        }

        return true
    }

    private func canAddPort(port: Int,
                            networkingProtocol: FirewallRule.NetworkProtocol) -> Bool {
        for usedPort in portsUsed {
            if port == usedPort.port &&
                networkingProtocol == usedPort.networkProtocol {
                return false
            }
        }

        return true
    }
}
