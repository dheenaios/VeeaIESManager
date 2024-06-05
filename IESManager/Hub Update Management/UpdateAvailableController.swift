//
//  UpdateAvailableController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/10/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

// VHM 871
// Is an update available
class UpdateAvailableController {
    static func getUpdateInfo(meshId: String,
                              completion: @escaping([PackagesWithUpdates]? ,MeshUpdateError?) -> Void) {
        URLRequest.getAuthToken { token in
            guard let token = token else {
                completion(nil, MeshUpdateError.notAuthorised)
                return
            }
            
            makeRequest(token: token,
                        meshId: meshId,
                        completion: completion)
        }
    }
    
    private static func makeRequest(token: String,
                                    meshId: String,
                                    completion: @escaping([PackagesWithUpdates]? ,MeshUpdateError?) -> Void) {
        let url = _AppEndpoint("/subscription/mesh/\(meshId)/availableUpdates")
        //print("URL: \(url)")
        
        let request = RequestFactory.authenticatedRequest(url: url,
                                                   authToken: token,
                                                   method: "GET",
                                                   body: nil)

        URLSession.sendDataWith(request: request) { result, error in
            guard let data = result.data else {
                completion(nil, MeshUpdateError.noData(message: error?.localizedDescription ?? "No data returned"))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(UpdateResponse.self, from: data)

                if !result.isHttpResponseGood {
                    let e = MeshUpdateError.unsuccessfulHttpResponse(httpCode: response.meta.status,
                                                                    message: response.meta.message ?? "Unknown")
                    completion(nil, e)
                    return
                }

                completion(response.availableUpdates, nil)
                return
            }
            catch {
                let e = MeshUpdateError.badlyFormedJson(message: error.localizedDescription)
                completion(nil, e)
                return
            }
        }
    }
}

/// The package information to be sent via the "subscription/update" call
struct PackagesWithUpdates: Codable {
    let newVersion: String
    let currentVersion: String
    let title: String
    let newPackageId: String
    let oldPackageId: String
    let type: String
}


// MARK: - Response structure
fileprivate struct UpdateResponse: Codable {
    let meta: ResponseMeta
    let response: UpdateResponseItem
    
    // Returns an empty array if there are no updates
    var availableUpdates: [PackagesWithUpdates] {
        var updates = [PackagesWithUpdates]()
        
        for update in response.updates {
            let u = PackagesWithUpdates(newVersion: update.available.version,
                                        currentVersion: update.applied.version,
                                        title: update.available.title,
                                        newPackageId: update.available.packageId,
                                        oldPackageId: update.applied.packageId,
                                        type: update.applied.title)
            updates.append(u)
        }
        
        return updates
    }
}

fileprivate struct UpdateResponseItem: Codable {
    let updates: [Packages]
}

fileprivate struct Packages: Codable {
    let available: PackageInfo
    let applied: PackageInfo
}

fileprivate struct PackageInfo: Codable {
    let packageId: String
    let title: String
    let version: String
}
