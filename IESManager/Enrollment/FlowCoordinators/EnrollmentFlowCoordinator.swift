//
//  EnrollmentFlowCoordinator.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 2/1/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

@objc protocol EnrollmentFlowDelegate {
    func next()
    func cancelEnrollment()
    func completeEnrollment()
}

class EnrollmentFlowCoordinator: VUIViewController {
    
    private enum CurrentScreen: String {
        case addDevice = "Add VeeaHub"
        case authenticateDevice = "Authenticate VeeaHub"
        case nameYourDevice = "Name Your VeeaHub"
        case selectGroup = "Select a group"
        case selectMesh = "Select Mesh"
        case nameMesh = "Name Mesh"
        case setWifi = "Set Wi-Fi"
        case selectRegion = "Select Region"
        case confirmSettings = "Confirm Settings"
    }
    
    private var currentScreen: CurrentScreen? {
        didSet {
            //print("Current screen: " + (currentScreen?.rawValue ?? "Nothing set"))
        }
    }
    
    var enrollmentData: Enrollment = Enrollment()
    var meshes: [VHMesh]?
    private var selectedGroup : GroupModel!
    var groupDetailsVM : GroupDetailsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedGroup = self.groupDetailsVM.groupData
        self.enrollmentData.groupName = self.groupDetailsVM.hasMultipleGroups ? self.selectedGroup.displayName : ""
        // Navigation item
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                           target: self,
                                           action: #selector(EnrollmentFlowCoordinator.cancel))
        self.navigationItem.rightBarButtonItem = cancelButton
        
        self.start()
    }
    
    func start() {
        let welcomeVC = AddDeviceWelcomeViewController()
        currentScreen = CurrentScreen.addDevice
        welcomeVC.flowDelegate = self
        self.add(welcomeVC)
    }
    
    // MARK: - Private helpers
    fileprivate func setMeshData(type: EnrollMeshType, name: String) {
        var meshData = Enrollment.EnrollMesh()
        meshData.name = name
        meshData.type = type
        self.enrollmentData.mesh = meshData
    }
    
    // MARK:- Navigation Helpers
    @objc func cancel() {
        AnalyticsEventHelper.recordUserEnrollmentCancelled(screenName: currentScreen?.rawValue.localized() ?? "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAuthenticationView() {
        let authVC = AuthenticateDeviceViewController()
        currentScreen = CurrentScreen.authenticateDevice
        authVC.delegate = self
        self.show(authVC, sender: self)
    }
    
    func showNamingView(_ type: NamingViewType) {
        let vm = NamingViewViewModel(type: type, groupId: self.selectedGroup.id)
        let namingVC = NamingViewController(vm: vm)
        currentScreen = CurrentScreen.nameYourDevice
        namingVC.delegate = self
        self.show(namingVC, sender: self)
    }
    
    func showMeshListView() {
        let meshVC = SelectMeshViewController(meshes: self.meshes ?? [])
        currentScreen = CurrentScreen.selectMesh
        meshVC.delegate = self
        self.show(meshVC, sender: self)
    }
    
    func showTimezoneView() {
        let timezoneLoader = TimeZonesLoader()

        let regionVC = SelectLocationViewController(timezone: timezoneLoader.defaultUserTimeZone, country: timezoneLoader.defaultCountryCode)
        regionVC.delegate = self
        currentScreen = CurrentScreen.selectRegion
        self.show(regionVC, sender: self)
    }
    
    func showDefaultWifiSettings() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "DefaultWifiStoryboard", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "DefaultWifiViewController") as? DefaultWifiViewController {
            vc.delegate = self
            vc.delegateForEnrollmentData = self
            self.show(vc, sender: self)
        }
    }
    
    func showEnrollmentSettings() {
        self.show(ConfirmEnrollmentSettingsViewController(settings: self.enrollmentData, delegate: self), sender: self)
    }
    
    func showConnectDevice() {
        let vc = ConnectDeviceViewController()
        vc.flowDelegate = self
        self.show(vc, sender: self)
    }
}

// MARK: - EnrollmentFlowDelegate
extension EnrollmentFlowCoordinator: EnrollmentFlowDelegate {
    func next() {
        self.showAuthenticationView()
    }
    
    func cancelEnrollment() {
        self.cancel()
    }
    
    func completeEnrollment() {
        if let tabVC = self.presentingViewController as? MainTabViewController {
            tabVC.selectedIndex = 0
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - AuthenticateDeviceDelegate
extension EnrollmentFlowCoordinator: AuthenticateDeviceDelegate {
    func didAuthenticateDevice(with code: String) {
        self.enrollmentData.code = code
        self.enrollmentData.name = QrCodeParser.getDefaultDeviceName(from: code)
        self.enrollmentData.serialNumber = QrCodeParser.getSerielNumberOfDevice(from: code)
        let model = VeeaHubHardwareModel(qrCode: code)
        self.enrollmentData.model = String(describing: model)
        self.showNamingView(.device)
    }
}

// MARK: - NamingDeviceMeshDelegate
extension EnrollmentFlowCoordinator: NamingDeviceMeshDelegate {
    func didNameDevice(name: String, meshesAvailable: [VHMesh], groupId: String) {
        self.enrollmentData.name = name
        self.enrollmentData.group = groupId
        self.enrollmentData.version = VeeaKit.versions.application

        guard let meshes else {
            self.showNamingView(.mesh)
            return
        }

        if meshes.isEmpty {
            self.showNamingView(.mesh)
        }
        else {
            self.showMeshListView()
        }
    }
    
    func didNameMesh(name: String) {
        self.setMeshData(type: .create, name: name)
        self.enrollmentData.mesh.id = ""
        self.showDefaultWifiSettings()
    }
}

// MARK: - MeshSelectorDelegate
extension EnrollmentFlowCoordinator: MeshSelectorDelegate {
    func didChooseMesh(with mesh: VHMesh) {
        self.setMeshData(type: .addTo, name: mesh.name)
        self.enrollmentData.mesh.id = mesh.id
        self.enrollmentData.timezoneArea = mesh.timezoneArea
        self.enrollmentData.timezoneRegion = mesh.timezoneRegion
        self.enrollmentData.country = mesh.country
        self.showEnrollmentSettings()
    }
    
    func createNewMesh() {
        self.showNamingView(.mesh)
    }
}

// MARK: - TimezoneSelectorDelegate
extension EnrollmentFlowCoordinator: LocationSelectorDelegate {
    func didSelectLocation(region: String, area: String, countryCode: String) {
        self.enrollmentData.timezoneRegion = region
        self.enrollmentData.timezoneArea = area
        self.enrollmentData.country = countryCode
        self.showEnrollmentSettings()
    }
}

// MARK: - Default Wifi and Password
extension EnrollmentFlowCoordinator: DefaultWifiViewControllerDelegate {
    func didSelectSsidName(name: String, password: String, ssid_2_4: String, password_2_4: String, ssid_5: String, password_5: String, optedBothBool: Bool) {
        self.enrollmentData.ssid = name
        self.enrollmentData.password = password
        self.enrollmentData.ssid_2_4ghz = ssid_2_4
        self.enrollmentData.password_2_4ghz = password_2_4
        self.enrollmentData.ssid_5ghz = ssid_5
        self.enrollmentData.password_5ghz = password_5
        self.enrollmentData.user_aps = 2
        self.showTimezoneView()
    }
    
    func didSelectSsidName(name: String, password: String) {
        self.enrollmentData.ssid = name
        self.enrollmentData.password = password
        self.showTimezoneView()
    }
    
    func userDidSkip() {
        self.enrollmentData.user_aps = 0
        self.showTimezoneView()
    }
    
    func userDidSetDefaultWifiPassword(name: String, password: String, ssid_2_4: String, password_2_4: String, ssid_5: String, password_5: String, optedBothBool: Bool) {
        let name = NamingViewViewModel.nameGeneratorForDefaultWifiCredentials(serial: self.enrollmentData.code)
        self.enrollmentData.ssid = name
        self.enrollmentData.password = password
        self.enrollmentData.ssid_2_4ghz = ssid_2_4
        self.enrollmentData.password_2_4ghz = password_2_4
        self.enrollmentData.ssid_5ghz = ssid_5
        self.enrollmentData.password_5ghz = password_5
        self.enrollmentData.user_aps = 2
        self.showTimezoneView()
    }
}

// MARK: - ConfirmEnrollmentSettingsDelegate
extension EnrollmentFlowCoordinator: ConfirmEnrollmentSettingsDelegate {
    func confirmSettings() {
        self.showConnectDevice()
    }
}
