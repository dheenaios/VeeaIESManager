//
//  WdsSupportTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 13/07/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class WdsSupportTests: XCTestCase {

    let noWdsSupport = "2021-11-03T11-37-56.990 - Snapshot for MAS Connection to Hub ID 8466.json"
    let wdsSupportFalse = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    let wdsSupportTrue = "2021-11-03T11-39-56.942 - Snapshot for MAS Connection to Hub ID 6200.json"

    var snapshotLoader: SnapshotLoader!

    var noWdsSupportSnapshot: ConfigurationSnapShot!
    var wdsSupportFalseSnapshot: ConfigurationSnapShot!
    var wdsSupportTrueSnapshot: ConfigurationSnapShot!

    var vm: VmeshConfigViewModel!
    var hdm: HubDataModel!

    private func setDataModelForSnapshot(snapshot: ConfigurationSnapShot) {
        HubDataModel.shared.configurationSnapShotItem = snapshot
        HubDataModel.shared.snapShotInUse = true
        hdm = HubDataModel.shared
    }

    override func setUpWithError() throws {
        snapshotLoader = SnapshotLoader()

        guard let s = snapshotLoader.getSnapshots() else {
            XCTFail("Failed to load snapshots from bundle")
            return
        }

        var index = snapshotLoader.fileNames.firstIndex(of: noWdsSupport)
        noWdsSupportSnapshot = ConfigurationSnapShot(snapShotJson: s[index!])

        index = snapshotLoader.fileNames.firstIndex(of: wdsSupportFalse)
        wdsSupportFalseSnapshot = ConfigurationSnapShot(snapShotJson: s[index!])

        index = snapshotLoader.fileNames.firstIndex(of: wdsSupportTrue)
        wdsSupportTrueSnapshot = ConfigurationSnapShot(snapShotJson: s[index!])
    }

    //====================================================
    // testnoWdsSupport
    //====================================================

    func testnoWdsSupport() {
        setDataModelForSnapshot(snapshot: noWdsSupportSnapshot)
        vm = VmeshConfigViewModel()

        if vm.hasWdsSupport {
            XCTFail("Should be false")
        }

        if vm.channelSelectionReadOnly {
            XCTFail("Channel selection should be read write")
        }
    }

    func testMnNoWdsSupportWanOperationalOption() {
        setDataModelForSnapshot(snapshot: noWdsSupportSnapshot)
        vm = VmeshConfigViewModel()

        // Set to mn
        hdm.baseDataModel?.nodeConfig?.node_type = "MN"

        if !hdm.isMN {
            XCTFail("Should be an MN")
        }

        let options = VmeshConfig.WanOperationalOption.options(wdsSupport: vm.hasWdsSupport)

        let expectedOptions = [VmeshConfig.WanOperationalOption.disabled.rawValue,
                               VmeshConfig.WanOperationalOption.auto.rawValue,
                               VmeshConfig.WanOperationalOption.join.rawValue,
                               VmeshConfig.WanOperationalOption.start.rawValue]

        if options != expectedOptions {
            XCTFail("Responses not as expected")
        }
    }

    func testMenNoWdsSupportWanOperationalOption() {
        setDataModelForSnapshot(snapshot: noWdsSupportSnapshot)
        vm = VmeshConfigViewModel()

        // Set to mn
        hdm.baseDataModel?.nodeConfig?.node_type = "MEN"

        if hdm.isMN {
            XCTFail("Should be an MEN")
        }

        let options = VmeshConfig.WanOperationalOption.options(wdsSupport: vm.hasWdsSupport)

        let expectedOptions = [VmeshConfig.WanOperationalOption.disabled.rawValue,
                               VmeshConfig.WanOperationalOption.start.rawValue]

        if options != expectedOptions {
            XCTFail("Responses not as expected")
        }
    }

    //====================================================
    // testWdsSupportFalse
    //====================================================

    func testWdsSupportFalse() {
        setDataModelForSnapshot(snapshot: wdsSupportFalseSnapshot)
        vm = VmeshConfigViewModel()

        if vm.hasWdsSupport {
            XCTFail("Should be false")
        }

        if vm.channelSelectionReadOnly {
            XCTFail("Channel selection should be read write")
        }
    }

    func testMnWdsSupportFalseWanOperationalOption() {
        setDataModelForSnapshot(snapshot: wdsSupportFalseSnapshot)
        vm = VmeshConfigViewModel()

        // Set to mn
        hdm.baseDataModel?.nodeConfig?.node_type = "MN"

        if !hdm.isMN {
            XCTFail("Should be an MN")
        }

        let options = VmeshConfig.WanOperationalOption.options(wdsSupport: vm.hasWdsSupport)

        let expectedOptions = [VmeshConfig.WanOperationalOption.disabled.rawValue,
                               VmeshConfig.WanOperationalOption.auto.rawValue,
                               VmeshConfig.WanOperationalOption.join.rawValue,
                               VmeshConfig.WanOperationalOption.start.rawValue]

        if options != expectedOptions {
            XCTFail("Responses not as expected")
        }
    }

    func testMenWdsSupportFalseWanOperationalOption() {
        setDataModelForSnapshot(snapshot: wdsSupportFalseSnapshot)
        vm = VmeshConfigViewModel()

        // Set to mn
        hdm.baseDataModel?.nodeConfig?.node_type = "MEN"

        if hdm.isMN {
            XCTFail("Should be an MEN")
        }

        let options = VmeshConfig.WanOperationalOption.options(wdsSupport: vm.hasWdsSupport)

        let expectedOptions = [VmeshConfig.WanOperationalOption.disabled.rawValue,
                               VmeshConfig.WanOperationalOption.start.rawValue]

        if options != expectedOptions {
            XCTFail("Responses not as expected")
        }
    }

    //====================================================
    // testWdsSupportTrue
    //====================================================

    func testWdsSupportTrue() {
        setDataModelForSnapshot(snapshot: wdsSupportTrueSnapshot)
        vm = VmeshConfigViewModel()

        if !vm.hasWdsSupport {
            XCTFail("Should be true")
        }

        if !vm.ssidAndPasswordFieldsReadonly {
            XCTFail("Channel selection should be read only")
        }

    }

    func testMnWdsSupportTrueWanOperationalOption() {
        setDataModelForSnapshot(snapshot: wdsSupportTrueSnapshot)
        vm = VmeshConfigViewModel()

        // Set to mn
        hdm.baseDataModel?.nodeConfig?.node_type = "MN"

        if !hdm.isMN {
            XCTFail("Should be an MN")
        }

        let options = VmeshConfig.WanOperationalOption.options(wdsSupport: vm.hasWdsSupport)

        let expectedOptions = [VmeshConfig.WanOperationalOption.disabled.rawValue,
                               VmeshConfig.WanOperationalOption.join.rawValue,
                               VmeshConfig.WanOperationalOption.start.rawValue]

        if options != expectedOptions {
            XCTFail("Responses not as expected")
        }
    }

    func testMenWdsSupportTrueWanOperationalOption() {
        setDataModelForSnapshot(snapshot: wdsSupportTrueSnapshot)
        vm = VmeshConfigViewModel()

        // Set to mn
        hdm.baseDataModel?.nodeConfig?.node_type = "MEN"

        if hdm.isMN {
            XCTFail("Should be an MEN")
        }

        let options = VmeshConfig.WanOperationalOption.options(wdsSupport: vm.hasWdsSupport)

        let expectedOptions = [VmeshConfig.WanOperationalOption.disabled.rawValue,
                               VmeshConfig.WanOperationalOption.start.rawValue]

        if options != expectedOptions {
            XCTFail("Responses not as expected")
        }
    }
}
