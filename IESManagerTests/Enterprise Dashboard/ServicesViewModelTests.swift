//
//  ServicesViewModelTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 11/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class ServicesViewModelTests: XCTestCase {

    let snapshotFile = "2021-11-03T11-38-49.808 - Snapshot for MAS Connection to Hub ID 7555.json"
    var snapshot: ConfigurationSnapShot!
    var snapshotLoader: SnapshotLoader!
    var hdm: HubDataModel!

    let urlString = "https://dweb.veea.co/enrollment/enroll/owner/baef8c7a-5f92-4852-b400-f51fda62191b/config"

    var viewModel: ServicesViewModel?

    //====================================================
    // MARK: - Testing mock loads
    //====================================================

    func test_gateDataClosure() {
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)

        let expectation = expectation(description: "Services/Subscription mocked group call response")

        URLSession.sendDataWith(request: request) { result, error in
            if let error = error {
                XCTFail("Should not be in error: \(error.localizedDescription)")
            }

            if result.data == nil {
                XCTFail("Data should not be nil")
            }

            if !result.isHttpResponseGood {
                XCTFail("HTTP response should not be nil")
            }

            if result.httpCode != 200 {
                XCTFail("HTTP code should be 200, it is \(result.httpCode)")
            }

            expectation.fulfill()

        }

        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    /// Just tests that the data is sent to the test router
    func test_getDataAsync() async throws {
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)

        do {
            let result = try await URLSession.sendDataWith(request: request)

            if result.data == nil {
                XCTFail("Data should not be nil")
            }

            if !result.isHttpResponseGood {
                XCTFail("HTTP response should not be nil")
            }

            if result.httpCode != 200 {
                XCTFail("HTTP code should be 200, it is \(result.httpCode)")
            }
        }
        catch {
            XCTFail("Should not be in error: \(error.localizedDescription)")
            throw(error)
        }
    }

    func test_createViewModel() {

        // We need a valid hub model to get the package details
        setUpHubModel()

        var updated = false
        let expectation = expectation(description: "Set up vm")

        self.viewModel = ServicesViewModel(updateHandler: {
            // Give the init time to return. With no network request happening here,
            // the closure will fire before the model is init'd
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if !updated {
                    updated = true
                    expectation.fulfill()
                }
            }
        })
        self.viewModel?.loadAvailableServices()

        waitForExpectations(timeout: 6) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    private func setUpHubModel() {
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
    }
}
