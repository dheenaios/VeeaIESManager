//
//  UpdateRequestController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 23/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class UpdateRequestController {
    
    static func requestUpdate(meshUUID: String,
                              packagesToUpdate: [PackagesWithUpdates],
                              completion: @escaping (Bool, MeshUpdateError?) -> Void) {
        var packages = [UpdatePackageId]()
        for package in packagesToUpdate {
            let m = UpdatePackageId(packageId: package.newPackageId)
            packages.append(m)
        }
        
        sendUpdateRequest(meshId: meshUUID,
                          packages: packages,
                          completion: completion)
    }
    
    private static func sendUpdateRequest(meshId: String,
                                          packages: [UpdatePackageId],
                                          completion: @escaping (Bool, MeshUpdateError?) -> Void) {
        
        URLRequest.getAuthToken { token in
            guard let token = token else {
                completion(false, MeshUpdateError.notAuthorised)
                return
            }
            
            makeRequest(token: token,
                        meshId: meshId,
                        packages: packages,
                        completion: completion)
        }
    }
    
    private static func makeRequest(token: String,
                                    meshId: String,
                                    packages: [UpdatePackageId],
                                    completion: @escaping (Bool, MeshUpdateError?) -> Void) {
        let url = _AppEndpoint("/subscription/mesh/\(meshId)/updateMesh")
        //print("URL: \(url)")
        
        
        let model = UpdatePackage(packages: packages)
        
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(model) else {
            completion(false, MeshUpdateError.badlyFormedJson(message: "Could not encode the request to update"))
            
            return
        }
        
        let request = RequestFactory.authenticatedRequest(url: url,
                                                   authToken: token,
                                                   method: "PATCH",
                                                   body: encoded)

        URLSession.sendDataWith(request: request) { result, error in
            guard let data = result.data else {
                completion(false, MeshUpdateError.badlyFormedJson(message: "Could not decode the server response"))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(UpdateRequestResponse.self, from: data)

                if let error = responseHasErrors(response: response) {
                    completion(true, error)
                    return
                }

                completion(true, nil)
            }
            catch {
                if let dict = data.toJson() {
                    if let meta = dict["meta"] as? [String : Any] {
                        if let status = meta["status"] as? Int,
                            let message = meta["message"] as? String {
                            completion(false, MeshUpdateError.unsuccessfulHttpResponse(httpCode: status,
                                                                                       message: message))
                        }
                        else {
                            completion(false, MeshUpdateError.badlyFormedJson(message: ""))
                        }
                    }
                }
            }
        }
    }
    
    private static func responseHasErrors(response: UpdateRequestResponse) -> MeshUpdateError? {
        guard let responseItems = response.response else {
            return .unsuccessfulHttpResponse(httpCode: response.meta.status,
                                             message: response.meta.message ?? "Unknown issue")
        }
        
        if response.meta.status != 200 {
            return .unsuccessfulHttpResponse(httpCode: response.meta.status,
                                             message: response.meta.message ?? "")
        }
        
        var fails = String()
        for responseItem in responseItems {
            let success = responseItem.succeeded ?? false
            
            if !success {
                if let operation = responseItem.operation {
                    fails.append("\(operation) did not succeed\n")
                }
                else if let message = responseItem.messages {
                    fails.append("Request did not succeed \(message)\n")
                }
                else {
                    fails.append("Request did not succeed")
                }
            }
        }
        
        if !fails.isEmpty {
            return .partialResponse(message: fails)
        }
        
        return nil
    }
}


// MARK: - Send objects
private struct UpdatePackage: Codable {
    let packages: [UpdatePackageId]
}

private struct UpdatePackageId: Codable {
    let packageId: String
}

// MARK: - Response objects
struct UpdateRequestResponse: Codable {
    let meta: ResponseMeta
    let response: [Response]?
}

struct Response: Codable {
    let operation: String?
    let succeeded: Bool?
    let serialNumber: String?
    let serialNumbers: [String]?
    let messages: String?
    
    let packageId: String?
}

