//
//  LocationSelectorTests.swift
//  VeeaHub ManagerTests
//
//  Created by Niranjan Ravichandran on 6/18/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class LocationSelectorTests: XCTestCase {
    
//    var locationSelectorVC: SelectLocationViewController!
//
//    override func setUp() {
//        let current = TimeZone.current.identifier.components(separatedBy: "/")
//        let currentArea = current.first ?? ""
//        let currentRegion = current.last ?? ""
//        let countryCode = NSLocale.current.regionCode ?? "US"
//        locationSelectorVC = SelectLocationViewController(region: currentRegion, area: currentArea, country: countryCode)
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testCountryCodeSuccess() {
//        let code = locationSelectorVC.getCountryCode(for: locationSelectorVC.areaData.subtitle!, region: locationSelectorVC.regionData.subtitle!)
//        XCTAssertEqual(code, "US")
//    }
//
//    func testCustomCountryCodeSuccess() {
//        locationSelectorVC = SelectLocationViewController(region: "Europe", area: "London", country: "GB")
////        let code = locationSelectorVC.getCountryCode(for: "Europe", region: "London")
//        _ = locationSelectorVC.view
//        XCTAssertEqual(locationSelectorVC.countryData.subtitle!, "GB")
//    }
//    
//    func testCountryCodeFail() {
//        _ = locationSelectorVC.view
//        let code = locationSelectorVC.getCountryCode(for: "Europe", region: "Manchester")
//        XCTAssertFalse(code == "UK")
//    }
}
