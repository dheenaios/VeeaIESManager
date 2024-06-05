//
//  MeshAndHubRenameManager.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 24/05/2023.
//

import Foundation

public struct MeshAndHubRenameManager {

    public typealias SuccessAndOptionalMessage = (Bool, String?)


    /// Set the name of a mesh (or rename a mesh)
    /// This method does not check the validity of a mesh name.
    /// - Parameters:
    ///   - name: The name of the mesh
    ///   - meshId: the id of the mesh to be named or renamed
    /// - Returns: SuccessAndOptionalMessage tuple
    public static func setMeshName(_ name: String, for meshId: String) async -> SuccessAndOptionalMessage {
        let endpoint = "/enrollment/mesh/\(meshId)"
        let url = _GroupEndPoint(endpoint)

        let json: [String: Any] = ["meshName": name]
        do {
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            let request = await RequestFactory.authenticatedRequest(url: url,
                                                                    method: "PUT",
                                                                    body: jsonData)
            let result = try await URLSession.sendDataWith(request: request)

            if result.isHttpResponseGood {
                return (true, nil)
            }

            return (false, "Error: HTTP code: \(result.httpCode)")
        }
        catch {
            return (false, error.localizedDescription)
        }
    }


    /// Set the name of a hub (or rename a hub).
    /// This method does not check the validity of a hub name.
    /// - Parameters:
    ///   - name: The name of the hub
    ///   - serial: The serial of the hub
    /// - Returns: SuccessAndOptionalMessage tuple
    public static func setHubName(_ name: String, for serial: String) async -> SuccessAndOptionalMessage {
        let endpoint = "/enrollment/enroll/device/\(serial)"
        let url = _GroupEndPoint(endpoint)

        let json: [String: Any] = ["veeahubName": name]
        do {
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            let request = await RequestFactory.authenticatedRequest(url: url,
                                                                    method: "PUT",
                                                                    body: jsonData)
            let result = try await URLSession.sendDataWith(request: request)

            if result.isHttpResponseGood {
                return (true, nil)
            }

            return (false, "Error: HTTP code: \(result.httpCode)")
        }
        catch {
            return (false, error.localizedDescription)
        }
    }
}
