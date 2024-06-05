//
//  PatchConfigCall.swift
//  MAS API
//
//  Created by Richard Stockdale on 01/09/2020.
//  Copyright © 2020 Richard Stockdale. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class MasApiPatchConfigCall {
    
    let patchData: Data
    let tableName: String
    
    let masConnection: MasConnection
    
    init(patchData: Data, masConnection: MasConnection, tableName: String) {
        self.patchData = patchData
        self.masConnection = masConnection
        self.tableName = tableName
    }
    
    func makeCall(completion: @escaping (Bool, String) -> Void) {
        Task {
            let request = await makeRequest()

            URLSession.sendDataWith(request: request) { result, error in
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }

                guard let data = result.data else {
                    completion(false, "No data returned")
                    return
                }

                print(String(data: data, encoding: .utf8)!)

                guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] else {
                    completion(false, "Could not cast data to Dictionary")
                    return
                }

                guard let success = json["success"] as? Bool, let message = json["message"] as? String else {
                    completion(false, "Unexpected data structure. Keys not found")
                    return
                }

                completion(success, message)
            }
        }
    }

    private func makeRequest() async -> URLRequest {
        let url = masConnection.urlFor(tableName: tableName)
        //print("URL to send too... \(url)")

        var request = URLRequest(url: URL(string: url)!, timeoutInterval: Double.infinity)
        request.httpMethod = "PATCH"
        request.httpBody = patchData
        await request.addUpdateAuthToken()

        return request
    }
}
