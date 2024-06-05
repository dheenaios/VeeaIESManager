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
typealias ErrorCallback = (_ message: String) -> Void

typealias ErrorCallbackWithData = (_ data: ErrorHandlingData) -> Void

class EnrollmentService {
        
    /** Check if a device is ready to be enrolled */
    class func checkDevice(with code: String, success: @escaping Callback, error: @escaping ErrorCallback, errData: @escaping ErrorCallbackWithData) {
        do {
            let urlPath = EnrollmentEndpoint.checkDevice.value
            let data = ["version": VeeaKit.versions.application, "code": code]
            let encoded = try JSONEncoder().encode(data)
            let request = try VKHTTPRequest.create(url: urlPath, type: .post, data: encoded)
            try VKHTTPManager.call(request: request) { (rStatus, rData, rError, errorData) in
                if rStatus {
                    success()
                    return
                }
                if (errorData?.title == "" &&  errorData?.suggestions?.count == 0) {
                    error(VKHTTPManagerError.parseError(error: rError))
                }else{
                    errData(errorData!)
                }
            }
        } catch let e {
            error(e.localizedDescription)
        }
    }
    

    /// Checks if the name for the device is acceptable
    /// - Parameters:
    ///   - groupId: The group id
    ///   - deviceName: the device name
    ///   - success: success colosure. Note that mesh info will only be correct for top level groups.
    ///   Lower level groups will return an empty meshes array
    ///   - error: Error closure
    class func checkDeviceName(groupId : String, name deviceName: String, success: @escaping ([VHMesh], String) -> Void, error: @escaping ErrorCallback, errData: @escaping ErrorCallbackWithData) {
        do {
            let urlPath = EnrollmentEndpoint.checkDeviceName.value
            let encoded = try JSONEncoder().encode(["version": VeeaKit.versions.application, "name": deviceName, "ownerId" : groupId])
            let request = try VKHTTPRequest.create(url: urlPath, type: .post, data: encoded)
            try VKHTTPManager.call(request: request, result: { (rStatus, rData, rError, errorData) in
                if rStatus {
                    let response = VKDecoder.decode(type: CheckDeviceNameResponse.self, data: rData)
                    if response != nil {
                        success(response!.meshes, response?.owner ?? "")
                        return
                    }
                }
                if (errorData?.title == "" &&  errorData?.suggestions?.count == 0) {
                    error(VKHTTPManagerError.parseError(error: rError))
                }
                else {
                    errData(errorData!)
                }
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }
    
    /** Checks if the mesh name is acceptable */
    class func checkMeshName(groupId : String, name meshName: String, success: @escaping Callback, error: @escaping ErrorCallback, errData: @escaping ErrorCallbackWithData) {
        do {
            let urlPath = EnrollmentEndpoint.checkMeshName.value
            let encoded = try JSONEncoder().encode(["version": VeeaKit.versions.application, "name": meshName, "ownerId" : groupId])
            let request = try VKHTTPRequest.create(url: urlPath, type: .post, data: encoded)
            try VKHTTPManager.call(request: request, result: { (rStatus, rData, rError, errorData) in
                if rStatus {
                    success()
                    return
                }
                if (errorData?.title == "" &&  errorData?.suggestions?.count == 0) {
                    error(VKHTTPManagerError.parseError(error: rError))
                }
                else {
                    errData(errorData!)
                }
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }

    class func checkMeshName(groupId : String,
                             name meshName: String) async -> (Bool, String?) {
        do {
            let urlPath = EnrollmentEndpoint.checkMeshName.value
            let encoded = try JSONEncoder().encode(["version": VeeaKit.versions.application, "name": meshName, "ownerId" : groupId])
            let request = try VKHTTPRequest.create(url: urlPath, type: .post, data: encoded)

            let result = try await VKHTTPManager.call(request: request)
            if result.0 {
                return (true, nil)
            }

            return (false, VKHTTPManagerError.parseError(error: result.2))

        } catch let e {
            return (false, VKHTTPManagerError.parseError(error: e))
        }
    }
    
    class func startEnrollment(data: Enrollment, success: @escaping Callback, error: @escaping ErrorCallback, errData: @escaping ErrorCallbackWithData) {
        do {
            let url = EnrollmentEndpoint.enrollStart.value
            let encoded = try JSONEncoder().encode(data)
            let request = try VKHTTPRequest.create(url: url, type: .post, data: encoded)
            try VKHTTPManager.call(request: request, result: { (rStatus, rData, rError, errorData) in
                if rStatus && rData != nil {
                    let _ = VKDecoder.decode(type: EnrollStartResponse.self, data: rData!)
                    success()
                    return
                }
                if (errorData?.title == "" &&  errorData?.suggestions?.count == 0) {
                    error(VKHTTPManagerError.parseError(error: rError))
                }
                else {
                    errData(errorData!)
                }
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
            try VKHTTPManager.call(request: request, result: { (status, rData, rError, errorData) in
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
            try VKHTTPManager.call(request: request, result: { (status, rData, rError, errorData) in
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
    
    class func getEnrollmentStatus(deviceId: String, success: @escaping (EnrollStatusModel) -> Void, error: @escaping ErrorCallback, errData: @escaping ErrorCallbackWithData) {
        do {
            let url = EnrollmentEndpoint.enrollmentStatus(deviceId).value
            let encoded = try JSONEncoder().encode(["version": VeeaKit.versions.application])
            let request = try VKHTTPRequest.create(url: url, type: .post, data: encoded)
            try VKHTTPManager.call(request: request, result: { (status, rData, rError, errorData) in
                if status && rData != nil {
                    if let enrollStatus = VKDecoder.decode(type: EnrollStatusModel.self, data: rData) {
                        success(enrollStatus)
                        return
                    }
                }
                if (errorData?.title == "" &&  errorData?.suggestions?.count == 0) {
                    error(VKHTTPManagerError.parseError(error: rError))
                }
                else {
                    errData(errorData!)
                }
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }

    /// Get users mesh details
    /// - Parameter groupId: The group ID. If nothing is passed in the UserSessionManager owner Id is used
    /// - Returns: An array of VMeshs if successful. If not a error message string
    class func getOwnerConfig(groupId: String, success: @escaping (_ meshes: [VHMesh]?) -> Void, error: @escaping ErrorCallback) {
        do {
            let url = EnrollmentEndpoint.ownerConfig(groupId).value
            
            let request = try VKHTTPRequest.create(url: url)
            try VKHTTPManager.call(request: request, result: { (rStatus, rData, rError, errorData) in
                if let response = VKDecoder.decode(type: UserConfigResponse.self, data: rData) {
                    if rStatus {
                        saveBeaconInfo(response: response, groupId: groupId) // For the test screen
                        let updatedResponse = addBeaconsToMesh(response: response)

                        success(updatedResponse.meshes)
                        return
                    }
                }
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
        }
    }

    /// Async version of get owner.
    /// - Parameter groupId: The group to be queried
    /// - Returns: A tuple with an optinal VMesh array. A string optional, which is only populated
    /// if an error is encountered
    class func getOwnerConfig(groupId : String) async -> ([VHMesh]?, String?) {
        let url = EnrollmentEndpoint.ownerConfig(groupId).value

        do {
            let request = try VKHTTPRequest.create(url: url)
            let callResponse = try await VKHTTPManager.call(request: request)
            if let response = VKDecoder.decode(type: UserConfigResponse.self, data: callResponse.1) {
                saveBeaconInfo(response: response, groupId: groupId) // For the test screen
                let updatedResponse = addBeaconsToMesh(response: response)

                return (updatedResponse.meshes, nil)
            }
        }
        catch {
            return (nil, error.localizedDescription)
        }

        return (nil, "Call to Get owner config failed.")
    }

    private class func addBeaconsToMesh(response: UserConfigResponse) -> UserConfigResponse {
        guard var meshes = response.meshes,
              let beacons = response.beacons else {
            Logger.log(tag: "EnrollmentService",
                       message: "Enrollment service did not return meshes and beacon info")

            return response
        }

        if meshes.count != beacons.count {
            Logger.log(tag: "EnrollmentService",
                       message: "Enrollment service did not return equal meshes(\(meshes.count)) and beacons(\(beacons.count) (1)")
            return response
        }

        for (index, beacon) in beacons.enumerated() {
            meshes[index].beacon = beacon
        }

        let updatedResponse = UserConfigResponse(ownerId: response.ownerId,
                                                 meshes: meshes,
                                                 mas: response.mas,
                                                 beacons: beacons)
        return updatedResponse
    }

    private class func saveBeaconInfo(response: UserConfigResponse, groupId: String) {
        guard let meshes = response.meshes,
              let beacons = response.beacons else {
            Logger.log(tag: "EnrollmentService",
                       message: "Enrollment service did not return meshes and beacon info(1)")
            return
        }

        if meshes.count != beacons.count {
            Logger.log(tag: "EnrollmentService",
                       message: "Enrollment service did not return equal meshes(\(meshes.count)) and beacons(\(beacons.count)")
            return
        }

        var identifiedBeacons = [VHBeacon]()
        for (index, var beacon) in beacons.enumerated() {
            let mesh = meshes[index]
            beacon.groupId = groupId
            beacon.meshId = mesh.id
            beacon.meshName = mesh.name

            identifiedBeacons.append(beacon)
        }

        UserSettings.beacons = identifiedBeacons
    }
    
}
