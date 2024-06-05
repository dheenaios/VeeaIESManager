//
//  EnrollmentUnitNamingTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 11/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class EnrollmentUnitNamingModelTests: XCTestCase {

    var deviceNamingViewModel: NamingViewViewModel!
    var meshNamingViewModel: NamingViewViewModel!

    override func setUpWithError() throws {
        self.deviceNamingViewModel = NamingViewViewModel(type: .device, groupId: "12345")
        self.meshNamingViewModel = NamingViewViewModel(type: .mesh, groupId: "12345")
    }

    func test_deviceModelTests() {

        // Top level
        XCTAssert(deviceNamingViewModel.groupId == "12345")
        XCTAssert(deviceNamingViewModel.namingType == NamingViewType.device)

        // Model
        XCTAssert(deviceNamingViewModel.model.icon == "OnboardingStep3")
        XCTAssert(deviceNamingViewModel.model.vcTitle == "Name VeeaHub")
        XCTAssert(deviceNamingViewModel.model.title == "Name your VeeaHub")
        XCTAssert(deviceNamingViewModel.model.details == "A default name has been given to the VeeaHub. If you like, you can change this to something more memorable and descriptive.")
    }

    func test_meshModelTest() {

        // Top level
        XCTAssert(meshNamingViewModel.groupId == "12345")
        XCTAssert(meshNamingViewModel.namingType == NamingViewType.mesh)

        // Model
        XCTAssert(meshNamingViewModel.model.icon == "OnboardingStep5")
        XCTAssert(meshNamingViewModel.model.vcTitle == "Name Mesh")
        XCTAssert(meshNamingViewModel.model.title == "Name your mesh")
        XCTAssert(meshNamingViewModel.model.details == "Your VeeaHub operates in a \"mesh\" - a group of VeeaHubs working together. You can add more VeeaHubs to your mesh later or create a new mesh.")
    }

    func test_namingValidation() {
        XCTAssertFalse (meshNamingViewModel.checkIfFirstCharIsAlpha(textFieldText: "", string: "12345678"))
        XCTAssert(meshNamingViewModel.checkIfFirstCharIsAlpha(textFieldText: "", string: "A12345678"))
    }

    func test_nameGeneration() {
        let deviceWithSerial = deviceNamingViewModel.nameGenerator(serial: "E10CCWA080C000000740/U7R4AC6PKAHZU$")
        let deviceWithNoSerial = deviceNamingViewModel.nameGenerator(serial: nil)

        let meshWithSerial = meshNamingViewModel.nameGenerator(serial: "E10CCWA080C000000740/U7R4AC6PKAHZU$")
        let meshWithNoSerial = meshNamingViewModel.nameGenerator(serial: nil)

        // Prefix
        XCTAssert(deviceWithSerial.prefix(3) == "VH-")
        XCTAssert(deviceWithNoSerial.prefix(3) == "VH-")

        XCTAssert(meshWithSerial.prefix(6) == "VMESH-")
        XCTAssert(meshWithNoSerial.prefix(6) == "VMESH-")

        XCTAssert(deviceWithSerial.suffix(4) == "0740")
        XCTAssert(meshWithSerial.suffix(4) == "0740")
    }
}
