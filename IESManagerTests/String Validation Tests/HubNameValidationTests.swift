//
//  NameValidationTest.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 02/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class NameValidationTests: XCTestCase {

    func test_valid1() {
        if let result = NameValidation.hubNameHasErrors(name: "Living_Room") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_valid2() {
        if let result = NameValidation.hubNameHasErrors(name: "Living_Room123") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_valid3() {
        if let result = NameValidation.hubNameHasErrors(name: "t") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_valid4() {
        if let result = NameValidation.hubNameHasErrors(name: "t1234") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_invalid1() {
        if let result = NameValidation.hubNameHasErrors(name: "t ^&*^*") {
            XCTAssert(true, result)
            return
        }
        
        XCTAssert(false, "Special Chars should not be accepted")
    }
    
    func test_invalid2() {
        if let result = NameValidation.hubNameHasErrors(name: "") {
            XCTAssert(true, result)
            return
        }
        
        XCTAssert(false, "Empty strings should not be accepted")
    }
    
    func test_invalid3() {
        
        if let result = NameValidation.hubNameHasErrors(name: "1234567890123456789012345678901234567890") {
            XCTAssert(true, result)
            return
        }
        
        XCTAssert(false, ">32 chars should not be accepted")
    }
}
