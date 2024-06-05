//
//  IPConfigViewModelTest.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 10/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class IPConfigViewModelTest: XCTestCase {

    let snapshotFile = "2021-11-03T11-39-56.942 - Snapshot for MAS Connection to Hub ID 6200.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var hdm: HubDataModel!
    var vm: IPConfigViewModel!

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

        self.vm = IPConfigViewModel()
    }

    func test_enabled() {
        XCTAssert(self.vm.enabled == true)
    }

    func test_showOnlyInternalPrefix() {
        XCTAssert(self.vm.showOnlyInternalPrefix == false)
    }

    func test_ipAddr() {
        XCTAssert(self.vm.ipAddr == "100.119.222.44")
    }

    func test_selectedGateway() {
        XCTAssert(self.vm.selectedGateway == "Cellular")
    }

    func test_delegatePrefix() {
        XCTAssert(self.vm.delegatePrefix == "10.101.0.0/16")
    }

    func test_meshAddr() {
        XCTAssert(self.vm.meshAddr == "10.101.0.1/24")
    }

    func test_pDns() {
        // TODO: Refactor
        //XCTAssert(self.vm.pDns == "")
    }

    func test_sDns() {
        // TODO: Refactor
        //XCTAssert(self.vm.sDns == "")
    }

    func test_intPrefix() {
        XCTAssert(self.vm.intPrefix == "10.102.0.0/16")
    }
}
