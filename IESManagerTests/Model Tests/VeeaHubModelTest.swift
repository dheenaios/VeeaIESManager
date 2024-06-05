//
//  VeeaHubHardwareModelTest.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 29/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

// Note need serial / QR code for 06

class VeeaHubHardwareModelTest: XCTestCase {

    /*

     This is populated by serials or by qr code test. Used in the hub enrollment process
     Note we need serial / QR code for an 06 unit

     */

    // 05 Units
    let tSerial05 = "C05BCBOOCOA000000652"
    let tQrCode05 = "V:C05BCB00C0A000000652/IWQ7SDDMOKAES$"

    // 06 Units - Made up serial and QR code
    let tSerial06 = "C06BCBOOCOA000000652"
    let tQrCode06 = "V:C06BCB00C0A000000652/IWQ7SDDMOKAES$"

    // 09 Units
    let tSerial09 = "E09CCW00C0B000001314"
    let tQrCode09 = "V:E09CCW00C0B000001314/PQRPYMJMJZANA$"

    // 10 Units
    let tSerial10 = "E10CCWA080C000000740"
    let tQrCode10 = "V:E10CCWA080C000000740/U7R4AC6PKAHZU$"

    // 25 Units
    let tSerial25 = "C25CTW00000000001539"
    let tQrCode25 = "V:C25CTW00000000001539/52F3M23UM2KUI$"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - QR Code Population

    func test_05UnitSerial() {
        // Type info
        let testType = VeeaHubHardwareModel.vhc05
        let description = "VHC05"
        let prefix = "C05"

        let model = VeeaHubHardwareModel(serial: tSerial05)

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 3 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if !canShow { XCTFail("Should be able to show bandwidth options") }

        // is 09 and is Ap2
        if model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return false") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    func test_06UnitSerial() {
        // Type info
        let testType = VeeaHubHardwareModel.vhc06
        let description = "VHC06"
        let prefix = "C06"

        let model = VeeaHubHardwareModel(serial: tSerial06)

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 4 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if !canShow { XCTFail("Should be able to show bandwidth options") }

        // is 09 and is Ap2
        if model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return false") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    func test_09UnitSerial() {
        // Type info
        let testType = VeeaHubHardwareModel.vhe09
        let description = "VHE09"
        let prefix = "E09"

        let model = VeeaHubHardwareModel(serial: tSerial09)

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 4 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if canShow { XCTFail("Should NOT be able to show bandwidth options") }

        // is 09 and is Ap2
        if !model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return true") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    func test_10UnitSerial() {
        // Type info
        let testType = VeeaHubHardwareModel.vhe10
        let description = "VHE10"
        let prefix = "E10"

        let model = VeeaHubHardwareModel(serial: tSerial10)

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 4 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if !canShow { XCTFail("Should be able to show bandwidth options") }

        // is 09 and is Ap2
        if model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return false") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    func test_25UnitSerial() {
        // Type info
        let testType = VeeaHubHardwareModel.vhc25
        let description = "VHC25"
        let prefix = "C25"

        let model = VeeaHubHardwareModel(serial: tSerial25)

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 4 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if !canShow { XCTFail("Should be able to show bandwidth options") }

        // is 09 and is Ap2
        if model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return false") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    func test_UnknownUnitSerial() {
        // Type info
        let testType = VeeaHubHardwareModel.unknown
        let description = "Unknown"
        let prefix = "SomePrefix"

        let model = VeeaHubHardwareModel(serial: "SomeSerial")

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 4 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if !canShow { XCTFail("Should be able to show bandwidth options") }

        // is 09 and is Ap2
        if model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return false") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    // MARK: - Serial Code Population

    func test_05UnitQrCode() {
        // Type info
        let testType = VeeaHubHardwareModel.vhc05
        let description = "VHC05"
        let prefix = "C05"

        let model = VeeaHubHardwareModel(qrCode: tQrCode05)

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 3 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if !canShow { XCTFail("Should be able to show bandwidth options") }

        // is 09 and is Ap2
        if model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return false") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    func test_06UnitQrCode() {
        // Type info
        let testType = VeeaHubHardwareModel.vhc06
        let description = "VHC06"
        let prefix = "C06"

        let model = VeeaHubHardwareModel(qrCode: tQrCode06)

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 4 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if !canShow { XCTFail("Should be able to show bandwidth options") }

        // is 09 and is Ap2
        if model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return false") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    func test_09UnitQrCode() {
        // Type info
        let testType = VeeaHubHardwareModel.vhe09
        let description = "VHE09"
        let prefix = "E09"

        let model = VeeaHubHardwareModel(qrCode: tQrCode09)

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 4 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if canShow { XCTFail("Should NOT be able to show bandwidth options") }

        // is 09 and is Ap2
        if !model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return true") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    func test_10UnitQrCode() {
        // Type info
        let testType = VeeaHubHardwareModel.vhe10
        let description = "VHE10"
        let prefix = "E10"

        let model = VeeaHubHardwareModel(qrCode: tQrCode10)

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 4 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if !canShow { XCTFail("Should be able to show bandwidth options") }

        // is 09 and is Ap2
        if model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return false") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    func test_25UnitQrCode() {
        // Type info
        let testType = VeeaHubHardwareModel.vhc25
        let description = "VHC25"
        let prefix = "C25"

        let model = VeeaHubHardwareModel(qrCode: tQrCode25)

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 4 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if !canShow { XCTFail("Should be able to show bandwidth options") }

        // is 09 and is Ap2
        if model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return false") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }

    func test_UnknownUnitQreCode() {
        // Type info
        let testType = VeeaHubHardwareModel.unknown
        let description = "Unknown"
        let prefix = "SomePrefix"

        let model = VeeaHubHardwareModel(serial: "SomeSerial")

        // Tests
        // Check model type
        if model != testType { XCTFail("Wrong hub type") }

        // Check model description
        if model.description != description { XCTFail("Wrong hub description") }

        // Get type
        let type = VeeaHubHardwareModel.getType(for: prefix)
        if type != testType { XCTFail("Wrong hub type from description") }

        // Expected number of Configurable SSIDs
        let numberOfSSIDs = model.numberOfUserConfigurableSsids
        if numberOfSSIDs != 4 { XCTFail("Wrong number of ssids") }

        // Can show bandwidth options
        let canShow = model.canShowBandwidthOptions
        if !canShow { XCTFail("Should be able to show bandwidth options") }

        // is 09 and is Ap2
        if model.isvhe09AndAp2(isAp2: true) { XCTFail("Should return false") }

        // is 09 and is NOT Ap2
        if model.isvhe09AndAp2(isAp2: false) { XCTFail("Should return false") }
    }
}
