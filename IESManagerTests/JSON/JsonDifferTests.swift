//
//  JsonDifferTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 04/05/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class JsonDifferTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Check for target nil
    func test_emptyContent() {
        do {
            let result = try JsonDiffer.diffJson(original: JSON(), target: JSON())
            if !result.isEmpty {
                XCTFail("Result should be empty")
            }
        }
        catch {
            XCTFail("Should be no exception")
        }
    }

    // Check _rev and _id ignored in original json
    func test_idAndRevisionKeysIgnoredInOriginal() {
        do {
            let result = try JsonDiffer.diffJson(original: jsonWithRevAndId, target: JSON())
            if !result.isEmpty {
                XCTFail("Result should be empty")
            }
        }
        catch {
            XCTFail("Should be no exception")
        }
    }

//    // Different Keys
    func test_differentKeys() {
        do {
            let diff = try JsonDiffer.diffJson(original: JSON(), target: jsonWithKeyAndString)
            XCTFail("Should have thrown: \(diff)")
        }
        catch let error as JsonDiffer.JsonDiffingErrors {
            switch error {
            case .conflictingTypes, .unexpectedType, .unknownError:
                XCTFail("Should have thrown diff keys, not: \(error.localizedDescription)")
            case .differentKeys:
                return // correct value
            }
        }
        catch {
            XCTFail("Unexpected error type")
        }

        XCTFail("Result should be nil")
    }

    // Different value: string
    func test_differentStringValue() {
        do {
            let diff = try JsonDiffer.diffJson(original: jsonWithKeyAndString,
                                               target: jsonWithKeyAndStringAlt)

            if let one = diff["one"] as? String {
                if one != "Two" {
                    XCTFail("Unexpected value \(one). Should be \"Two\"")
                }
            }
        }
        catch {
            XCTFail("Unexpected error thrown")
        }
    }

    // Different value: number int
    func test_differentIntValue() {
        do {
            let diff = try JsonDiffer.diffJson(original: jsonWithKeyAndInt,
                                               target: jsonWithKeyAndIntAlt)

            if let one = diff["one"] as? Int {
                if one != 2{
                    XCTFail("Unexpected value \(one). Should be 2")
                }
            }
        }
        catch {
            XCTFail("Unexpected error thrown")
        }
    }

    // Different value: number float
    func test_differentFloatValue() {
        do {
            let diff = try JsonDiffer.diffJson(original: jsonWithKeyAndFloat,
                                               target: jsonWithKeyAndFloatAlt)

            if let one = diff["one"] as? Float {
                if one != 1.2{
                    XCTFail("Unexpected value \(one). Should be 2")
                }
            }
        }
        catch {
            XCTFail("Unexpected error thrown")
        }
    }

    // Different value: bool
    func test_differentBoolValue() {
        do {
            let diff = try JsonDiffer.diffJson(original: jsonWithKeyAndBool,
                                               target: jsonWithKeyAndBool)

            if let one = diff["one"] as? Bool {
                if one != false {
                    XCTFail("Unexpected value \(one). Should be 2")
                }
            }
        }
        catch {
            XCTFail("Unexpected error thrown")
        }
    }

    // Different value: Object
    func test_differentObjectStringValue() {
        do {
            let diff = try JsonDiffer.diffJson(original: jsonWithKeyAndObjectString,
                                               target: jsonWithKeyAndObjectStringAlt)

            if let one = diff["one"] as? JSON {
                if let oneA = one["one"] as? String {
                    if oneA != "Two" {
                        XCTFail("Unexpected value should be Two")
                    }
                }
            }
        }
        catch {
            XCTFail("Unexpected error thrown")
        }
    }

    func test_differentObjectNumberValue() {
        do {
            let diff = try JsonDiffer.diffJson(original: jsonWithKeyAndObjectString,
                                               target: jsonWithKeyAndObjectStringAlt)

            if let one = diff["one"] as? JSON {
                if let oneA = one["one"] as? Int {
                    if oneA != 2 {
                        XCTFail("Unexpected value should be Two")
                    }
                }
            }
        }
        catch {
            XCTFail("Unexpected error thrown")
        }
    }

    func test_differentObjectBoolValue() {
        do {
            let diff = try JsonDiffer.diffJson(original: jsonWithKeyAndObjectString,
                                               target: jsonWithKeyAndObjectStringAlt)

            if let one = diff["one"] as? JSON {
                if let oneA = one["one"] as? Bool {
                    if oneA != false {
                        XCTFail("Unexpected value should be Two")
                    }
                }
            }
        }
        catch {
            XCTFail("Unexpected error thrown")
        }
    }

    // Different value: Array
    func test_differentArrayValue() {
        do {
            let diff = try JsonDiffer.diffJson(original: jsonWithKeyAndArray,
                                               target: jsonWithKeyAndArrayAlt)
            if let arr = diff["one"] as? [Int] {
                if arr.count != 2 {
                    XCTFail("Wrong number of elements")
                }
                if arr.first != 2 {
                    XCTFail("Expected first element to be 2")
                }
                if arr.last != 3 {
                    XCTFail("Expected last element to be 3")
                }
            }
        }
        catch {
            XCTFail("Unexpected error thrown")
        }
    }
}

// Test data
extension JsonDifferTests {
    var jsonWithRevAndId: JSON {
        var json = JSON()
        json["_rev"] = "Rev"
        json["_id"] = "Id"

        return json
    }

    var jsonWithKeyAndString: JSON {
        var json = JSON()
        json["one"] = "One"

        return json
    }

    var jsonWithKeyAndStringAlt: JSON {
        var json = JSON()
        json["one"] = "Two"

        return json
    }

    var jsonWithKeyAndInt: JSON {
        var json = JSON()
        json["one"] = 1

        return json
    }

    var jsonWithKeyAndIntAlt: JSON {
        var json = JSON()
        json["one"] = 2

        return json
    }

    var jsonWithKeyAndFloat: JSON {
        var json = JSON()
        json["one"] = 1.1

        return json
    }

    var jsonWithKeyAndFloatAlt: JSON {
        var json = JSON()
        json["one"] = 1.2

        return json
    }

    var jsonWithKeyAndBool: JSON {
        var json = JSON()
        json["one"] = true

        return json
    }

    var jsonWithKeyAndBoolAlt: JSON {
        var json = JSON()
        json["one"] = false

        return json
    }

    var jsonWithKeyAndObjectString: JSON {
        var json = JSON()
        json["one"] = jsonWithKeyAndString

        return json
    }

    var jsonWithKeyAndObjectStringAlt: JSON {
        var json = JSON()
        json["one"] = jsonWithKeyAndStringAlt

        return json
    }

    var jsonWithKeyAndObjectNumber: JSON {
        var json = JSON()
        json["one"] = jsonWithKeyAndInt

        return json
    }

    var jsonWithKeyAndObjectNumberAlt: JSON {
        var json = JSON()
        json["one"] = jsonWithKeyAndIntAlt

        return json
    }

    var jsonWithKeyAndObjectBool: JSON {
        var json = JSON()
        json["one"] = jsonWithKeyAndBool

        return json
    }

    var jsonWithKeyAndObjectBoolAlt: JSON {
        var json = JSON()
        json["one"] = jsonWithKeyAndBoolAlt

        return json
    }

    var jsonWithKeyAndArray: JSON {
        var json = JSON()
        let arr = [1, 2]
        json["one"] = arr

        return json
    }

    var jsonWithKeyAndArrayAlt: JSON {
        var json = JSON()
        let arr = [2, 3]
        json["one"] = arr

        return json
    }
}
