//
//  LanReservedIPsViewModelTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 09/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class LanReservedIPsViewModelTests: XCTestCase {


    let baseSnapshotFile = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"

    var snapshotLoader: SnapshotLoader!

    var baseSnapshot: ConfigurationSnapShot!

    var vm: LanReservedIPsViewModel!
    var hdm: HubDataModel!

    private func setDataModelForSnapshot(snapshot: ConfigurationSnapShot) {
        HubDataModel.shared.configurationSnapShotItem = snapshot
        HubDataModel.shared.snapShotInUse = true
        hdm = HubDataModel.shared
        vm = LanReservedIPsViewModel(parentViewModel: LanConfigurationViewModel()!)
    }

    override func setUpWithError() throws {
        snapshotLoader = SnapshotLoader()

        guard let s = snapshotLoader.getSnapshots() else {
            XCTFail("Failed to load snapshots from bundle")
            return
        }

        let index = snapshotLoader.fileNames.firstIndex(of: baseSnapshotFile)
        baseSnapshot = ConfigurationSnapShot(snapShotJson: s[index!])

        setDataModelForSnapshot(snapshot: baseSnapshot)
    }

    func test_loadedVm() {
        guard let lan1 = vm.staticIpDetails.lans.first,
              let reservation = lan1.first else {
            XCTFail("Unexpected lan 1 should be populated")
            return
        }

        let host = reservation.host
        if host != "device 1" {
            XCTFail("Unexpected device name \(name)")
        }

        let ip = reservation.ip
        if ip != "1.1.1.1" {
            XCTFail("Unexpected ip \(ip)")
        }
    }

    func test_validIpAgainstDhcpLan1() {
        let result = LanReservedIPsViewModel.validateAgainstDHCPSettings(hostIpAddress: "10.100.1.56", lanNumber: 0)

        if !result.isEmpty {
            XCTFail("This should be valid \(result)")
        }
    }

    func test_invalidIpAgainstDhcpLan1() {
        let result = LanReservedIPsViewModel.validateAgainstDHCPSettings(hostIpAddress: "1.1.1.1", lanNumber: 0)

        if result.isEmpty {
            XCTFail("This should be invalid")
        }
    }

    func test_hostIpIsValid() {
        let valid = LanReservedIPsViewModel.hostIPIsValid(hostIpAddress: "10.100.1.56", lanNumber: 0)

        if !valid {
            XCTFail("This should be valid")
        }

    }

    func test_hostIpIsInvalid() {
        let valid = LanReservedIPsViewModel.hostIPIsValid(hostIpAddress: "1.1.1.1", lanNumber: 0)

        if valid {
            XCTFail("This should be invalid")
        }
    }
}
