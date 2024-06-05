//
//  VHM-1346-Mesh-Channel-Display.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 04/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class VHM_1346_Mesh_Channel_Display_5GhzAP: XCTestCase {

    let noMeshSnapshotName = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    let meshSnapshotName = "VHM-1346-tests.json"
    
    var snapshotLoader: SnapshotLoader!
    
    // Does not have vmesh cap present
    var noAp2MeshSnapshot: ConfigurationSnapShot!
    
    // Snapshot set up for all other tests
    var ap2MeshSnapshot: ConfigurationSnapShot!
    
    var vm: APRadioConfigTableViewModel!
    var hdm: HubDataModel!
    
    private func setDataModelForSnapshot(snapshot: ConfigurationSnapShot) {
        HubDataModel.shared.configurationSnapShotItem = snapshot
        HubDataModel.shared.snapShotInUse = true
        hdm = HubDataModel.shared
    }
    
    // MARK: - SET UP AND TEAR DOWN
    override func setUpWithError() throws {
        snapshotLoader = SnapshotLoader()
        
        guard let s = snapshotLoader.getSnapshots() else {
            XCTFail("Failed to load snapshots from bundle")
            return
        }
        
        var index = snapshotLoader.fileNames.firstIndex(of: noMeshSnapshotName)
        noAp2MeshSnapshot = ConfigurationSnapShot(snapShotJson: s[index!])
        
        index = snapshotLoader.fileNames.firstIndex(of: meshSnapshotName)
        ap2MeshSnapshot = ConfigurationSnapShot(snapShotJson: s[index!])
        
        // Set the snapshot override so the app can access the snapshotConfiguration
        
        // Create a new instance of the
        vm = APRadioConfigTableViewModel()
        vm.selectedFreq = .AP2
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - 5Ghz CAPABILITY TESTS
        
    // If the vmesh capability is not present then we fall back to previous capability. In this case, we show
    func test_vmesh_cap_NOT_present() {
        setDataModelForSnapshot(snapshot: noAp2MeshSnapshot)
        
        // Set the data model
        // Remove the vmesh Capability
        for (index, cap) in hdm.baseDataModel!.nodeCapabilitiesConfig!.availableNodeCapabilities.enumerated() {

            if cap.capabilityId == "vmesh" {
                hdm.baseDataModel?.nodeCapabilitiesConfig?.availableNodeCapabilities.remove(at: index)
                break
            }
        }
        
        if let meshAvailable = hdm.baseDataModel?.nodeCapabilitiesConfig?.ap2Charateristics?.meshRadio {
            if meshAvailable {
                XCTFail("Mesh should not be available on this snapshot")
            }
        }
        
        
        let show = vm.showChannelConfigurationOption
        
        if !show {
            XCTFail("Should show the config as vmesh cap is not available")
        }
    }

    // If the vmesh capability is present, but ap mesh is not available, then show ap config
    func test_vmesh_cap_present_ap_mesh_not_available() {
        setDataModelForSnapshot(snapshot: noAp2MeshSnapshot)
        
        // Vmesh Config should be present.
        // It is present on the loaded snapshot.
        if let meshAvailable = hdm.baseDataModel?.nodeCapabilitiesConfig?.ap2Charateristics?.meshRadio {
            if meshAvailable {
                XCTFail("Mesh should not be available on this snapshot")
            }
        }
        
        let show = vm.showChannelConfigurationOption
        
        if !show {
            XCTFail("Should show the config as mesh is not available")
        }
    }
    
    // MARK: - LOCAL CONTROL + NODE STATUS
    func test_vmesh_cap_present_ap_mesh_available_local_control_state_locked() {
        setDataModelForSnapshot(snapshot: ap2MeshSnapshot)
        
        // Set mesh radio to true
        guard let meshAvailable = hdm.baseDataModel?.nodeCapabilitiesConfig?.ap2Charateristics?.meshRadio else {
            XCTFail("Mesh radio should be populated")
            return
        }
        
        if !meshAvailable {
            XCTFail("MeshAvailable should be true in this snapshot")
            return
        }
        
        hdm.baseDataModel?.vmeshConfig?.vmesh_local_control = "locked"
        let show = vm.showChannelConfigurationOption
        if !show {
            XCTFail("Should show when local control is locked")
        }
    }
    
    func test_vmesh_cap_present_ap_mesh_available_local_control_state_join() {
        setDataModelForSnapshot(snapshot: ap2MeshSnapshot)
        
        // Set mesh radio to true
        guard let meshAvailable = hdm.baseDataModel?.nodeCapabilitiesConfig?.ap2Charateristics?.meshRadio else {
            XCTFail("Mesh radio should be populated")
            return
        }
        
        if !meshAvailable {
            XCTFail("MeshAvailable should be true in this snapshot")
            return
        }
        
        hdm.baseDataModel?.vmeshConfig?.vmesh_local_control = "join"
        let show = vm.showChannelConfigurationOption
        if show {
            XCTFail("Should not show when local control is join")
        }
    }
    
    func test_vmesh_cap_present_ap_mesh_available_local_control_state_start() {
        setDataModelForSnapshot(snapshot: ap2MeshSnapshot)
        
        // Set mesh radio to true
        guard let meshAvailable = hdm.baseDataModel?.nodeCapabilitiesConfig?.ap2Charateristics?.meshRadio else {
            XCTFail("Mesh radio should be populated")
            return
        }
        
        if !meshAvailable {
            XCTFail("MeshAvailable should be true in this snapshot")
            return
        }
        
        hdm.baseDataModel?.vmeshConfig?.vmesh_local_control = "start"
        let show = vm.showChannelConfigurationOption
        if show {
            XCTFail("Should not show when local control is start")
        }
    }
    
    func test_vmesh_cap_present_ap_mesh_available_local_control_state_auto() {
        setDataModelForSnapshot(snapshot: ap2MeshSnapshot)
        
        // Set mesh radio to true
        guard let meshAvailable = hdm.baseDataModel?.nodeCapabilitiesConfig?.ap2Charateristics?.meshRadio else {
            XCTFail("Mesh radio should be populated")
            return
        }
        
        if !meshAvailable {
            XCTFail("MeshAvailable should be true in this snapshot")
            return
        }
        
        hdm.baseDataModel?.vmeshConfig?.vmesh_local_control = "auto"
        
        hdm.baseDataModel?.nodeStatusConfig?.vmesh_operating_mode = "wired-only"
        let showWiredOnly = vm.showChannelConfigurationOption
        if !showWiredOnly {
            XCTFail("Should show when vmesh_operating_mode is wired-only")
        }
        
        hdm.baseDataModel?.nodeStatusConfig?.vmesh_operating_mode = "wireless-start"
        let showWirelessStart = vm.showChannelConfigurationOption
        if showWirelessStart {
            XCTFail("Should NOT show when vmesh_operating_mode is wireless-start")
        }
        
        hdm.baseDataModel?.nodeStatusConfig?.vmesh_operating_mode = "wireless-join"
        let wirelessJoin = vm.showChannelConfigurationOption
        if wirelessJoin {
            XCTFail("Should NOT show when vmesh_operating_mode is wireless-join")
        }
    }    
}
