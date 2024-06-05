//
//  LanTabEnabledControllerTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 15/05/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

final class LanTabEnabledControllerTests: XCTestCase {

    private struct SettingsCombination {
        internal init(_ wanMode: WanMode,
                      _ ipManagementMode: IpManagementMode,
                      _ expectedEnabled: Bool) {
            self.wanMode = wanMode
            self.ipManagementMode = ipManagementMode
            self.expectedEnabled = expectedEnabled
        }

        let wanMode: WanMode
        let ipManagementMode: IpManagementMode
        let expectedEnabled: Bool
    }

    // See VHM 1593 for rules
    private var configScreenCombinations: [SettingsCombination] {
        return [
            SettingsCombination(.ISOLATED, .SERVER, true),
            SettingsCombination(.ISOLATED, .CLIENT, true),
            SettingsCombination(.ISOLATED, .STATIC, true),

            SettingsCombination(.ROUTED, .SERVER, true),
            SettingsCombination(.ROUTED, .STATIC, true),

            SettingsCombination(.BRIDGED, .CLIENT, true),
            SettingsCombination(.BRIDGED, .STATIC, true),
        ]
    }

    private var dhcpScreenCombinations: [SettingsCombination] {
        return [
            SettingsCombination(.ISOLATED, .SERVER, false),
            SettingsCombination(.ISOLATED, .CLIENT, false),
            SettingsCombination(.ISOLATED, .STATIC, false),

            SettingsCombination(.ROUTED, .SERVER, true),
            SettingsCombination(.ROUTED, .STATIC, false),

            SettingsCombination(.BRIDGED, .CLIENT, false),
            SettingsCombination(.BRIDGED, .STATIC, false),
        ]
    }

    private var reservedIpsScreenCombinations: [SettingsCombination] {
        return [
            SettingsCombination(.ISOLATED, .SERVER, false),
            SettingsCombination(.ISOLATED, .CLIENT, false),
            SettingsCombination(.ISOLATED, .STATIC, false),

            SettingsCombination(.ROUTED, .SERVER, true),
            SettingsCombination(.ROUTED, .STATIC, false),

            SettingsCombination(.BRIDGED, .CLIENT, false),
            SettingsCombination(.BRIDGED, .STATIC, false),
        ]
    }

    private var staticIpsScreenCombinations: [SettingsCombination] {
        return [
            SettingsCombination(.ISOLATED, .SERVER, false),
            SettingsCombination(.ISOLATED, .CLIENT, false),
            SettingsCombination(.ISOLATED, .STATIC, true),

            SettingsCombination(.ROUTED, .SERVER, false),
            SettingsCombination(.ROUTED, .STATIC, true),

            SettingsCombination(.BRIDGED, .CLIENT, false),
            SettingsCombination(.BRIDGED, .STATIC, true),
        ]
    }

    // MARK: - Tests

    func test_configScreen() {
        for comb in configScreenCombinations {
            let c = LanTabEnabledController(wanMode: comb.wanMode,
                                            ipManagementMode: comb.ipManagementMode)
            XCTAssertTrue(c.configEnabled == comb.expectedEnabled)
        }
    }

    func test_dhcpScreen() {
        for comb in dhcpScreenCombinations {
            let c = LanTabEnabledController(wanMode: comb.wanMode,
                                            ipManagementMode: comb.ipManagementMode)
            XCTAssertTrue(c.lanIpEnabled == comb.expectedEnabled)
        }
    }

    func test_reservedIpsScreen() {
        for comb in reservedIpsScreenCombinations {
            let c = LanTabEnabledController(wanMode: comb.wanMode,
                                            ipManagementMode: comb.ipManagementMode)
            XCTAssertTrue(c.reservedIpsEnabled == comb.expectedEnabled)
        }
    }

//    func test_staticIpsScreen() {
//        for comb in staticIpsScreenCombinations {
//            let c = LanTabEnabledController(wanMode: comb.wanMode,
//                                            ipManagementMode: comb.ipManagementMode)
//            XCTAssertTrue(c.staticIpsEnabled == comb.expectedEnabled)
//        }
//    }
}
