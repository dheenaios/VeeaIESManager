//
//  MeshHardwareIncompatibilityT.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 22/05/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

final class MeshHardwareIncompatibilityTests: XCTestCase {

    func test_createMeshWith_vhc05_ReturnsWarningMessage() {
        let result = MeshHardwareIncompatability.createMeshWith(men: .vhc05)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.message, "If your gateway VeeaHub is a VHC05, the mesh must be built only with VHC05 VeeaHubs.")
        XCTAssertEqual(result?.totalIncompatibility, false)
    }

    func test_createMeshWith_OtherModels_ReturnsNil() {
        for model in [VeeaHubHardwareModel.vhc06, .vhe09, .vhe10, .vhc25, .vhh09, .unknown] {
            let result = MeshHardwareIncompatability.createMeshWith(men: model)
            XCTAssertNil(result)
        }
    }

    func test_add_vhe09toVhe10_ReturnsWarningMessage() {
        let result = MeshHardwareIncompatability.add(mn: .vhe10, toMenModel: .vhe09)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.message, "When using a VHE09 as a gateway with a VHE10, wireless meshing may not work.")
        XCTAssertEqual(result?.totalIncompatibility, false)
    }

    func test_add_vhc05toNonVhc05_ReturnsWarningMessage() {
        for model in [VeeaHubHardwareModel.vhc06, .vhe09, .vhe10, .vhc25, .vhh09, .unknown] {
            let result = MeshHardwareIncompatability.add(mn: model, toMenModel: .vhc05)
            XCTAssertNotNil(result)
            XCTAssertEqual(result?.message, "Your gateway VeeaHub is a VHC05. This mesh should only be extended using VHC05 VeeaHubs.")
            XCTAssertEqual(result?.totalIncompatibility, true)
        }
    }

    func test_add_OtherCombinations_ReturnsNil() {
        // Use a nested loop to test all combinations
        for menModel in VeeaHubHardwareModel.allCases {
            for mnModel in VeeaHubHardwareModel.allCases {
                if !(menModel == .vhe09 && mnModel == .vhe10) && !(menModel == .vhc05 && mnModel != .vhc05) {
                    let result = MeshHardwareIncompatability.add(mn: mnModel, toMenModel: menModel)
                    XCTAssertNil(result)
                }
            }
        }
    }
    

}
