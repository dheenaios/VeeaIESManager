//
//  EnrollmentService.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/22/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking


typealias Callback = () -> Void

class EnrollmentService {
        
    /** Check if a device is ready to be enrolled */
    class func checkDevice(with code: String, success: @escaping Callback, error: @escaping ErrorCallback) {
        do {
            let urlPath = EnrollmentEndpoint.checkDevice.value
            let data = ["version": VeeaKit.versions.application, "code": code]
            let encoded = try JSONEncoder().encode(data)
            let request = try VKHTTPRequest.create(url: urlPath, type: .post, data: encoded)
            try VKHTTPManager.call(request: request) { (rStatus, rData, rError) in
                if rStatus {
                    success()
                    return
                }
                
                error(VKHTTPManagerError.parseError(error: rError))
                
            }
        } catch let e {
            error(e.localizedDescription)
        }
    }
    
    /** Checks if the name for the device is acceptable */
    class func checkDeviceName(groupId : String, name deviceName: String, success: @escaping ([VHMesh], String) -> Void, error: @escaping ErrorCallback) {
        do {
            let urlPath = EnrollmentEndpoint.checkDeviceName.value
            let encoded = try JSONEncoder().encode(["version": VeeaKit.versions.application, "name": deviceName, "ownerId" : groupId])
            let request = try VKHTTPRequest.create(url: urlPath, type: .post, data: encoded)
            try VKHTTPManager.call(request: request, result: { (rStatus, rData, rError) in
                if rStatus {
                    let response = VKDecoder.decode(type: CheckDeviceNameResponse.self, data: rData)
                    if response != nil {
                        success(response!.meshes, response?.owner ?? "")
                        return
                    }
                }
                
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }
    
    /** Checks if the mesh name is acceptable */
    class func checkMeshName(groupId : String, name meshName: String, success: @escaping Callback, error: @escaping ErrorCallback) {
        do {
            let urlPath = EnrollmentEndpoint.checkMeshName.value
            let encoded = try JSONEncoder().encode(["version": VeeaKit.versions.application, "name": meshName, "ownerId" : groupId])
            let request = try VKHTTPRequest.create(url: urlPath, type: .post, data: encoded)
            try VKHTTPManager.call(request: request, result: { (rStatus, rData, rError) in
                if rStatus {
                    success()
                    return
                }
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }
    
    class func startEnrollment(data: Enrollment, success: @escaping Callback, error: @escaping ErrorCallback) {
        do {
            let url = EnrollmentEndpoint.enrollStart.value
            let encoded = try JSONEncoder().encode(data)
            let request = try VKHTTPRequest.create(url: url, type: .post, data: encoded)
            try VKHTTPManager.call(request: request, result: { (rStatus, rData, rError) in
                if rStatus && rData != nil {
                    
                    let _ = VKDecoder.decode(type: EnrollStartResponse.self, data: rData!)
                    success()
                    return
                }
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
        }
        
    }
    
    @available(*, deprecated, message: "Use getProcessingVeeaHubsOfCurrentGroups instead")
    class func getProcessingVeeaHubs(success: @escaping ([EnrollStatusModel]) -> Void, error: @escaping ErrorCallback) {
        do {
            let url = EnrollmentEndpoint.getProcessingVeeaHubs.value
            // UserSessionManager.shared.currentUserId.int
            let request = try VKHTTPRequest.create(url: url, type: .get)
            try VKHTTPManager.call(request: request, result: { (status, rData, rError) in
                if status && rData != nil {
                    
                    if let devicesEnrollStatus = VKDecoder.decode(type: [EnrollStatusModel].self, data: rData) {
                        success(devicesEnrollStatus)
                        return
                    }
                }
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }
    
    class func getProcessingVeeaHubsOfForGroup(groupId : String, success: @escaping ([EnrollStatusModel]) -> Void, error: @escaping ErrorCallback) {
        do {
            let url = EnrollmentEndpoint.getProcessingVeeaHubsOfOwner(groupId).value
            let request = try VKHTTPRequest.create(url: url, type: .get)
            try VKHTTPManager.call(request: request, result: { (status, rData, rError) in
                if status && rData != nil {
                    
                    if let devicesEnrollStatus = VKDecoder.decode(type: [EnrollStatusModel].self, data: rData) {
                        success(devicesEnrollStatus)
                        return
                    }
                }
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }
    
    class func getEnrollmentStatus(deviceId: String, success: @escaping (EnrollStatusModel) -> Void, error: @escaping ErrorCallback) {
        do {
            let url = EnrollmentEndpoint.enrollmentStatus(deviceId).value
            let encoded = try JSONEncoder().encode(["version": VeeaKit.versions.application])
            let request = try VKHTTPRequest.create(url: url, type: .post, data: encoded)
            try VKHTTPManager.call(request: request, result: { (status, rData, rError) in
                if status && rData != nil {
                    if let enrollStatus = VKDecoder.decode(type: EnrollStatusModel.self, data: rData) {
                        success(enrollStatus)
                        return
                    }
                }
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }
    
    class func getPackages(success: @escaping ([VHPackage]) -> Void, error: @escaping ErrorCallback) {
        
        do {
            let url = EnrollmentEndpoint.enrollPackages.value
            let request = try VKHTTPRequest.create(url: url)
            try VKHTTPManager.call(request: request, result: { (status, rData, rError) in
                if status {
                    if let packages = VKDecoder.decode(type: [VHPackage].self, data: rData) {
                        success(packages)
                        return
                    }
                }
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }

    @available(*, deprecated, message: "Use getOwnerConfig instead")
    class func getUserConfig(success: @escaping (_ beacon: VHBeacon?, _ meshes: [VHMesh]?) -> Void, error: @escaping ErrorCallback) {
        do {
            let url = EnrollmentEndpoint.userConfig(UserSessionManager.shared.currentUserId.int).value
            let request = try VKHTTPRequest.create(url: url)
            try VKHTTPManager.call(request: request, result: { (rStatus, rData, rError) in
                if let response = VKDecoder.decode(type: UserConfigResponse.self, data: rData) {
                    if rStatus {
                        success(response.beacons?.first, response.meshes)
                        return
                    }
                }
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }
    
    class func getOwnerConfig(groupId : String? = nil, success: @escaping (_ beacon: VHBeacon?, _ meshes: [VHMesh]?) -> Void, error: @escaping ErrorCallback) {
        do {
            let url = groupId != nil ? EnrollmentEndpoint.ownerConfig(groupId!).value : EnrollmentEndpoint.ownerConfig(UserSessionManager.shared.currentOwnerId).value
            
            let request = try VKHTTPRequest.create(url: url)
            try VKHTTPManager.call(request: request, result: { (rStatus, rData, rError) in
                if let response = VKDecoder.decode(type: UserConfigResponse.self, data: rData) {
                    if rStatus {
                        success(response.beacons?.first, response.meshes)
                        return
                    }
                }
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }
    
}
