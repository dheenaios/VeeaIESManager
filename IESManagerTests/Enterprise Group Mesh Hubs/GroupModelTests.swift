//
//  GroupModelTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 29/06/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import XCTest
@testable import SharedBackendNetworking

class GroupModelTests: XCTestCase {

    func test_Equality() {
        let path1 = PathElement(displayName: "Name1", id: "1", name: "Name1")
        let path2 = PathElement(displayName: "Name2", id: "2", name: "Name2")
        let counts = Counts(children: 10, devices: 10, meshes: 10, users: 10)

        let group1 = GroupModel(counts: counts, displayName: "Group1", id: "1", name: "Group1", path: [path1, path2])
        let group2 = GroupModel(counts: counts, displayName: "Group1", id: "1", name: "Group1", path: [path1, path2])

        XCTAssertEqual(group1, group2, "Equality test failed for equal GroupModel instances")
    }

    func test_ParentGroupId() {
        let path1 = PathElement(displayName: "Name1", id: "1", name: "Name1")
        let path2 = PathElement(displayName: "Name2", id: "2", name: "Name2")
        let counts = Counts(children: 10, devices: 10, meshes: 10, users: 10)

        let group = GroupModel(counts: counts, displayName: "Group1", id: "1", name: "Group1", path: [path1, path2])

        XCTAssertEqual(group.parentGroupId, "1", "Parent Group ID does not match expected value")
    }

    func test_SelectedModel() {
        let path = PathElement(displayName: "Name", id: "1", name: "Name")
        let counts = Counts(children: 10, devices: 10, meshes: 10, users: 10)

        let group = GroupModel(counts: counts, displayName: "Group", id: "1", name: "Group", path: [path])
        GroupModel.selectedModel = group

        XCTAssertEqual(GroupModel.selectedModel, group, "Saved GroupModel does not match retrieved GroupModel")
    }

    // More tests could be added to validate negative cases and edge cases
}
