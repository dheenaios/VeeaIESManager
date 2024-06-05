//
//  ConnectDeviceVcTest.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 09/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager


class ConnectDeviceVcTest: XCTestCase {

    func test_correctTitle() {
        let vc = ConnectDeviceViewController()
        vc.viewDidLoad()

        let title = vc.title

        if title != "Connect VeeaHub" {
            XCTFail("Unexpected url")
        }
    }
}
