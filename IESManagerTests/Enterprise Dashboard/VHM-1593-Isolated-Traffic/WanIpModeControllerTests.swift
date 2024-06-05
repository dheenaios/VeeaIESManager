//
//  WanIpModeControllerTests.swift
//  IESManager
//
//  Created by Richard Stockdale on 01/08/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

final class WanIpModeControllerTests: XCTestCase {

    func testInitialization() {
        let controller = WanIpModeController(supportsBackpack: true,
                                             supportsIpMode: true,
                                             selectedWanMode: .ROUTED,
                                             selectedIpMode: .CLIENT)

        XCTAssert(controller.selectedWanMode == .ROUTED)
        XCTAssert(controller.selectedIpMode == .CLIENT)
        XCTAssert(controller.supportsBackpack == true)
        XCTAssert(controller.supportsIpMode == true)
    }

    func testAvailableWanModes() {
        let controllerWithoutIsolated = WanIpModeController(supportsBackpack: false,
                                                            supportsIpMode: true,
                                                            selectedWanMode: .ROUTED,
                                                            selectedIpMode: .CLIENT)
        XCTAssertFalse(controllerWithoutIsolated.availableWanModes.contains(.ISOLATED))

        let controllerWithIsolated = WanIpModeController(supportsBackpack: true,
                                                         supportsIpMode: true,
                                                         selectedWanMode: .ROUTED,
                                                         selectedIpMode: .CLIENT)
        XCTAssertTrue(controllerWithIsolated.availableWanModes.contains(.ISOLATED))
    }

    func testIpManagementHidden() {
        let controller = WanIpModeController(supportsBackpack: true,
                                             supportsIpMode: false,
                                             selectedWanMode: .ROUTED,
                                             selectedIpMode: .CLIENT)
        XCTAssertTrue(controller.ipManagementHidden)
    }

    func testUpdateForNewLan() {
        let controller = WanIpModeController(supportsBackpack: true,
                                             supportsIpMode: true,
                                             selectedWanMode: .ROUTED,
                                             selectedIpMode: .CLIENT)

        controller.updateForNewLan(selectedWanMode: .BRIDGED,
                                   selectedIpMode: .SERVER)

        XCTAssert(controller.selectedWanMode == .BRIDGED)
        XCTAssert(controller.selectedIpMode == .SERVER)
    }
}
