//
//  RealmTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 28/07/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class RealmTests: XCTestCase {

    let urlString = "https://qa-auth.veea.co/auth/realms/veea/veearealms/realms"

    /// Just tests that the data is sent to the test router
    func test_getDataClosure() {
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)

        let expectation = expectation(description: "RealmTests_Get mocked group call response")

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

}
