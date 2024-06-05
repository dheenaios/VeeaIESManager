//
//  DhcpViewModelTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 27/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class DhcpViewModelTests: XCTestCase {

    let snapshotFile = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var hdm: HubDataModel!
    var vm: DhcpDnsViewModel!

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
        vm = DhcpDnsViewModel(parentViewModel: LanConfigurationViewModel()!)
    }

    func test_nodeLanConfigModelsCountCorrect() {
        if vm.numberOfLans != 4 {
            XCTFail("Wrong number of NodeLanConfigModels - 1")
        }

        let models = vm.nodeLanConfigModels
        if models.count != 4 {
            XCTFail("Wrong number of NodeLanConfigModels - 2")
        }
    }

    func test_meshLansConfigModelsCountCorrect() {
        let models = vm.meshLans
        if models.count != 4 {
            XCTFail("Wrong number of meshLans - 2")
        }
    }

    // Test validity of the models as per snapshot
    func test_nodeLanConfigModelValidity() {
        for (index, _) in vm.meshLans.enumerated() {
            if let errorMessages = vm.entriesHaveErrors(selectedMeshLan: vm.meshLans[index]) {
                XCTFail("Expected all to be valid: \(errorMessages)")
            }
        }
    }

    func test_NodeLanConfigModelValidityInError_startIpHigher() {
        let config = vm.nodeLanConfigModels.first
        config?.start_ip = "1.1.1.20"
        config?.end_ip = "1.1.1.2"

        guard let errorMessage = vm.entriesHaveErrors(selectedMeshLan: vm.meshLans[0]) else {
            XCTFail("Expected invalid response")
            return
        }

        if errorMessage != "LAN1 Start IP > End IP\n" {
            XCTFail("Unexpected error: \(errorMessage)")
        }
    }

    func test_NodeLanConfigModelValidityInError_outOfSubnet() {
        let config = vm.nodeLanConfigModels.first
        config?.start_ip = "1.1.1.1"
        config?.end_ip = "10.1.1.1"

        guard let errorMessage = vm.entriesHaveErrors(selectedMeshLan: vm.meshLans[0]) else {
            XCTFail("Expected invalid response")
            return
        }

        if errorMessage != "LAN1 has IPs that are not within its subnet\n" {
            XCTFail("Unexpected error: \(errorMessage)")
        }
    }

    func test_NodeLanConfigModelValidityInError_badIp() {
        let config = vm.nodeLanConfigModels.first
        config?.start_ip = "1.1.1"

        guard let errorMessage = vm.entriesHaveErrors(selectedMeshLan: vm.meshLans[0]) else {
            XCTFail("Expected invalid response")
            return
        }

        if errorMessage != "LAN1 starting IP is not a valid IP address\nLAN1 needs a ending IP address\n" {
            XCTFail("Unexpected error: \(errorMessage)")
        }
    }

    func test_NodeLanConfigModelValidityInError_endIpEmpty() {
        let config = vm.nodeLanConfigModels.first
        config?.start_ip = "1.1.1.2"

        guard let errorMessage = vm.entriesHaveErrors(selectedMeshLan: vm.meshLans[0]) else {
            XCTFail("Expected invalid response")
            return
        }

        if errorMessage != "LAN1 needs a ending IP address\n" {
            XCTFail("Unexpected error: \(errorMessage)")
        }
    }

    func test_NodeLanConfigModelValidityDns1_valid() {
        let config = vm.nodeLanConfigModels.first
        config?.dns_1 = "1.1.1.1"

        if let errorMessages = vm.entriesHaveErrors(selectedMeshLan: vm.meshLans[0]) {
            XCTFail("Expected Dns1 IP to be valid: \(errorMessages)")
        }
    }

    func test_NodeLanConfigModelValidityDns2_valid() {
        let config = vm.nodeLanConfigModels.first
        config?.dns_2 = "1.1.1.1"

        if let errorMessages = vm.entriesHaveErrors(selectedMeshLan: vm.meshLans[0]) {
            XCTFail("Expected Dns1 IP to be valid: \(errorMessages)")
        }
    }

    func test_NodeLanConfigModelValidityDns1_invalid() {
        let config = vm.nodeLanConfigModels.first
        config?.dns_1 = "1.1.1.300"

        if let errorMessages = vm.entriesHaveErrors(selectedMeshLan: vm.meshLans[0]) {
            if errorMessages == "LAN1 dns1 is not a valid IP address\n" {
                return
            }

            XCTFail("Unexpected error message: \(errorMessages)")
            return
        }

        XCTFail("Expectedly valid")
    }

    func test_NodeLanConfigModelValidityDns2_invalid() {
        let config = vm.nodeLanConfigModels.first
        config?.dns_2 = "1.1.1.300"

        if let errorMessages = vm.entriesHaveErrors(selectedMeshLan: vm.meshLans[0]) {
            if errorMessages == "LAN1 dns2 is not a valid IP address\n" {
                return
            }

            XCTFail("Unexpected error message: \(errorMessages)")
            return
        }

        XCTFail("Expectedly valid")
    }

    // MARK: - IP Management
    
    func test_ipManagementDefaults() {
        var meshLan = vm.parentVm.meshLanConfig.lan_1

        meshLan.wanMode = .ROUTED
        vm.parentVm.setMeshLan(meshLan: meshLan, for: 0)
        XCTAssertTrue(vm.parentVm.defaultIpManagementMode(lan: 0) == IpManagementMode.SERVER)

        meshLan.wanMode = .BRIDGED
        vm.parentVm.setMeshLan(meshLan: meshLan, for: 0)
        XCTAssertTrue(vm.parentVm.defaultIpManagementMode(lan: 0) == IpManagementMode.CLIENT)

        meshLan.wanMode = .ISOLATED
        vm.parentVm.setMeshLan(meshLan: meshLan, for: 0)
        XCTAssertTrue(vm.parentVm.defaultIpManagementMode(lan: 0) == IpManagementMode.CLIENT)
    }
}
