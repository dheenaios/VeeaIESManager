//
//  Enrollment.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/17/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

enum EnrollMeshType: String, Codable {
    case create
    case addTo
}

enum ConnectionType: String, Codable {
    case ethernet
    
    var stringValue: String {
        switch self {
        case .ethernet:
            return "Wired".localized()
        }
    }
}

struct Enrollment: Codable {
    
    var group: String!
    var code: String!
    var name: String!
    var mesh: EnrollMesh!
    var connection = Connection()
    var version: String!
    var package: String = ""
    
    var timezoneRegion: String?
    var timezoneArea: String?
    var country: String?
    
    var ssid: String?
    var password: String?
    var ssid_2_4ghz: String?
    var password_2_4ghz: String?
    var ssid_5ghz: String?
    var password_5ghz: String?
    var user_aps: Int?
    
    
    var guestSsid: String?
    var guestPassword: String?
    @DecodableDefault.False var guestEnabled: Bool
    
    var model = "VeeaHub"
    var groupName = ""
    var serialNumber = ""

    var hardwareModel: VeeaHubHardwareModel { VeeaHubHardwareModel(serial: serialNumber) }
    
    struct EnrollMesh: Codable {
        var id: String?
        var type: EnrollMeshType!
        var name: String!
    }
    
    struct Connection: Codable {
        var type: ConnectionType = .ethernet
    }
    
    enum CodingKeys: String, CodingKey {
        case group
        case code
        case name
        case mesh
        case connection
        case version
        case package
        case ssid
        case password
        case ssid_2_4ghz
        case password_2_4ghz
        case ssid_5ghz
        case password_5ghz
        case user_aps
        case guestSsid = "guest_ssid"
        case guestPassword = "guest_password"
        case guestEnabled = "guest_enabled"
        case timezoneRegion = "nc_node_timezone_region"
        case timezoneArea = "nc_node_timezone_area"
        case country = "nc_node_country"
    }
}
