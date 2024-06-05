//
//  TimeZoneSelectionTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 11/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class TimeZoneSelectionTests: XCTestCase {

    func test_Load() {
        let loader = TimeZonesLoader()
        XCTAssert(loader.jsonCountries.count == 35)
    }
}
