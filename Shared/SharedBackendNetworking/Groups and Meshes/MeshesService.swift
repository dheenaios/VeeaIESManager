//
//  MeshesService.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 20/06/2022.
//

import Foundation

fileprivate struct UserConfigResponse: Codable {
    let ownerId: String!
    let meshes: [MeshModel]?
}


/// Gets the details of the mesh for home users and returns a list of devices. Only to be used with Widgets and home users (where there
/// will only be a single mesh
public class MeshService {
    public static func getDevicesForSoleMesh(groupId : String, success: @escaping (_ nodes: [NodeModel]?, String?) -> Void, error: @escaping ErrorCallback) {
        do {
            let url = EnrollmentEndpoint.ownerConfig(groupId).value

            let request = try VKHTTPRequest.create(url: url)
            try VKHTTPManager.call(request: request, result: { (rStatus, rData, rError, errData) in
                if let response = VKDecoder.decode(type: UserConfigResponse.self, data: rData) {
                        if rStatus {
                            if let mesh = response.meshes?.first {
                                success(mesh.devices, nil)
                                return
                            }
                        }
                }
                success(nil, "Decoding error node response")
                error(VKHTTPManagerError.parseError(error: rError))
            })
        } catch let e {
            error(e.localizedDescription)
            success(nil, "Error: \(error(e.localizedDescription))")
        }
    }
}

public struct SimplifedMesh: Codable, Equatable {

    static public func == (lhs: SimplifedMesh, rhs: SimplifedMesh) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.devices == rhs.devices
    }

    let id: String!
    let name: String!
    var devices: [NodeModel]
}
