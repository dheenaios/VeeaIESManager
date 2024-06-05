//
//  ColorTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 15/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest

class ColorTests: XCTestCase {

    var colorManager: ColorManager?
    
    override func setUpWithError() throws {
        if let colorManager = ColorManager.newInstanceFailing() {
            self.colorManager = colorManager
        }
        else {
            self.colorManager = nil
        }
    }

    func test_color_load() {
        // setUpWithError should create the color manager. If its not there,
        // then this test is in error
        if colorManager != nil {
            XCTAssert(true, "Color Manager is loaded")
        }
        else {
            XCTAssert(false, "Color Manager was not loaded")
        }
    }

}
