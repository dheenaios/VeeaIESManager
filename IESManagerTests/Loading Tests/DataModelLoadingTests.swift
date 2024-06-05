//
//  LoadingTests.swift
//  VeeaHub ManagerTests
//
//  Created by Richard Stockdale on 03/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

/// This set of tests loads a number of snapshots to check if the snapshot is loaded without error
class DataModelLoadingTests: XCTestCase {
    
    private enum LoadError: Error {
        case wasNull
        case expectedPropertyWasNotPresent(message: String?)
    }
    
    var snapshotLoader: SnapshotLoader!
    var snapshots: [[String : Any]]!
    
    // MARK: - SET UP AND TEAR DOWN
    override func setUp() {
        snapshotLoader = SnapshotLoader()
        
        guard let s = snapshotLoader.getSnapshots() else {
            XCTFail("Failed to load snapshots from bundle")
            return
        }
        
        self.snapshots = s
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - TESTS
    
    // MARK: Base Model
    func test_loading_base_model() {
        for (index, snapshot) in snapshots.enumerated() {
            let snapshotConfiguration = ConfigurationSnapShot(snapShotJson: snapshot)
            
            let model = snapshotConfiguration.getBaseDataModel()
            let fileName = snapshotLoader.fileNames[index]
            try XCTAssertNoThrow(baseValid(model: model, fileName: fileName))
        }
    }
    
    
    
    // MARK: Optional Model
    func test_loading_optional_model() {
        for snapshot in snapshots {
            let snapshotConfiguration = ConfigurationSnapShot(snapShotJson: snapshot)
            
            let model = snapshotConfiguration.getOptionalDataModel()
            try XCTAssertNoThrow(optionalValid(model: model))
        }
    }
}

// MARK: - Validation methods
extension DataModelLoadingTests {
    private func optionalValid(model: OptionalAppsDataModel?) throws {
        guard let model = model else {
            throw LoadError.wasNull
        }
    }
    
    private func baseValid(model: HubBaseDataModel?, fileName: String) throws {
        guard let model = model else {
            throw LoadError.wasNull
        }
        if !model.isComplete {
            throw LoadError.expectedPropertyWasNotPresent(message: "Error in snapshot: \(fileName)")
        }
    }
}
