//
//  RouterViewModelTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 10/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class RouterViewModelTests: XCTestCase {

    let snapshotFile = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var hdm: HubDataModel!
    var vm: RouterViewModel!

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

        self.vm = RouterViewModel()
    }

    func test_acceptMacList() {
        XCTAssert(self.vm.acceptListChanged == false)
        self.vm.acceptMacList = ["123", "456"]
        XCTAssert(self.vm.acceptListChanged == true)
        XCTAssert(self.vm.acceptMacList!.count == 2)
    }

    func denyMacList() {
        XCTAssert(self.vm.denyListChanged == false)
        self.vm.denyMacList = ["123", "456"]
        XCTAssert(self.vm.denyListChanged == true)
        XCTAssert(self.vm.denyMacList!.count == 2)
    }

}
