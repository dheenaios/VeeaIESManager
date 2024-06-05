//
//  WDSLinksViewModelTests.swift
//  IESManager
//
//  Created by Richard Stockdale on 21/10/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

final class WDSLinksViewModelTests: XCTestCase {

    let wdsEnabled = "Wds enabled mn.json"
    var snapshotLoader: SnapshotLoader!
    var wdsEnabledSnapshot: ConfigurationSnapShot!
    var hdm: HubDataModel!
    var inTestModel: WDSLinksViewModel!

    override func setUpWithError() throws {
        snapshotLoader = SnapshotLoader()

        guard let s = snapshotLoader.getSnapshots() else {
            XCTFail("Failed to load snapshots from bundle")
            return
        }

        let index = snapshotLoader.fileNames.firstIndex(of: wdsEnabled)
        wdsEnabledSnapshot = ConfigurationSnapShot(snapShotJson: s[index!])
        setDataModelForSnapshot(snapshot: wdsEnabledSnapshot)
        inTestModel = WDSLinksViewModel()
    }

    func test_nodesCount() {
        XCTAssertTrue(inTestModel.nodes.count == 5)
    }

    func test_showUpLinkDetails() {
        XCTAssertTrue(inTestModel.shownUplinkDetails)
    }

    func test_uplinkNodeName() {
        XCTAssertTrue(inTestModel.uplinkNodeName == "VH-1459")
    }

    private func setDataModelForSnapshot(snapshot: ConfigurationSnapShot) {
        HubDataModel.shared.configurationSnapShotItem = snapshot
        HubDataModel.shared.snapShotInUse = true
        hdm = HubDataModel.shared
    }
}
