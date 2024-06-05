//
//  UplinkNodeSelectionViewModelTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 21/10/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

final class UplinkNodeSelectionViewModelTests: XCTestCase {

    let wdsEnabled = "Wds enabled mn.json"
    var snapshotLoader: SnapshotLoader!
    var wdsEnabledSnapshot: ConfigurationSnapShot!
    var hdm: HubDataModel!
    var inTestModel: UplinkNodeSelectionViewModel!

    override func setUpWithError() throws {
        snapshotLoader = SnapshotLoader()

        guard let s = snapshotLoader.getSnapshots() else {
            XCTFail("Failed to load snapshots from bundle")
            return
        }

        let index = snapshotLoader.fileNames.firstIndex(of: wdsEnabled)
        wdsEnabledSnapshot = ConfigurationSnapShot(snapShotJson: s[index!])
        setDataModelForSnapshot(snapshot: wdsEnabledSnapshot)
        inTestModel = UplinkNodeSelectionViewModel()

        // Mock report results
        let report1 = WdsScanReport.BssidReport(hops: 1, rank: 1, rate: 12, rssi: "", stas: 12, ul_nodes_list: ["Test"])
        let report2 = WdsScanReport.BssidReport(hops: 1, rank: 2, rate: 12, rssi: "", stas: 12, ul_nodes_list: ["Test"])
        let report3 = WdsScanReport.BssidReport(hops: 1, rank: 3, rate: 12, rssi: "", stas: 12, ul_nodes_list: ["Test"])
        let report4 = WdsScanReport.BssidReport(hops: 1, rank: 4, rate: 12, rssi: "", stas: 12, ul_nodes_list: ["Test"])
        let reports = [
            "00:76:3d:01:4e:18" : report1,
            "00:76:3d:01:51:58" : report2,
            "00:76:3d:01:4b:18" : report3,
            "00:76:3d:01:47:38" : report4

        ]
        let bssidReport: [String : WdsScanReport.BssidReport] = reports

        let report = WdsScanReport(scan_time: "1000", bssid_report: bssidReport)
        inTestModel.lastReport = report
    }

    func test_refreshButtonEnabled() {
        XCTAssertFalse(inTestModel.refreshButtonEnabled)
    }

    func test_disableApplyButton() {
        XCTAssertTrue(inTestModel.disableApplyButton)
    }

    func test_rowCount() {
        XCTAssertTrue(inTestModel.rows.count == 4)
    }

    func test_isSelectedBssid() {
        self.inTestModel.selectedBssid = "00:76:3d:01:4e:18"

        var found = false
        for item in self.inTestModel.rows {
            if self.inTestModel.isSelectedBssid(nodeBssid: item.bssid) {
                found = true
            }
        }

        XCTAssertTrue(found)
    }

    private func setDataModelForSnapshot(snapshot: ConfigurationSnapShot) {
        HubDataModel.shared.configurationSnapShotItem = snapshot
        HubDataModel.shared.snapShotInUse = true
        hdm = HubDataModel.shared
    }
}
