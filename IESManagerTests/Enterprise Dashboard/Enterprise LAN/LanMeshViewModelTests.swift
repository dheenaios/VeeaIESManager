//
//  LanMeshViewModelTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 09/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager


// See also... LanMeshViewModel_BackPack_Tests
class LanMeshViewModelTests: XCTestCase {

    let snapshotFile = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var hdm: HubDataModel!
    var vm: LanMeshViewModel!

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

        self.vm = LanMeshViewModel(parentViewModel: LanConfigurationViewModel()!)
    }

    // Lans info hoisted up to the parent VM.
    func test_lans() {
        let lans = vm.parentVm.meshLanConfig.lans

        if lans.count != 4 {
            XCTFail("There should be 4 lans")
        }

        let lan1 = lans.first!

        if lan1.name != "default" {
            XCTFail("This should be default")
        }

        if lan1.port_set.count != 4 {
            XCTFail("This should be 4 port sets")
        }

        if lan1.wanMode != WanMode.ROUTED {
            XCTFail("This should be rt")
        }

        if lan1.ip4_subnet != "10.100.1.0/24" {
            XCTFail("This should be 10.100.1.0/24. It is \(lan1.ip4_subnet)")
        }
    }


    func test_wanModeTappedNoBackpack() {
        let result = vm.wanModeTapped(current: .ROUTED)
        XCTAssertEqual(result, .BRIDGED)

        let result1 = vm.wanModeTapped(current: .BRIDGED)
        XCTAssertEqual(result1, .ROUTED)
    }

    func test_allPortRoles() {
        guard let portRoles = vm.allPortRoles else {
            XCTFail("No port roles")
            return
        }

        if portRoles.count != 4 {
            XCTFail("There should be 4 port roles")
        }

        for portRole in portRoles {
            let roles = portRole.roles
            if roles.count != 2 {
                XCTFail("Expecting 2 roles. Got \(roles.count)")
            }

            if portRole.roles.first != Role.WAN {
                XCTFail("Should be wan. Got \(String(describing: portRole.roles.first))")
            }

            if portRole.roles.last != Role.LAN {
                XCTFail("Should be lan. Got \(String(describing: portRole.roles.last))")
            }
        }
    }

    func test_physicalPortsAvailable() {
        if vm.physicalPortsAvailable != 4 {
            XCTFail("Expecting 4 ports available. Got \(vm.physicalPortsAvailable)")
        }
    }

    func test_clientIsolationAvailable() {
        if !vm.clientIsolationAvailable {
            XCTFail("Client isolations should not be available")
        }
    }

    func test_numberOfPorts() {
        if vm.numberOfPorts != 4 {
            XCTFail("Expecting 4 ports. Got \(vm.numberOfPorts)")
        }
    }

    func test_ipv4TextFieldUserEditableFor() {
        if !vm.ipv4TextFieldUserEditableFor(lanNumber: 0) {
            XCTFail("Expecting true")
        }

        if !vm.ipv4TextFieldUserEditableFor(lanNumber: 1) {
            XCTFail("Expecting true")
        }

        if !vm.ipv4TextFieldUserEditableFor(lanNumber: 2) {
            XCTFail("Expecting true")
        }

        if !vm.ipv4TextFieldUserEditableFor(lanNumber: 3) {
            XCTFail("Expecting true")
        }
    }

    func test_ipv4AddressFor() {
        if vm.ipv4AddressFor(lanNumber: 0) != "10.100.1.0/24" {
            XCTFail("Expecting 10.100.1.0/24. Got \(vm.ipv4AddressFor(lanNumber: 0))")
        }

        if vm.ipv4AddressFor(lanNumber: 1) != "" {
            XCTFail("Expecting empty string. Got \(vm.ipv4AddressFor(lanNumber: 1))")
        }

        if vm.ipv4AddressFor(lanNumber: 2) != "" {
            XCTFail("Expecting empty string. Got \(vm.ipv4AddressFor(lanNumber: 2))")
        }

        if vm.ipv4AddressFor(lanNumber: 3) != "" {
            XCTFail("Expecting empty string. Got \(vm.ipv4AddressFor(lanNumber: 3))")
        }
    }

    func test_numberOfAps() {
        if vm.numberOfAps != 4 {
            XCTFail("Expecting 4 APs. Got \(vm.numberOfAps)")
        }
    }

    func test_currentlySelectedLanConfig() {
        guard let current = vm.currentlySelectedLanConfig else {
            XCTFail("Should be a selected lan config")
            return
        }

        XCTAssertTrue(current.dhcp)

        if current.ip4_subnet != "10.100.1.0/24" {
            XCTFail("Subnet should be 10.100.1.0/24")
        }
    }
}
