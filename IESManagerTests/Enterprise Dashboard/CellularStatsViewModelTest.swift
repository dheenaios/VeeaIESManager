//
//  CellularStatsViewModelTest.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 10/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class CellularStatsViewModelTest: XCTestCase {

    let snapshotFile = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var hdm: HubDataModel!
    var vm: CellularStatsViewModel!

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

        self.vm = CellularStatsViewModel()
    }

    func test_stats() {
        let expectation = expectation(description: "Update cell stats")
        vm.updateDataModel { stats, str in

            // Number of bars
            let bars = self.vm.numberOfBars
            if bars != 2 {
                XCTFail("Should be 2 bars - \(bars)")
            }

            // Rows
            let rows = self.vm.tableViewRows

            if rows.count != 19 {
                XCTFail("There should be 19 rows. There are \(rows)")
            }

            // Check some row values for correctness
            let row0 = rows[0]
            if row0.key != "IMEI" {
                XCTFail("Incorrect key")
            }

            if row0.value != "866758042200341" {
                XCTFail("Incorrect value")
            }

            let row14 = rows[14]
            if row14.key != "LTE Driver v." {
                XCTFail("Incorrect key")
            }

            if row14.value != "Quectel_Linux&Android_GobiNet_Driver_V1.6.1" {
                XCTFail("Incorrect value")
            }

            let row18 = rows[18]
            if row18.key != "Network Reg. Status" {
                XCTFail("Incorrect key")
            }

            if row18.value != "Registered. Roaming" {
                XCTFail("Incorrect value")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
