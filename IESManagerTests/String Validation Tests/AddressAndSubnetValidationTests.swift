//
//  AddressAndSubnetValidationTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 27/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class AddressAndSubnetValidationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_subnet_valid() {
        let start = "1.1.1.1"
        let end = "1.1.1.10"
        let mask = 24

        let sameSubnet = AddressAndSubnetValidation.areBothIpsOnSameSubnet(ipA: start,
                                                              ipB: end,
                                                              mask: mask)

        if !sameSubnet {
            XCTFail("Should be on the same subnet")
        }
    }

    func test_subnet_invalid() {
        let start = "1.1.1.1"
        let end = "10.1.1.10"
        let mask = 24

        let sameSubnet = AddressAndSubnetValidation.areBothIpsOnSameSubnet(ipA: start,
                                                              ipB: end,
                                                              mask: mask)

        if sameSubnet {
            XCTFail("Should not be on the same subnet")
        }
    }

    func test_isPlaceholderCidr() {
        XCTAssertTrue(AddressAndPortValidation.isValidPlaceholderRoute(cidr: "0.0.0.0/0"))
        XCTAssertFalse(AddressAndPortValidation.isValidPlaceholderRoute(cidr: nil))
        XCTAssertFalse(AddressAndPortValidation.isValidPlaceholderRoute(cidr: "0.0.0.0"))
        XCTAssertFalse(AddressAndPortValidation.isValidPlaceholderRoute(cidr: "0.0.0.0/1"))
        XCTAssertFalse(AddressAndPortValidation.isValidPlaceholderRoute(cidr: "8.8.8.8"))
        XCTAssertFalse(AddressAndPortValidation.isValidPlaceholderRoute(cidr: "8.8.8.8/1"))
        XCTAssertFalse(AddressAndPortValidation.isValidPlaceholderRoute(cidr: "192.168.1.1"))
        XCTAssertFalse(AddressAndPortValidation.isValidPlaceholderRoute(cidr: "192.168.1.1/0"))
        XCTAssertFalse(AddressAndPortValidation.isValidPlaceholderRoute(cidr: "192.168.1.1/20"))
    }

    func test_validatePlaceholderRoute() {
        XCTAssertTrue(AddressAndPortValidation.validatePlaceholderRoute(cidr: "0.0.0.0/0") == nil)
        XCTAssertTrue(AddressAndPortValidation.validatePlaceholderRoute(cidr: nil) == nil)

        XCTAssertTrue(AddressAndPortValidation.validatePlaceholderRoute(cidr: "0.0.0.0") != nil)
        XCTAssertTrue(AddressAndPortValidation.validatePlaceholderRoute(cidr: "0.0.0.0/1") != nil)
        XCTAssertTrue(AddressAndPortValidation.validatePlaceholderRoute(cidr: "8.8.8.8") != nil)
        XCTAssertTrue(AddressAndPortValidation.validatePlaceholderRoute(cidr: "8.8.8.8/1") != nil)
        XCTAssertTrue(AddressAndPortValidation.validatePlaceholderRoute(cidr: "192.168.1.1") != nil)
        XCTAssertTrue(AddressAndPortValidation.validatePlaceholderRoute(cidr: "192.168.1.1/0") != nil)
        XCTAssertTrue(AddressAndPortValidation.validatePlaceholderRoute(cidr: "192.168.1.1/20") != nil)
    }

    func test_isFirstAddressAndPrefixValid() {
        let ipSub = "10.100.1.0/24"

        guard let e = AddressAndSubnetValidation.isFirstAddressAndPrefixValid(addressSubnetString: ipSub) else {
            return
        }

        XCTFail("Did not expect an error: \(e)")
    }
    func test_isFirstAddressAndPrefixValid2() {
        let ipSub = "10.100.1.0/1"

        if let e = AddressAndSubnetValidation.isFirstAddressAndPrefixValid(addressSubnetString: ipSub) {
            if e != "The provided IP is not the first IP in the subnet. It should be 0.0.0.0 for the prefix 1" {
                XCTFail("Expected error message: \(e)")
            }

            return
        }

        XCTFail("Expected error")
    }

    func test_isSubnetValid() {
        var valid = true

        // Valid
        valid = AddressAndSubnetValidation.isSubnetValid(subnet: 0)
        if !valid { XCTFail("Expected an invalid result") }

        valid = AddressAndSubnetValidation.isSubnetValid(subnet: 1)
        if !valid { XCTFail("Expected a valid result") }

        valid = AddressAndSubnetValidation.isSubnetValid(subnet: 10)
        if !valid { XCTFail("Expected a valid result") }

        valid = AddressAndSubnetValidation.isSubnetValid(subnet: 22)
        if !valid { XCTFail("Expected a valid result") }

        valid = AddressAndSubnetValidation.isSubnetValid(subnet: 30)
        if !valid { XCTFail("Expected a valid result") }

        valid = AddressAndSubnetValidation.isSubnetValid(subnet: 31)
        if !valid { XCTFail("Expected a valid result") }

        // Invalid
        valid = AddressAndSubnetValidation.isSubnetValid(subnet: -1)
        if valid { XCTFail("Expected an invalid result") }

        valid = AddressAndSubnetValidation.isSubnetValid(subnet: 32)
        if valid { XCTFail("Expected a valid result") }

        valid = AddressAndSubnetValidation.isSubnetValid(subnet: 33)
        if valid { XCTFail("Expected an invalid result") }

        valid = AddressAndSubnetValidation.isSubnetValid(subnet: 55)
        if valid { XCTFail("Expected an invalid result") }

        valid = AddressAndSubnetValidation.isSubnetValid(subnet: 432534534)
        if valid { XCTFail("Expected an invalid result") }
    }

    func test_isAddressAndPrefixValid() {
        var valid = true

        // Valid
        valid = AddressAndSubnetValidation.isAddressAndPrefixValid(addressSubnetString: "10.100.1.0/24")
        if !valid { XCTFail("Expected a valid result") }

        // Invalid
        valid = AddressAndSubnetValidation.isAddressAndPrefixValid(addressSubnetString: "1.1.1./1")
        if valid { XCTFail("Expected a valid result") }

        valid = AddressAndSubnetValidation.isAddressAndPrefixValid(addressSubnetString: "10.100.1.0.2/24")
        if valid { XCTFail("Expected an invalid result") }

        valid = AddressAndSubnetValidation.isAddressAndPrefixValid(addressSubnetString: "hello/24")
        if valid { XCTFail("Expected an invalid result") }

        valid = AddressAndSubnetValidation.isAddressAndPrefixValid(addressSubnetString: "0.0.0.0/24")
        if valid { XCTFail("Expected an invalid result") }
    }
}
