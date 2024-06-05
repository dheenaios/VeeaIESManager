//
//  EnrollmentEndpoint.swift
//  IESManager
//
//  Created by Richard Stockdale on 20/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

public enum EnrollmentEndpoint {
    case checkDevice
    case checkDeviceName
    case checkMeshName

    case enrollStart
    case enrollmentStatus(String)
    case getProcessingVeeaHubs
    case getProcessingVeeaHubsOfOwner(String)
    case enrollPackages
    case unvailableNodes
    case userConfig(Int64)
    case ownerConfig(String)
    case getMeshStatus(String)
    case getDeviceStatus(String)


    public var value: String {
        var path = ""
        switch self {
        case .checkDevice:
            path = "/check/device/code"
        case .checkDeviceName:
            path = "/check/owner/device/name"
        case .checkMeshName:
            path = "/check/owner/mesh/name"
        case .enrollStart:
            path = "/enroll/start"
        case .enrollmentStatus(let deviceId):
            path = "/enroll/status/" + deviceId
        case .enrollPackages:
            path = "/enroll/packages"
        case .unvailableNodes:
            path = "/enroll/device/processing"
        case .userConfig(let userId):
            path = "/enroll/user/\(userId.description)/config"
        case .ownerConfig(let ownerId):
            path = "/enroll/owner/\(ownerId)/config"
        case .getProcessingVeeaHubs:
            path = "/enroll/device/processing"
        case .getProcessingVeeaHubsOfOwner(let ownerId) :
            path = "/enroll/\(ownerId)/processing"
        case .getMeshStatus(let messId) :
            path = "/mesh/\(messId)/status"
        case .getDeviceStatus(let deviceId) :
            path = "/device/\(deviceId)/status"


        }
        return _AppEndpoint(path)
    }
}
