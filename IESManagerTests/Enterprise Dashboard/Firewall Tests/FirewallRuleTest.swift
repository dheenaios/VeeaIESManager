//
//  FirewallRuleTest.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 10/05/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class FirewallRuleTest: XCTestCase {

    // MARK: - Network Protocol Enum
    func test_networkProtocolUdp() {
        let prot = FirewallRule.NetworkProtocol.protocolFromString(protocolString: "udp")
        XCTAssertTrue(prot == .UDP)
    }

    func test_networkProtocolAll() {
        let prot = FirewallRule.NetworkProtocol.protocolFromString(protocolString: "all")
        XCTAssertTrue(prot == .ALL)
    }

    func test_networkProtocolIcmp() {
        let prot = FirewallRule.NetworkProtocol.protocolFromString(protocolString: "icmp")
        XCTAssertTrue(prot == .ICMP)
    }

    func test_networkProtocolTcp() {
        let prot = FirewallRule.NetworkProtocol.protocolFromString(protocolString: "tcp")
        XCTAssertTrue(prot == .TCP)
    }

    func test_changeState() {
        let rule = FirewallRule(with: 0)
        if rule.mUpdateState != .NEW { XCTFail() }

        // Set to current
        rule.mUpdateState = .CURRENT
        if rule.mUpdateState != .CURRENT { XCTFail() }
    }

    func test_firewallActionTypes() {
        let rule = FirewallRule(with: 0)

        // Default type should be accept
        if rule.ruleActionType != .ACCEPT { XCTFail() }
        var d = rule.ruleActionType?.getActionTypeAsString()
        if d != "accept" { XCTFail() }

        rule.ruleActionType = .DROP
        if rule.ruleActionType != .DROP { XCTFail() }
        d = rule.ruleActionType?.getActionTypeAsString()
        if d != "drop" { XCTFail() }

        rule.ruleActionType = .FORWARD
        if rule.ruleActionType != .FORWARD { XCTFail() }
        d = rule.ruleActionType?.getActionTypeAsString()
        if d != "forward" { XCTFail() }
    }

    func test_networkProtocols() {
        let rule = FirewallRule(with: 0)

        // Default should be tcp
        if rule.networkProtocol != .TCP { XCTFail() }

        rule.mProtocol = "all"
        if rule.networkProtocol != .ALL { XCTFail() }

        rule.mProtocol = "udp"
        if rule.networkProtocol != .UDP { XCTFail() }

        rule.mProtocol = "icmp"
        if rule.networkProtocol != .ICMP { XCTFail() }

        rule.mProtocol = "tcp"
        if rule.networkProtocol != .TCP { XCTFail() }
    }

    func test_networkProtocolsFromString() {

        var p = FirewallRule.NetworkProtocol.protocolFromString(protocolString: "all")
        if p != .ALL { XCTFail() }

        p = FirewallRule.NetworkProtocol.protocolFromString(protocolString: "udp")
        if p != .UDP { XCTFail() }

        p = FirewallRule.NetworkProtocol.protocolFromString(protocolString: "icmp")
        if p != .ICMP { XCTFail() }

        p = FirewallRule.NetworkProtocol.protocolFromString(protocolString: "tcp")
        if p != .TCP { XCTFail() }

        // TCP is the default
        p = FirewallRule.NetworkProtocol.protocolFromString(protocolString: "someMadness")
        if p != .TCP { XCTFail() }
    }
}
