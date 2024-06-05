//
//  WelcomeScreenTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 09/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class WelcomeScreenTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_GetsLogin() async {
        let result = await LogoutController.endSession()

        await MainActor.run {
            switch result {
            case .success:
                let loginFlowCoord = LoginFlowCoordinator()
                let screenNav = loginFlowCoord.getInitialViewController()

                guard let nav = screenNav as? UINavigationController,
                        let login = nav.viewControllers.first as? LoginViewController else {
                    XCTFail("Unexpected types")
                    return
                }

                let vm = login.vm
                let type = vm.homeUserRealm()

                if type.id != "veea" || type.name != "veea" {
                    XCTFail("Unexpected realm")
                }

                if login.privacyUrl != "https://go.veea.com/privacy/" {
                    XCTFail("Unexpected url")
                }

                if login.termsUrl != "https://go.veea.com/tos/" {
                    XCTFail("Unexpected url")
                }

                break
            case .noAuthToken:
                XCTFail("Could not logout")
            case .noFbToken:
                XCTFail("Should not be returned on end session")
            case .FbTokenError(let string):
                XCTFail("Should not be returned on end session \(string)")
            case .couldNotMakeRequestBody:
                XCTFail("Should not be returned on end session")
            case .unknown(let string):
                XCTFail("Should not be returned on end session \(string)")
            }
        }
    }
}
