//
//  APStatusBarConfigTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 19/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class APStatusBarConfigTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Tests for each state
    func test_notConfigured() {
        let state = ApStatusBarConfig(state: .notConfigured)
        if state.text != "Not in use" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.notConfiguredIcon {
            XCTFail("Unexpected icon")
        }
        
        if state.barBackgroundColor !== state.backgroundGrey {
            XCTFail("Unexpected background color")
        }
        
        if state.iconColor !== UIColor.darkGray {
            XCTFail("Unexpected icon color")
        }
    }
    
    func test_otherInUseHub() {
        let state = ApStatusBarConfig(state: .otherInUseHub)
        
        if state.text != "Hub In Use" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.checkIcon {
            XCTFail("Unexpected icon")
        }
        
        if state.barBackgroundColor !== state.backgroundBlue {
            XCTFail("Unexpected background color")
        }
        
        if state.iconColor !== state.iconBlue {
            XCTFail("Unexpected icon color")
        }
    }
    
    func test_otherInUseMesh() {
        let state = ApStatusBarConfig(state: .otherInUseMesh)
        
        if state.text != "Network In Use" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.checkIcon {
            XCTFail("Unexpected icon")
        }
        
        if state.barBackgroundColor !== state.backgroundBlue {
            XCTFail("Unexpected background color")
        }
        
        if state.iconColor !== state.iconBlue {
            XCTFail("Unexpected icon color")
        }
    }
    
    func test_useButNotEnabled() {
        let state = ApStatusBarConfig(state: .useButNotEnabled)
        
        if state.text != "Disabled" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.lockIcon {
            XCTFail("Unexpected icon")
        }
        
        if state.barBackgroundColor !== state.backgroundOrange {
            XCTFail("Unexpected background color")
        }
        
        if state.iconColor !== state.iconOrange {
            XCTFail("Unexpected icon color")
        }
    }
    
    func test_operational() {
        let state = ApStatusBarConfig(state: .operational)
        
        if state.text != "Active" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.checkIcon {
            XCTFail("Unexpected icon")
        }
        
        if state.barBackgroundColor !== state.backgroundGreen {
            XCTFail("Unexpected background color")
        }
        
        if state.iconColor !== state.iconGreen {
            XCTFail("Unexpected icon color")
        }
    }
    
    func test_notOperational() {
        let state = ApStatusBarConfig(state: .notOperational)
        
        if state.text != "Non-Operational" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.stopIcon {
            XCTFail("Unexpected icon")
        }
        
        if state.barBackgroundColor !== state.backgroundRed {
            XCTFail("Unexpected background color")
        }
        
        if state.iconColor !== state.iconRed {
            XCTFail("Unexpected icon color")
        }
    }
    
    func test_editingNotValid() {
        let state = ApStatusBarConfig(state: .editingNotValid)
        
        if state.text != "Incomplete" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.warningInvalidIcon {
            XCTFail("Unexpected icon")
        }
        
        if state.barBackgroundColor !== state.backgroundYellow {
            XCTFail("Unexpected background color")
        }
        
        if state.iconColor !== UIColor.black {
            XCTFail("Unexpected icon color")
        }
    }
    
    func test_editingValid() {
        let state = ApStatusBarConfig(state: .editingValid)
        
        if state.text != "Changes not applied" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.needsSubmit {
            XCTFail("Unexpected icon")
        }
        
        if state.barBackgroundColor !== state.backgroundGrey {
            XCTFail("Unexpected background color")
        }
        
        if state.iconColor !== UIColor.black {
            XCTFail("Unexpected icon color")
        }
    }
}
