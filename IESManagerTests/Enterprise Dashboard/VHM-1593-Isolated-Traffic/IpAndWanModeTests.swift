//
//  IpAndWanModeTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 17/05/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

final class IpAndWanModeTests: XCTestCase {

    // MARK: - WanMode Tests

    func test_WanModeDisplayName() {
        XCTAssertEqual(WanMode.ROUTED.displayName, "Routed".localized())
        XCTAssertEqual(WanMode.BRIDGED.displayName, "Bridged".localized())
        XCTAssertEqual(WanMode.ISOLATED.displayName, "Isolated".localized())
    }

    func test_WanModeDefaultIpManagementMode() {
        XCTAssertEqual(WanMode.ROUTED.defaultIpManagementMode, IpManagementMode.SERVER)
        XCTAssertEqual(WanMode.BRIDGED.defaultIpManagementMode, IpManagementMode.CLIENT)
        XCTAssertEqual(WanMode.ISOLATED.defaultIpManagementMode, IpManagementMode.CLIENT)
    }

    func test_RawValues() {
        XCTAssertEqual(WanMode.ROUTED.rawValue, "rt")
        XCTAssertEqual(WanMode.BRIDGED.rawValue, "br")
        XCTAssertEqual(WanMode.ISOLATED.rawValue, "isolated")
    }

    
    func test_IpManagementModesForHasRw() {
        var wanMode = WanMode.ROUTED
        var result = wanMode.ipManagementModesFor(hasRw: true, hasRo: false)
        XCTAssertFalse(result.isEmpty, "The result should not be empty for read-write mode.")
        XCTAssertFalse(result.count != 2, "The result should have two elements")
        XCTAssertTrue(result.contains(where: { $0 == .SERVER }))
        XCTAssertTrue(result.contains(where: { $0 == .STATIC }))
        
        wanMode = WanMode.BRIDGED
        result = wanMode.ipManagementModesFor(hasRw: true, hasRo: false)
        XCTAssertFalse(result.isEmpty, "The result should not be empty for read-write mode.")
        XCTAssertFalse(result.count != 2, "The result should have two elements")
        XCTAssertTrue(result.contains(where: { $0 == .CLIENT }))
        XCTAssertTrue(result.contains(where: { $0 == .STATIC }))
        
        wanMode = WanMode.ISOLATED
        result = wanMode.ipManagementModesFor(hasRw: true, hasRo: false)
        XCTAssertFalse(result.isEmpty, "The result should not be empty for read-write mode.")
        XCTAssertFalse(result.count != 3, "The result should have three elements")
    }
    
    func test_IpManagementModesForHasRo() {
        var wanMode = WanMode.ROUTED
        var result = wanMode.ipManagementModesFor(hasRw: false, hasRo: true)
        XCTAssertFalse(result.isEmpty, "The result should not be empty for read-only mode.")
        XCTAssertFalse(result.count != 1, "The result should have one elements")
        XCTAssertTrue(result.contains(where: { $0 == .SERVER }))
        
        wanMode = WanMode.BRIDGED
        result = wanMode.ipManagementModesFor(hasRw: false, hasRo: true)
        XCTAssertFalse(result.isEmpty, "The result should not be empty for read-only mode.")
        XCTAssertFalse(result.count != 1, "The result should have one elements")
        XCTAssertTrue(result.contains(where: { $0 == .CLIENT }))
        
        wanMode = WanMode.ISOLATED
        result = wanMode.ipManagementModesFor(hasRw: false, hasRo: true)
        XCTAssertFalse(result.isEmpty, "The result should not be empty for read-only mode.")
        XCTAssertFalse(result.count != 2, "The result should have two elements")
        XCTAssertTrue(result.contains(where: { $0 == .CLIENT }))
        XCTAssertTrue(result.contains(where: { $0 == .STATIC }))
    }
    
    func test_IpManagementModesForNeither() {
        var wanMode = WanMode.ROUTED
        var result = wanMode.ipManagementModesFor(hasRw: false, hasRo: false)
        XCTAssertTrue(result.isEmpty, "The result should be empty if neither read-write nor read-only is specified.")
        
        wanMode = WanMode.BRIDGED
        result = wanMode.ipManagementModesFor(hasRw: false, hasRo: false)
        XCTAssertTrue(result.isEmpty, "The result should be empty if neither read-write nor read-only is specified.")
        
        wanMode = WanMode.ISOLATED
        result = wanMode.ipManagementModesFor(hasRw: false, hasRo: false)
        XCTAssertTrue(result.isEmpty, "The result should be empty if neither read-write nor read-only is specified.")
    }


    // MARK: - IpManagementMode Tests

    func test_IpManagementModeDisplayText() {
        XCTAssertEqual(IpManagementMode.CLIENT.displayText, "Client")
        XCTAssertEqual(IpManagementMode.SERVER.displayText, "Server")
        XCTAssertEqual(IpManagementMode.STATIC.displayText, "Static")
    }

    func test_IpManagementModeAvailableIpModesForReadOnly() {
        XCTAssertEqual(IpManagementMode.availableIpModesForReadOnly(wanMode: WanMode.ROUTED), [IpManagementMode.SERVER])
        XCTAssertEqual(IpManagementMode.availableIpModesForReadOnly(wanMode: WanMode.BRIDGED), [IpManagementMode.CLIENT])
        XCTAssertEqual(IpManagementMode.availableIpModesForReadOnly(wanMode: WanMode.ISOLATED), [IpManagementMode.CLIENT, IpManagementMode.STATIC])
    }

    func test_IpManagementModeAvailableIpModesForReadWrite() {
        XCTAssertEqual(IpManagementMode.availableIpModesForReadWrite(wanMode: WanMode.ROUTED), [IpManagementMode.SERVER, IpManagementMode.STATIC])
        XCTAssertEqual(IpManagementMode.availableIpModesForReadWrite(wanMode: WanMode.BRIDGED), [IpManagementMode.CLIENT, IpManagementMode.STATIC])
        XCTAssertEqual(IpManagementMode.availableIpModesForReadWrite(wanMode: WanMode.ISOLATED), IpManagementMode.allCases)
    }

}
