//
//  BeaconConfigViewModelTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 11/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class BeaconConfigViewModelTests: XCTestCase {

    let snapshotFile = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var hdm: HubDataModel!
    var vm: BeaconConfigViewModel!

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

        self.vm = BeaconConfigViewModel()
    }

    func test_locked() {
        XCTAssert(self.vm.locked == false)
    }

    func test_subDomain() {
        XCTAssert(self.vm.subDomain == "235775556301.veeahub.veea.io")
    }

    func test_instanceId() {
        XCTAssert(self.vm.instanceId == "235775556301")
    }

    func test_btMacAddress() {
        XCTAssert(self.vm.btMacAddress == "88:DA:1A:B6:36:56")
    }

    func test_beaconDecryptKey() {
        XCTAssert(self.vm.beaconDecryptKey == "")
        self.vm.beaconDecryptKey = "1234567890"
        XCTAssert(self.vm.beaconDecryptKey == "1234567890")
    }
}
