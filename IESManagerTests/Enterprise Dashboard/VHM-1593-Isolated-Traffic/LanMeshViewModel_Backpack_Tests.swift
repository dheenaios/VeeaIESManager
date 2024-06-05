//
//  LanMeshViewModelTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 17/05/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class MeshLanManager_Backpack_Tests: XCTestCase {

    var snapshotLoader: SnapshotLoader!
    let snapshotName = "2023-04-27-Traffic_Isolation.json"
    var snapshot: ConfigurationSnapShot!
    var hdm: HubDataModel!
    var inTestModel: LanMeshViewModel!

    override func setUpWithError() throws {
        snapshotLoader = SnapshotLoader()

        guard let s = snapshotLoader.getSnapshots() else {
            XCTFail("Failed to load snapshots from bundle")
            return
        }

        let index = snapshotLoader.fileNames.firstIndex(of: snapshotName)
        snapshot = ConfigurationSnapShot(snapShotJson: s[index!])
        setDataModelForSnapshot(snapshot: snapshot)
        let parentViewModel = LanConfigurationViewModel()
        inTestModel = LanMeshViewModel(parentViewModel: parentViewModel!)
    }


    func test_wanModeTappedWithBackpack() {
        var result = inTestModel.wanModeTapped(current: .ROUTED)
        XCTAssertEqual(result, .BRIDGED)

        result = inTestModel.wanModeTapped(current: .BRIDGED)
        XCTAssertEqual(result, .ISOLATED)

        result = inTestModel.wanModeTapped(current: .ISOLATED)
        XCTAssertEqual(result, .ROUTED)
    }

    private func setDataModelForSnapshot(snapshot: ConfigurationSnapShot) {
        HubDataModel.shared.configurationSnapShotItem = snapshot
        HubDataModel.shared.snapShotInUse = true
        hdm = HubDataModel.shared
    }
}
