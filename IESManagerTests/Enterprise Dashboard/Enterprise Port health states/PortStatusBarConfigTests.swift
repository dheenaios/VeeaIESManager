//
//  PortStatusBarConfigTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 21/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class PortStatusBarConfigTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_otherInUseHub() {
        let state = PortStatusBarConfig(state: .otherInUseHub)
        
        if state.barBackgroundColor !== state.backgroundBlue {
            XCTFail("Unexpected background color")
        }
        if state.iconColor !== state.iconBlue {
            XCTFail("Unexpected icon color")
        }
        
        if state.text != "Hub In Use" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.checkIcon {
            XCTFail("Unexpected icon")
        }
    }
    
    func test_otherInUseMesh() {
        let state = PortStatusBarConfig(state: .otherInUseMesh)
        
        if state.barBackgroundColor !== state.backgroundBlue {
            XCTFail("Unexpected background color")
        }
        if state.iconColor !== state.iconBlue {
            XCTFail("Unexpected icon color")
        }
        
        if state.text != "Network In Use" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.checkIcon {
            XCTFail("Unexpected icon")
        }
    }
    
    func test_disabled() {
        let state = PortStatusBarConfig(state: .disabled)
        
        if state.barBackgroundColor !== state.backgroundOrange {
            XCTFail("Unexpected background color")
        }
        if state.iconColor !== state.iconOrange {
            XCTFail("Unexpected icon color")
        }
        
        if state.text != "Disabled" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.lockIcon {
            XCTFail("Unexpected icon")
        }
    }
    
    func test_notOperational() {
        let state = PortStatusBarConfig(state: .notOperational)
        
        if state.barBackgroundColor !== state.backgroundRed {
            XCTFail("Unexpected background color")
        }
        if state.iconColor !== state.iconRed {
            XCTFail("Unexpected icon color")
        }
        
        if state.text != "Non-Operational" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.stopIcon {
            XCTFail("Unexpected icon")
        }
    }
    
    func test_active() {
        let state = PortStatusBarConfig(state: .active)
        
        if state.barBackgroundColor !== state.backgroundGreen {
            XCTFail("Unexpected background color")
        }
        if state.iconColor !== state.iconGreen {
            XCTFail("Unexpected icon color")
        }
        
        if state.text != "Active" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.checkIcon {
            XCTFail("Unexpected icon")
        }
    }
    
    func test_editingNotValid() {
        let state = PortStatusBarConfig(state: .editingNotValid)
        
        if state.barBackgroundColor !== state.backgroundYellow {
            XCTFail("Unexpected background color")
        }
        if state.iconColor !== UIColor.black {
            XCTFail("Unexpected icon color")
        }
        
        if state.text != "Incomplete" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.warningInvalidIcon {
            XCTFail("Unexpected icon")
        }
    }
    
    func test_editingValid() {
        let state = PortStatusBarConfig(state: .editingValid)
        
        if state.barBackgroundColor !== state.backgroundGrey {
            XCTFail("Unexpected background color")
        }
        if state.iconColor !== UIColor.black {
            XCTFail("Unexpected icon color")
        }
        
        if state.text != "Changes not applied" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.needsSubmit {
            XCTFail("Unexpected icon")
        }
    }
    
    func test_neverUsed() {
        let state = PortStatusBarConfig(state: .neverUsed)
        
        if state.barBackgroundColor !== state.portNeverUpGrey {
            XCTFail("Unexpected background color")
        }
        if state.iconColor !== UIColor.gray {
            XCTFail("Unexpected icon color")
        }
        
        if state.text != "Never Active" {
            XCTFail("Wording not as expected")
        }
        
        if state.icon !== state.portNeverUpIcon {
            XCTFail("Unexpected icon")
        }
    }
    

}


/*
 PortConfigCell
 StatusBarConfig/PortStatusBarConfig
 
 case otherInUseMesh
 case disabled
 case notOperational
 case active
 case inactive
 case editingNotValid
 case editingValid
 case neverUsed
 
 */
