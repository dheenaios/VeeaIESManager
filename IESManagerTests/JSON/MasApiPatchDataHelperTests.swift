//
//  MasApiPatchDataHelperTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 11/05/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class MasApiPatchDataHelperTests: XCTestCase {

    let tableName = "SomeTableName"

    func test_emptyContent() {
        guard let result = MasApiPatchDataHelper.patch(sourceJson: JSON(),
                                                       targetJson: JSON(),
                                                       tableName: tableName) else {
            XCTFail("Expected a result")
            return
        }

        guard let dict = result.toJson() else {
            XCTFail("The result data should convert to json")
            return
        }

        if let resultObject = dict[tableName] {
            if let arr = resultObject as? [Any] {
                if !arr.isEmpty {
                    XCTFail("Array should be empty")
                }
            }
        }
        else {
            XCTFail("The key should exist")
        }
    }

    func test_differentKeys() {
        var o = JSON()
        o["item1"] = "Some String"
        o["item2"] = "Some String2"

        var t = JSON()
        t["item1"] = "Some String"
        t["item3"] = "Some String3"

        guard let result = MasApiPatchDataHelper.patch(sourceJson: o,
                                                       targetJson: t,
                                                       tableName: tableName) else {
            XCTFail("Expected a result")
            return
        }

        guard let dict = result.toJson() else {
            XCTFail("The result data should convert to json")
            return
        }

        // Should remove item 2 and add item 3
        if let resultObject = dict[tableName] {
            if let arr = resultObject as? [JSON] {
                if arr.isEmpty {
                    XCTFail("Should not be empty")
                }
                else {
                    if arr.count != 2 {
                        XCTFail("Expected 2 results")
                    }
                    else {
                        XCTAssertTrue(jsonArray(jsonArray: arr,
                                                containsOperation: "remove",
                                                path: "/item2"))

                        XCTAssertTrue(jsonArray(jsonArray: arr,
                                                containsOperation: "add",
                                                path: "/item3"))
                    }
                }
            }
        }
        else {
            XCTFail("The key should exist")
        }
    }

    func test_differentStringValue() {
        var o = JSON()
        o["item1"] = "Some String"
        o["item2"] = "Some String2"

        var t = JSON()
        t["item1"] = "Some String"
        t["item2"] = "Some String3"

        guard let result = MasApiPatchDataHelper.patch(sourceJson: o,
                                                       targetJson: t,
                                                       tableName: tableName) else {
            XCTFail("Expected a result")
            return
        }

        guard let dict = result.toJson() else {
            XCTFail("The result data should convert to json")
            return
        }

        // Should remove item 2 and add item 3
        if let resultObject = dict[tableName] {
            if let arr = resultObject as? [JSON] {
                if arr.isEmpty {
                    XCTFail("Should not be empty")
                }
                else {
                    if arr.count != 1 {
                        XCTFail("Expected 2 results")
                    }
                    else {
                        XCTAssertTrue(jsonArray(jsonArray: arr,
                                                containsOperation: "replace",
                                                path: "/item2"))
                    }
                }
            }
        }
        else {
            XCTFail("The key should exist")
        }
    }

    // MARK: - Helpers
    private func jsonArray(jsonArray: [JSON],
                          containsOperation operation: String,
                          path: String) -> Bool {
        for json in jsonArray {
            guard let itemOperation = json["op"] as? String,
                  let itemPath = json["path"] as? String else {
                return false
            }

            if itemOperation == operation {
                if operation == "remove" {
                    return path == itemPath
                }
                if operation == "add" {
                    return json["value"] != nil && path == itemPath
                }
                if operation == "replace" {
                    return json["value"] != nil && path == itemPath
                }
            }
        }

        return false
    }
}
