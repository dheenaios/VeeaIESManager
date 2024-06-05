//
//  GuidesViewControllerTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 09/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class GuidesViewControllerTests: XCTestCase {

    func test_LoadEnterprise() {
        let vc = GuidesViewController()
        vc.homeRealm = false
        vc.loadData()

        if vc.dataSource.sections.count != 4 {
            XCTFail("Unexpected number of sections")
        }
    }

    func test_LoadHome() {
        let vc = GuidesViewController()
        vc.homeRealm = true
        vc.loadData()

        if vc.dataSource.sections.count != 3 {
            XCTFail("Unexpected number of sections")
        }
    }
}
