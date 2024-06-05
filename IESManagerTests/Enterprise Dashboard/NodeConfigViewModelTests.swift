//
//  NodeConfigViewModelTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 11/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class NodeConfigViewModelTests: XCTestCase {

    let snapshotFile = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var hdm: HubDataModel!
    var vm: NodeConfigViewModel!

    override func setUpWithError() throws {
        snapshotLoader = SnapshotLoader()

        guard let s = snapshotLoader.getSnapshots() else {
            XCTFail("Failed to load snapshots from bundle")
            return
        }

        let index = snapshotLoader.fileNames.firstIndex(of: snapshotFile)
        snapshot = ConfigurationSnapShot(snapShotJson: s[index!])

        HubDataModel.shared.configurationSnapShotItem = snapshot
        HubDataModel.shared.snapShotInUse = true
        hdm = HubDataModel.shared

        self.vm = NodeConfigViewModel()
    }

    func test_nodeName() {
        XCTAssert(self.vm.nodeName == "VH-0757")
        self.vm.nodeName = "1234"
        XCTAssert(self.vm.nodeName == "1234")
        XCTAssert(self.vm.hasConfigChanged() == true)
        self.vm.nodeName = "VH-0757"
        XCTAssert(self.vm.hasConfigChanged() == false)
    }

    func test_nodeSerial() {
        XCTAssert(self.vm.nodeSerial == "E10CCWA080C000000757")
    }

    func test_veeaHubUnitSerialNumber() {
        XCTAssert(self.vm.veeaHubUnitSerialNumber == "E10CCWA080C000000757")
    }

    func test_nodeType() {
        // "MEN"
        XCTAssert(self.vm.nodeType == "MEN")
    }

    func test_softwareVersion() {
        XCTAssert(self.vm.softwareVersion == "2.22.0-21")
    }

    func test_osVersion() {
        // "4.9.0"
        XCTAssert(self.vm.osVersion == "4.9.0")
    }

    func test_hardwareVersion() {
        XCTAssert(self.vm.hardwareVersion == "1.0")
    }

    func test_hardwareRev() {
        XCTAssert(self.vm.hardwareRev == "C")
    }

    func test_locale() {
        XCTAssert(self.vm.locale == "")
        self.vm.locale = "Home"
        XCTAssert(self.vm.hasConfigChanged() == true)
        self.vm.locale = ""
        XCTAssert(self.vm.hasConfigChanged() == false)
    }

    func test_restartTime() {
        XCTAssert(self.vm.restartTime == "2021-11-02 21:01:30")
    }

    func test_rebootRequired() {
        XCTAssert(self.vm.rebootRequired == false)
    }

    func test_lastRestartReason() {
        XCTAssert(self.vm.lastRestartReason == "CPU. Reset Requested by Button")
    }

    func test_restartRequiredReason() {
        XCTAssert(self.vm.restartRequiredReason == "No restart needed")
    }

    func test_locationText() {
        XCTAssert(self.vm.locationText == "New York, US")
    }
}
