//
//  CellularDataStats.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 10/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class CellularDataStatsTests: XCTestCase {

    let snapshotFile = "2021-11-03T11-39-56.942 - Snapshot for MAS Connection to Hub ID 6200.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var hdm: HubDataModel!
    var vm: SdWanCellularStatsViewModel!

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

        self.vm = SdWanCellularStatsViewModel()
    }


    func test_rows() {
        if self.vm.bytesSent.count != 4 {
            XCTFail("Should be 4 rows")
        }

        if self.vm.bytesReceived.count != 4 {
            XCTFail("Should be 4 rows")
        }

        if self.vm.billing.count != 0 {
            XCTFail("Should be 0 rows")
        }
    }

    func test_bytesSent() {
        let row0 = self.vm.bytesSent[0]
        if row0.mTitle != "Today" {
            XCTFail("Wrong title")
        }
        if row0.value != "11.3 MB" {
            XCTFail("Wrong value")
        }

        let row1 = self.vm.bytesSent[1]
        if row1.mTitle != "Yesterday" {
            XCTFail("Wrong title")
        }
        if row1.value != "255.6 MB" {
            XCTFail("Wrong value")
        }

        let row2 = self.vm.bytesSent[2]
        if row2.mTitle != "This month" {
            XCTFail("Wrong title")
        }
        if row2.value != "4.38 GB" {
            XCTFail("Wrong value")
        }

        let row3 = self.vm.bytesSent[3]
        if row3.mTitle != "Last month" {
            XCTFail("Wrong title")
        }
        if row3.value != "424.9 MB" {
            XCTFail("Wrong value")
        }
    }

    func test_bytesReceived() {
        let row0 = self.vm.bytesReceived[0]
        if row0.mTitle != "Today" {
            XCTFail("Wrong title")
        }
        if row0.value != "115.3 MB" {
            XCTFail("Wrong value")
        }

        let row1 = self.vm.bytesReceived[1]
        if row1.mTitle != "Yesterday" {
            XCTFail("Wrong title")
        }
        if row1.value != "720.7 MB" {
            XCTFail("Wrong value")
        }

        let row2 = self.vm.bytesReceived[2]
        if row2.mTitle != "This month" {
            XCTFail("Wrong title")
        }
        if row2.value != "11.33 GB" {
            XCTFail("Wrong value")
        }


        let row3 = self.vm.bytesReceived[3]
        if row3.mTitle != "Last month" {
            XCTFail("Wrong title")
        }
        if row3.value != "3.59 GB" {
            XCTFail("Wrong value")
        }
    }

}
