//
//  VHM-1346-Mesh-Channel-Display-Vmesh.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 04/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class VHM_1346_Mesh_Channel_Display_Vmesh: XCTestCase {
    
    let noMeshSnapshotName = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    let meshSnapshotName = "VHM-1346-tests.json"
    
    var snapshotLoader: SnapshotLoader!
    
    // Does not have vmesh cap present
    var noVMeshSnapshot: ConfigurationSnapShot!
    
    // Snapshot set up for all other tests
    var vmeshSnapshot: ConfigurationSnapShot!
    
    var vm: VmeshConfigViewModel!
    var hdm: HubDataModel!

    private func setDataModelForSnapshot(snapshot: ConfigurationSnapShot) {
        HubDataModel.shared.configurationSnapShotItem = snapshot
        HubDataModel.shared.snapShotInUse = true
        hdm = HubDataModel.shared
        
        // This needs to be called after setting the datamodel
        vm = VmeshConfigViewModel()
    }
    
    override func setUpWithError() throws {
        snapshotLoader = SnapshotLoader()
        
        guard let s = snapshotLoader.getSnapshots() else {
            XCTFail("Failed to load snapshots from bundle")
            return
        }
        
        var index = snapshotLoader.fileNames.firstIndex(of: noMeshSnapshotName)
        noVMeshSnapshot = ConfigurationSnapShot(snapShotJson: s[index!])
        
        index = snapshotLoader.fileNames.firstIndex(of: meshSnapshotName)
        vmeshSnapshot = ConfigurationSnapShot(snapShotJson: s[index!])
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - CAPABILITY TEST
    
    func test_vmesh_cap_NOT_present() {
        setDataModelForSnapshot(snapshot: noVMeshSnapshot)
        
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
        
        
        guard let show = vm.showChannelConfigForMeshRadioAvailable else {
            XCTFail("Should show should return a value")
            return
        }
        
        if show {
            XCTFail("Should show the config as vmesh cap is not available")
        }
    }
        
    // MARK: - LOCAL CONTROL + NODE STATUS
    func test_vmesh_local_control_state_locked() {
        setDataModelForSnapshot(snapshot: vmeshSnapshot)

        hdm.baseDataModel?.vmeshConfig?.vmesh_local_control = "locked"
        guard let show = vm.showChannelConfigForMeshRadioAvailable else {
            XCTFail("Should show should return a value")
            return
        }
        if show {
            XCTFail("Should NOT show when local control is locked")
        }
        
        let readonly = vm.channelSelectionReadOnly
        if readonly {
            XCTFail("Readonly should be false")
        }
    }
    
    func test_vmesh_local_control_state_join() {
        setDataModelForSnapshot(snapshot: vmeshSnapshot)

        hdm.baseDataModel?.vmeshConfig?.vmesh_local_control = "join"
        guard let show = vm.showChannelConfigForMeshRadioAvailable else {
            XCTFail("Should show should return a value")
            return
        }
        if !show {
            XCTFail("Should show when local control is join")
        }
        
        let readonly = vm.channelSelectionReadOnly
        if !readonly {
            XCTFail("Readonly should be true")
        }
    }
    
    func test_vmesh_local_control_state_start() {
        setDataModelForSnapshot(snapshot: vmeshSnapshot)

        hdm.baseDataModel?.vmeshConfig?.vmesh_local_control = "start"
        guard let show = vm.showChannelConfigForMeshRadioAvailable else {
            XCTFail("Should show should return a value")
            return
        }
        if !show {
            XCTFail("Should show when local control is start")
        }
        
        let readonly = vm.channelSelectionReadOnly
        if readonly {
            XCTFail("Readonly should be false")
        }
    }
    
    func test_vmesh_local_control_state_auto() {
        setDataModelForSnapshot(snapshot: vmeshSnapshot)
        
        hdm.baseDataModel?.vmeshConfig?.vmesh_local_control = "auto"
        
        hdm.baseDataModel?.nodeStatusConfig?.vmesh_operating_mode = "wired-only"
        if let show = vm.showChannelConfigForMeshRadioAvailable {
            if show {
                XCTFail("Should NOT show when local control is start")
            }
            
            if vm.channelSelectionReadOnly {
                XCTFail("Readonly should be false")
            }
        }
        else {
            XCTFail("Should show should return a value")
            return
        }

        hdm.baseDataModel?.nodeStatusConfig?.vmesh_operating_mode = "wireless-start"
        if let show = vm.showChannelConfigForMeshRadioAvailable {
            if !show {
                XCTFail("Should show when local control is start")
            }
            if vm.channelSelectionReadOnly {
                XCTFail("Readonly should be false")
            }
        }
        else {
            XCTFail("Should show should return a value")
            return
        }

        
        hdm.baseDataModel?.nodeStatusConfig?.vmesh_operating_mode = "wireless-join"
        if let show = vm.showChannelConfigForMeshRadioAvailable {
            if !show {
                XCTFail("Should show when local control is start")
            }
            if !vm.channelSelectionReadOnly {
                XCTFail("Readonly should be true")
            }
        }
        else {
            XCTFail("Should show should return a value")
            return
        }
    }
}
