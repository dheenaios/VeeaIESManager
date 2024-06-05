//
//  GroupServiceTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 29/06/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import XCTest
@testable import SharedBackendNetworking

class GroupServiceTests: XCTestCase {

    func test_IsDataStale() {
        let groupService = GroupService()
        XCTAssert(groupService.isDataStale, "Initial isDataStale should return true")

        groupService.lastInitialLoadTime = Date()
        XCTAssertFalse(groupService.isDataStale, "isDataStale should return false after setting lastInitialLoadTime")
    }

    func test_MoreAvailable() {
        let groupService = GroupService()
        XCTAssertFalse(groupService.moreAvailable, "Initial moreAvailable should return false")

        groupService.lastMeta = Meta(nextCursor: "someCursor", prevCursor: nil)
        XCTAssert(groupService.moreAvailable, "moreAvailable should return true when nextCursor is not empty")
    }

    func test_ReadablePath() {
        let groupService = GroupService()
        XCTAssertNil(groupService.readablePath, "Initial readablePath should return nil")

        let path = PathElement(displayName: "root", id: "1", name: "root")
        let counts = Counts(children: 10, devices: 10, meshes: 10, users: 10)
        let groupModel = GroupModel(counts: counts, displayName: "Group", id: "1", name: "Group", path: [path])
        groupService.groupModels = [groupModel]

        XCTAssertEqual(groupService.readablePath, "", "readablePath should return empty string when path only contains root")
    }
}
