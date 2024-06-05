//
//  EmailAddressTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 21/04/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

final class EmailAddressTests: XCTestCase {
    func test_isVeeaEmailValidation() {
            let email = "r@mac.com"
            let result = EmailValidation.isVeeaUser(email: email)
            XCTAssertFalse(result)

            let email2 = "r@veea.com"
            let result2 = EmailValidation.isVeeaUser(email: email2)
            XCTAssertTrue(result2)

            let email3 = "r@max2.com"
            let result3 = EmailValidation.isVeeaUser(email: email3)
            XCTAssertTrue(result3)

            let email4 = "r@veeasystems.com"
            let result4 = EmailValidation.isVeeaUser(email: email4)
            XCTAssertTrue(result4)

            let email5 = "r@max2Inc.com"
            let result5 = EmailValidation.isVeeaUser(email: email5)
            XCTAssertFalse(result5)

            let email6 = "r@veeasystems.co.uk"
            let result6 = EmailValidation.isVeeaUser(email: email6)
            XCTAssertTrue(result6)
        }


}
