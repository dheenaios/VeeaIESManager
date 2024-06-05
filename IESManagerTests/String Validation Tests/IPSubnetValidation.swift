//
//  IPSubnetValidation.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 09/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class IPSubnetValidation: XCTestCase {
    func test_ip_1() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "192.168.1.1") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_ip_2() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "192.168.1.1/32") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_ip_3() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "192.168.1.0/24") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_ip_4() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "192.168.1.253/32") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_ip_5() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "10.0.0.0/8") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_ip_6() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "192.168.1.0/32") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_ip_7() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "192.168.1.255/32") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_ip_8() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "192.0.2.0/24") {
            XCTAssert(false, result)
            return
        }
        
        XCTAssert(true, "Pass")
    }
    
    func test_ip_9() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "192.0.2.500/24") {
            XCTAssert(true, result)
            return
        }
        
        XCTAssert(false, "Pass")
    }

    func test_ip_10() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "192.168.1.253/24") {
            XCTAssert(true, result)
            return
        }

        XCTAssert(false, "Pass")
    }

    func test_ip_11() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "192.168.1.253/31") {
            XCTAssert(true, result)
            return
        }

        XCTAssert(false, "Pass")
    }

    func test_ip_12() {
        if let result = AddressAndPortValidation.ipAndSubnetError(string: "10.10.0.0/8") {
            XCTAssert(true, result)
            return
        }

        XCTAssert(false, "Pass")
    }
}


/*
 

 192.168.1.253/24:false
 192.168.1.253/31:false
 10.10.0.0/8:false
 
 */
