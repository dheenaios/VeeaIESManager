//
//  SSIDNameAndPasswordValidation.swift
//  VeeaHub ManagerTests
//
//  Created by Richard Stockdale on 05/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

/// Tests relating to SSID and AP Password validation
class SSIDNameAndPasswordValidation: XCTestCase {
        
    // MARK: - SSID Name Tests
    
    // MARK: Entrollment
    func test_valid_name_enrollment() {
        let result = SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: "VMESH-123456")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(valid, reason)
    }
    
    func test_too_short_name_enrollment() {
        let result = SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: "")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(!valid, reason)
    }
    
    func test_too_long_name_enrollment() {
        let result = SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: "1234567890123456789012345678901234567890")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(!valid, reason)
    }
    
    func test_invalid_char_name_enrollment() {
        let result = SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: "&*^%$£@!`~<>?;:'\\|{}[]-_=+")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(!valid, reason)
    }
    
    // MARK: Other SSID validation
    func test_valid_name() {
        let result = SSIDNamePasswordValidation.ssidNameValid(str: "VMESH-123456")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(valid, reason)
    }
    
    func test_too_short_name() {
        let result = SSIDNamePasswordValidation.ssidNameValid(str: "")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(!valid, reason)
    }
    
    func test_too_long_name() {
        let result = SSIDNamePasswordValidation.ssidNameValid(str: "1234567890123456789012345678901234567890")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(!valid, reason)
    }
    
    // MARK: - Password tests

    // MARK: Entrollment
    func test_valid_password_enrollment() {
        let result = SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: "1234567890")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(valid, reason)
    }
    
    func test_too_short_password_enrollment() {
        let result = SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: "")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(!valid, reason)
    }
    
    func test_too_long_password_enrollment() {
        let result = SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(!valid, reason)
    }
    
    func test_invalid_char_password_enrollment() {
        let result = SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: "&*^%$£@!`~<>?;:'\\|{}[]-_=+")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(!valid, reason)
    }
    
    // MARK: Other SSID validation
    func test_valid_password() {
        let result = SSIDNamePasswordValidation.passwordValid(passString: "1234567890", ssid: "TestSSID")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(valid, reason)
    }
    
    func test_too_short_password() {
        let result = SSIDNamePasswordValidation.passwordValid(passString: "1234", ssid: "TestSSID")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(!valid, reason)
    }
    
    func test_too_long_password() {
        let result = SSIDNamePasswordValidation.passwordValid(passString: "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890", ssid: "TestSSID")
        let valid = result.0
        let reason = result.1 ?? "No reason"
        XCTAssert(!valid, reason)
    }
}
