//
//  ApStatusBarConfigUnitTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 24/08/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

final class ApStatusBarConfigUnitTests: XCTestCase {
    
    // For the purpose of this example, I'll mock these values.
    // You should provide actual values as per your environment.
    var hubIsSelected = false
    var meshProperlyConfigured = false
    var nodeApConfig = ApStatusBarConfig(state: .notConfigured) // Mock value, you should adjust it
    var hasAssociatedLan = true
    var hasBeenCleared = false
        
    let snapshotFile = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var cellModel: APConfigurationCellModel!
    
    var hdm: HubDataModel!
    
    // The below to create an instance. Not needed for anything else since we are just testing the
    // calculate method
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
        
        let nc = hdm.baseDataModel!.nodeAPConfig
        let mc = hdm.baseDataModel!.meshAPConfig
        let nApC = hdm.baseDataModel!.nodeApStatus
        
        let nodeAps = nc!.allAP1s
        let meshAps = mc!.allAP1s
        let apStats = nApC!.allAP1s
        
        // It doesnt matter what AP we use here, as we will change the details in the tests
        cellModel = APConfigurationCellModel(nodeApConfig: nodeAps.first!,
                                             meshApConfig: meshAps.first!,
                                             nodeApStatus: apStats.first!,
                                             index: 0)
    }
    
    func testPath1UseButNotEnabled() {
        hubIsSelected = true
        meshProperlyConfigured = true
        nodeApConfig = ApStatusBarConfig(state: .notConfigured)
        let state = ApStatusBarConfig(state: .notConfigured)
        let result = cellModel.calculateStatusBarConfig(meshIsEnabled: true, meshInUse: true, state: state, currentlyDisplayedSsidIsInUse: false, currentlyDisplayedSsidIsEnabled: false, currentlyDisplayedSsidIsEmpty: false, hasChanged: false, opStatus: false, isValid: false)
        XCTAssertEqual(result.state, .useButNotEnabled)
    }
    
    func testPath2NotConfigured() {
        let state = ApStatusBarConfig(state: .notConfigured)
        let result = cellModel.calculateStatusBarConfig(meshIsEnabled: false, meshInUse: false, state: state, currentlyDisplayedSsidIsInUse: true, currentlyDisplayedSsidIsEnabled: false, currentlyDisplayedSsidIsEmpty: true, hasChanged: false, opStatus: false, isValid: false)
        XCTAssertEqual(result.state, .notConfigured)
    }
    
    func testPath3UseButNotEnabledNoAccociatedLan() {
        hasAssociatedLan = false
        let state = ApStatusBarConfig(state: .notConfigured)
        let result = cellModel.calculateStatusBarConfig(meshIsEnabled: false, meshInUse: false, state: state, currentlyDisplayedSsidIsInUse: false, currentlyDisplayedSsidIsEnabled: false, currentlyDisplayedSsidIsEmpty: false, hasChanged: false, opStatus: false, isValid: false)
        XCTAssertEqual(result.state, .useButNotEnabled)
    }
    
    func testPathuseButNotEnabled() {
        let state = ApStatusBarConfig(state: .notConfigured)
        let result = cellModel.calculateStatusBarConfig(meshIsEnabled: false, meshInUse: false, state: state, currentlyDisplayedSsidIsInUse: true, currentlyDisplayedSsidIsEnabled: false, currentlyDisplayedSsidIsEmpty: false, hasChanged: false, opStatus: false, isValid: false)
        XCTAssertEqual(result.state, .useButNotEnabled)
    }
}
