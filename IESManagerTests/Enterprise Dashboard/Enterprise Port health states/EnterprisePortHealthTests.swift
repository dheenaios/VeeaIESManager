//
//  EnterprisePortHealthTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 21/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class EnterprisePortHealthTests: XCTestCase {
    
    let snapshotFile = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var cellModel: PortConfigCellViewModel!
    
    var hdm: HubDataModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
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
        
        guard let nodePortConfigPorts = hdm.optionalAppDetails?.nodePortConfig?.ports,
              let meshPortConfigPorts = hdm.optionalAppDetails?.meshPortConfig?.ports,
              let nodePortStatusConfigPorts = hdm.optionalAppDetails!.nodePortStatusConfig?.ports,
              let portRoles = hdm.baseDataModel?.nodeCapabilitiesConfig?.ethernetPortRoles,
              let nodePortInfoPorts = hdm.baseDataModel?.nodePortInfo?.ports,
              let netPortRoles = hdm.baseDataModel?.nodeCapabilitiesConfig?.netPortRoles else {
            assertionFailure("Missing properties")
            return
        }
        
        cellModel = PortConfigCellViewModel(nodePorts: nodePortConfigPorts.first!,
                                            meshPorts: meshPortConfigPorts.first!,
                                            portRoles: portRoles.first!,
                                            netPortRoles: netPortRoles.first,
                                            portStatus: nodePortStatusConfigPorts.first!,
                                            portInfo: nodePortInfoPorts.first!,
                                            index: 0)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // !nodeUse && !meshUse
    func test_inactive() {
        cellModel.nodePorts.use = false
        cellModel.meshPorts.use = false
        
        let portState = cellModel.getState()
        
        if portState.state != .inactive {
            XCTFail("Unexpected state")
        }
        
    }
    
    // currentlySelectedConfigHasChanged && currentSelectionIsIncomplete
    func test_editingNotValid() {
        // Set current selection is incomplete to true
        cellModel.nodePorts.role = .UNUSED
        cellModel.nodePorts.mesh = false
        
        // Set currentlySelectedConfigHasChanged to true by changing something
        cellModel.nodePorts.name = "Changed"
        
        let portState = cellModel.getState()
        
        if portState.state != .editingNotValid {
            XCTFail("Unexpected state")
        }
    }
    
    // currentlySelectedConfig.use && !currentIsEnabled
    func test_disabled() {
        cellModel.nodePorts.use = true
        cellModel.nodePorts.locked = true
        
        let portState = cellModel.getState()
        
        if portState.state != .disabled {
            XCTFail("Unexpected state")
        }
    }
    
    // sOperational && !currentlySelectedConfigHasChanged && currentlySelectedConfig.use
    func test_active() {
        let portState = cellModel.getState()
        
        if portState.state != .active {
            XCTFail("Unexpected state")
        }
    }
    
    // !isOperational && !currentlySelectedConfigHasChanged && portNeverUsed
    func test_neverUsed() {
        cellModel.portStatus.operational = false
        cellModel.portNeverUsed = true
        
        let portState = cellModel.getState()
        
        if portState.state != .neverUsed {
            XCTFail("Unexpected state")
        }
    }
    
    // !isOperational && !currentlySelectedConfigHasChanged
    func test_notOperational() {
        cellModel.portStatus.operational = false
        
        let portState = cellModel.getState()
        
        if portState.state != .notOperational {
            XCTFail("Unexpected state")
        }
    }
    
    // currentlySelectedConfigHasChanged
    func test_editingValid() {
        cellModel.nodePorts.name = "Changed"
        
        let portState = cellModel.getState()
        
        if portState.state != .editingValid {
            XCTFail("Unexpected state")
        }
    }
}
