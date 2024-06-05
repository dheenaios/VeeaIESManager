//
//  JsonTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 06/12/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

final class JsonTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    /// Test the validity of bundled json files
    func testJsonValidity() {
        let files = getNamesOfJsonFiles()
        XCTAssertFalse(files.isEmpty)

        for file in files {
            XCTAssertTrue(isValidJson(fileName: file))
        }
    }

    private func isValidJson(fileName: String) -> Bool {
        let components = fileName.components(separatedBy: ".")
        XCTAssertTrue(components.count == 2)

        do {
            if let data = try Bundle.main.jsonData(fromFile: components.first!, format: components.last!) {
                if JSONSerialization.isValidJSONObject(data) { // Valid object
                    return true
                }
                else { // Might be an array
                    return isValidJsonArray(data: data)
                }
            }
            else {
                //print("Invalid Json object in file: \(fileName)")
            }
        }
        catch {
            XCTAssert(false, error.localizedDescription)
        }

        return false
    }

    private func isValidJsonArray(data: Data) -> Bool {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        return json != nil
    }


    private func getNamesOfJsonFiles() -> [String] {
        var jsonFiles = [String]()
        if let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath ){

            for file in files {
                let components = file.components(separatedBy: ".")
                if components.last == "json" {
                    jsonFiles.append(file)
                }
            }
        }

        return jsonFiles
    }
}
