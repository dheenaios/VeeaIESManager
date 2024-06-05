//
//  CellularStrengthToBarsTests.swift
//  SharedBackendNetworkingTests
//
//  Created by Richard Stockdale on 07/10/2022.
//

import XCTest
@testable import SharedBackendNetworking

final class CellularStrengthToBarsTests: XCTestCase {


    func test_signalStrength() {
        for strengthPercentage in -1..<102 {
            let bars = CellularStrengthToBars.convert(strengthPercentage: strengthPercentage)
                        
            // Test some outlayers
            if strengthPercentage == -1 {
                XCTAssertTrue(bars == 0, "Strength: \(strengthPercentage), bars: \(bars)")
                continue
            }
            else if strengthPercentage == 101 {
                XCTAssertTrue(bars == 0, "Strength: \(strengthPercentage), bars: \(bars)")
                continue
            }
            
            
            
            if strengthPercentage > 0 && strengthPercentage <= 20 {
                XCTAssertTrue(true, "Strength: \(strengthPercentage), bars: \(bars)")
                
            }
            else if strengthPercentage > 20 && strengthPercentage <= 40 {
                XCTAssertTrue(bars == 2, "Strength: \(strengthPercentage), bars: \(bars)")
            }
            else if strengthPercentage > 40 && strengthPercentage <= 60 {
                XCTAssertTrue(bars == 3, "Strength: \(strengthPercentage), bars: \(bars)")
            }
            else if strengthPercentage > 60 && strengthPercentage <= 80 {
                XCTAssertTrue(bars == 4, "Strength: \(strengthPercentage), bars: \(bars)")
            }
            else if strengthPercentage > 80 && strengthPercentage <= 100 {
                XCTAssertTrue(bars == 5, "Strength: \(strengthPercentage), bars: \(bars)")
            }
            else {
                XCTAssertTrue(bars == 0, "Strength: \(strengthPercentage), bars: \(bars)")
            }
            
            
        }

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
