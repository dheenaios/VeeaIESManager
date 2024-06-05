//
//  MyAccountVcTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 09/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager
@testable import SharedBackendNetworking

class MyAccountVmTests: XCTestCase {

    var vm: MyAccountTableViewModel!

    override func setUpWithError() throws {
        let mockUser = VHUser.mockUser()
        let vm = MyAccountTableViewModel()
        vm.user = mockUser
        self.vm = vm
    }

    func test_initials() {
        let v = vm.initials
        if v != "TO" {
            XCTFail("Unexpected initials")
        }
    }

    func test_username() {
        let v = vm.usersName
        if v != "Tommy OneTwo" {
            XCTFail("Unexpected UserName")
        }
    }

    func test_emailAddress() {
        let v = vm.usersEmailAddress
        if v != "one@two.com" {
            XCTFail("Unexpected email address")
        }
    }

    func test_appName() {
        let v = vm.appName
        if v != "VeeaHub Manager" {
            XCTFail("Unexpected app name")
        }
    }

    func test_appVersionText() {

        // For release version we do not show the build number.
        let expected = "Version" + " " + VeeaKit.versions.application
        let v = vm.version
        if v != expected {
            XCTFail("Unexpected version")
        }
    }

    func test_supportCenterUrl() {
        let v = vm.supportCenterUrl
        if v != "https://go.veea.com/troubleshooting" {
            XCTFail("Unexpected url")
        }
    }

    func test_contactUsUrl() {
        let v = vm.contactUsUrl
        if v != "https://veea.zendesk.com/hc/en-us/requests/new/" {
            XCTFail("Unexpected url")
        }
    }

    func test_termsUrl() {
        let v = vm.termsUrl
        if v != "https://go.veea.com/tos/" {
            XCTFail("Unexpected url")
        }
    }

    func test_privacyPolicy() {
        let v = vm.privacyPolicy
        if v != "https://go.veea.com/privacy/" {
            XCTFail("Unexpected url")
        }
    }
}
