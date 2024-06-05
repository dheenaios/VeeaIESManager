//
//  HomeHubEnrollmentModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 01/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

struct HomeHubEnrollmentModel {
    
    private let prefix = "STAX"
    private var initialPsk = PasswordGenerator().newPassword()
    private var initialGuestPsk = PasswordGenerator().newPassword()
    
    var hubQrCode: String?
    
    // The initial default name of the hub.
    // This will be changed by the user on the locations page.
    var defaultName: String? {
        guard let hubQrCode = hubQrCode else { return nil }
        return QrCodeParser.getDefaultDeviceName(from: hubQrCode)
    }
    
    /// The serial number of the hub taken from the QR code
    var serial: String? {
        guard let hubQrCode = hubQrCode else { return nil }
        return QrCodeParser.getSerielNumberOfDevice(from: hubQrCode)
    }
    
    /// The model name of the hub, taken from the QR code
    var model: String? {
        guard let hubQrCode = hubQrCode else {
            return nil
        }

        let model = VeeaHubHardwareModel(qrCode: hubQrCode)
        return String(describing: model)
    }
    
    /// The version of this application
    private var version: String {
        return VeeaKit.versions.application
    }
    
    
    var owner: String?
    
    /// The Group the hub being enrolled belongs too
    var group: GroupModel?
    
    /// The location of the hub ("Living Room"). This becomes the name of the hub went we send
    var name: String?


    // MARK: - Wifi
    
    var primarySsid = ""
    var primaryPsk = ""
    var guestSsid = ""
    var guestPsk = ""
    var guestNetworkIsOn = false
    
    mutating func clearWifiSettings() {
        primarySsid = ""
        primaryPsk = ""
        guestSsid = ""
        guestPsk = ""
    }
    
    // MARK: - MESH
    
    // Are we adding or creating the mesh
    var meshName: String?
    private var enrollmentType: EnrollMeshType?
    private var meshId: String = ""
    
    /// Set the mesh detail
    /// - Parameters:
    ///   - type: Create or add too
    ///   - name: The name of the mesh
    ///   - meshId: the ID of the mesh. Send in "" for new meshes
    mutating func setMesh(type: EnrollMeshType,
                 name: String,
                 meshId: String) {
        self.enrollmentType = type
        self.meshName = name
        self.meshId = meshId
    }
    
    var enrollMesh: Enrollment.EnrollMesh {
        var m = Enrollment.EnrollMesh()
        m.id = meshId
        m.name = meshName!
        m.type = enrollmentType!
        
        return m
    }
    
    /// A name for the mesh based on the hubs id. Requires the QR code
    var defaultMeshName: String? {
        guard let defaultName = defaultName else { return nil }
        return "Home-Vmesh-\(defaultName)"
    }
}

// MARK: - Sending data
extension HomeHubEnrollmentModel {
    var enrollmentPackage: Enrollment {
        var e = Enrollment()
        e.group = owner
        e.code = hubQrCode
        e.name = name
        e.version = version
        e.ssid = primarySsid
        e.password = primaryPsk
        e.guestSsid = guestSsid
        e.guestPassword = guestPsk
        e.guestEnabled = guestNetworkIsOn
        e.model = model ?? ""
        e.groupName = group?.name ?? ""
        e.serialNumber = serial ?? ""
        e.mesh = enrollMesh
        e.timezoneArea = nil
        e.timezoneRegion = nil
        e.country = nil
        
        return e
    }
    
    func sendEnrollmentData(completion: @escaping(SuccessAndOptionalMessage) -> Void) {
        AnalyticsEventHelper.recordDeviceEnrollmentStart(deviceId: self.enrollmentPackage.code)
        EnrollmentService.startEnrollment(data: self.enrollmentPackage, success: {
            DispatchQueue.main.async {
                AnalyticsEventHelper.recordDeviceEnrollmentSuccess(deviceId: self.enrollmentPackage.code)
                completion((true, nil))
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                AnalyticsEventHelper.recordDeviceEnrollmentFailed(deviceId: self.enrollmentPackage.code, reason: err)
                completion((false, err))
            }
        } errData: { (errorMeta) in
//            self.showErrorHandlingAlert(title: errorMeta.title ?? "", message: errorMeta.message ?? "", suggestions: errorMeta.suggestions ?? [])
        }
    }
}

// MARK: - Helpers for displaying Wi-Fi SSID and PSK values
extension HomeHubEnrollmentModel {
    
    /// The SSID that should be displayed in the wifi hub seleciton page
    var displayWifiSsid: String {
        if primarySsid.isEmpty {
            let n = defaultName!
            return "\(prefix)-\(n)-Wifi"
        }
        
        return primarySsid
    }
    
    /// The psk that should be displayed in the wifi hub seleciton page
    var displayWifiPsk: String {
        if primaryPsk.isEmpty {
            return initialPsk
        }
        
        return primaryPsk
    }
    
    /// The Guest SSID that should be displayed in the wifi hub seleciton page
    var displayGuestWifiSsid: String {
        if guestSsid.isEmpty {
            let n = defaultName!
            return "\(prefix)-\(n)-Guest"
        }
        
        return guestSsid
    }
    
    /// The Guest PSK  that should be displayed in the wifi hub seleciton page
    var displayGUESTWifiPsk: String {
        if guestPsk.isEmpty {
            return initialGuestPsk
        }
        
        return guestPsk
    }
}
