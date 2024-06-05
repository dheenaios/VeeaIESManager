//
//  HomeDashboardHeaderTests.swift
//  IESManagerTests
//
//  Created by Richard Stockdale on 06/05/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import XCTest
@testable import IESManager

class HomeDashboardHeaderTests: XCTestCase {

    let imageDisabled = UIImage(named: "home_strength_bars_disabled")
    let image0Bar = UIImage(named: "home_strength_bars_0")
    let image1Bar = UIImage(named: "home_strength_bars_1")
    let image2Bar = UIImage(named: "home_strength_bars_2")
    let image3Bar = UIImage(named: "home_strength_bars_3")
    let image4Bar = UIImage(named: "home_strength_bars_4")
    let image5Bar = UIImage(named: "home_strength_bars_5")

    let imageG2 = UIImage(named: "2G Logo")
    let imageG3 = UIImage(named: "3G Logo")
    let imageG4 = UIImage(named: "4G Logo")
    let imageG5 = UIImage(named: "5G Logo")

//    let snapshotFile = "2022-05-06-Cellular-Disabled.json"
//    var snapshot: ConfigurationSnapShot!
//    var snapshotLoader: SnapshotLoader!
//
//    var hdm: HubDataModel!
//    var headerViewModel: HomeDashboardHeaderViewModel!

//    override func setUpWithError() throws {
//        snapshotLoader = SnapshotLoader()
//
//        guard let s = snapshotLoader.getSnapshots() else {
//            XCTFail("Failed to load snapshots from bundle")
//            return
//        }
//
//        let index = snapshotLoader.fileNames.firstIndex(of: snapshotFile)
//        snapshot = ConfigurationSnapShot(snapShotJson: s[index!])
//
//        HubDataModel.shared.configurationSnapShotItem = snapshot
//        HubDataModel.shared.snapShotInUse = true
//        hdm = HubDataModel.shared
//
//
//    }

    // MARK: - Bars
    func test_NoSupport() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "2G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        // Check if the view is hidden
        XCTAssertFalse(headerViewModel.showCellularSignal)
    }

    func test_NoSubscription() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSubscription,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "2G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        //Cellular should be shown
        XCTAssertTrue(headerViewModel.showCellularSignal)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.cellularDataSignalImage == imageDisabled)
    }

    func test_NoBars() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .bar0,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "2G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        //Cellular should be shown
        XCTAssertTrue(headerViewModel.showCellularSignal)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.cellularDataSignalImage == image0Bar)
    }

    func test_OneBar() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .bar1,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "2G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        //Cellular should be shown
        XCTAssertTrue(headerViewModel.showCellularSignal)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.cellularDataSignalImage == image1Bar)
    }

    func test_TwoBars() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .bar2,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "2G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        //Cellular should be shown
        XCTAssertTrue(headerViewModel.showCellularSignal)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.cellularDataSignalImage == image2Bar)
    }

    func test_ThreeBars() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .bar3,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "2G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        //Cellular should be shown
        XCTAssertTrue(headerViewModel.showCellularSignal)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.cellularDataSignalImage == image3Bar)
    }

    func test_FourBars() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .bar4,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "2G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        //Cellular should be shown
        XCTAssertTrue(headerViewModel.showCellularSignal)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.cellularDataSignalImage == image4Bar)
    }

    func test_FiveBars() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .bar5,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "2G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        //Cellular should be shown
        XCTAssertTrue(headerViewModel.showCellularSignal)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.cellularDataSignalImage == image5Bar)
    }

    // Service type tests

    func test_2GLogo() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .bar5,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "2G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.networkTypeImage == imageG2)
    }

    func test_3GLogo() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .bar5,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "3G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.networkTypeImage == imageG3)
    }

    func test_4GLogo() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .bar5,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "4G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.networkTypeImage == imageG4)
    }

    func test_5GLogo() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .bar5,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        // Check the signal strength image is correct
        XCTAssertTrue(headerViewModel.networkTypeImage == imageG5)
    }

    func test_GLogoNoSupport() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: "Barry",
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        // Check the signal strength image is correct
        XCTAssertNil(headerViewModel.networkTypeImage)
    }

    // MARK: - Greeting
    func test_Greeting() {
        let name = "Barry"

        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: name,
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        let greeting = headerViewModel.greeting
        let correctResult = "Hello".localized() + " " + name + "!"

        XCTAssertTrue(greeting == correctResult)
    }

    // MARK: - Device Connection Text

    func test_preparing() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.isPreparing,
                                       usersName: name,
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        let connectionLabel = headerViewModel.deviceConnectionLabelText
        let correctResult = "Preparing your network.\nThis might take up to an hour.".localized()

        XCTAssertTrue(connectionLabel == correctResult)
    }

    func test_error() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.inError,
                                       usersName: name,
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        let connectionLabel = headerViewModel.deviceConnectionLabelText
        let correctResult = "Unable to prepare your network.".localized()

        XCTAssertTrue(connectionLabel == correctResult)
    }

    func test_notAvailable() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.notAvailable,
                                       usersName: name,
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        let connectionLabel = headerViewModel.deviceConnectionLabelText
        let correctResult = "Unable to connect to your network".localized()

        XCTAssertTrue(connectionLabel == correctResult)
    }

    func test_health1Hub() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: name,
                                       numberOfHubs: 1,
                                       numberOfHosts: 2,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        let connectionLabel = headerViewModel.deviceConnectionLabelText
        let correctResult = "2 devices connected\n1 VeeaHub in location"

        XCTAssertTrue(connectionLabel == correctResult)
    }

    func test_health2Hubs() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: name,
                                       numberOfHubs: 2,
                                       numberOfHosts: 2,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        let connectionLabel = headerViewModel.deviceConnectionLabelText
        let correctResult = "2 devices connected\n2 VeeaHubs in location"

        XCTAssertTrue(connectionLabel == correctResult)
    }

    func test_health5Hubs() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: name,
                                       numberOfHubs: 5,
                                       numberOfHosts: 2,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        let connectionLabel = headerViewModel.deviceConnectionLabelText
        let correctResult = "2 devices connected\n5 VeeaHubs in location"

        XCTAssertTrue(connectionLabel == correctResult)
    }

    // MARK: - Connected Devices
    func test_health0Devices() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: name,
                                       numberOfHubs: 5,
                                       numberOfHosts: 0,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        let connectionLabel = headerViewModel.deviceConnectionLabelText
        let correctResult = "5 VeeaHubs in location"

        XCTAssertTrue(connectionLabel == correctResult)
    }

    func test_health1Devices() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: name,
                                       numberOfHubs: 5,
                                       numberOfHosts: 1,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        let connectionLabel = headerViewModel.deviceConnectionLabelText
        let correctResult = "1 device is connected\n5 VeeaHubs in location"

        XCTAssertTrue(connectionLabel == correctResult)
    }

    func test_health5Devices() {
        let config = HomeDashboardHeaderViewModel
            .HomeDashboardHeaderConfig(cellular: .noCellularSupport,
                                       headerState: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState.healthy,
                                       usersName: name,
                                       numberOfHubs: 5,
                                       numberOfHosts: 5,
                                       networkMode: "5G")

        let headerViewModel = HomeDashboardHeaderViewModel(config: config)

        let connectionLabel = headerViewModel.deviceConnectionLabelText
        let correctResult = "5 devices connected\n5 VeeaHubs in location"

        XCTAssertTrue(connectionLabel == correctResult)
    }

}
