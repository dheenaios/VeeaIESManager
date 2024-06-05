//
//  UpdateProgressController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 24/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class UpdateProgressController {
    typealias UpdateProgressClosure = (MeshUpdateStatus?, MeshUpdateError?) -> Void
    private var savedCompletion: UpdateProgressClosure?
    private var lastUpdate: MeshUpdateStatus?
    
    func getUpdateProgress(meshId: String,
                           completion: @escaping UpdateProgressClosure) {
        savedCompletion = completion
        Task {
            await self.makeRequest(meshId: meshId)
        }
    }

    private func makeRequest(meshId: String) async {
        let url = _AppEndpoint("/mesh/\(meshId)/refreshStatus?limit=1")
        //print("URL: \(url)")

        let request = await RequestFactory.authenticatedRequest(url: url,
                                                                   method: "GET",
                                                                   body: nil)

        do {
            let result = try await URLSession.sendDataWith(request: request)
            guard let data = result.data else {
                self.savedCompletion?(nil, MeshUpdateError.noData(message: "No data returned"))
                return
            }

            let decoder = JSONDecoder()
            let response = try decoder.decode([MeshUpdateStatus].self, from: data)

            DispatchQueue.main.async {
                if response.isEmpty {
                    let e = MeshUpdateError.badlyFormedJson(message: "The response contained no entries")
                    self.savedCompletion?(nil, e)
                    return
                }

                self.savedCompletion?(response.first, nil)
                self.checkForUpdatesPeriodically(status: response.first!)
            }
        }
        catch {
            let e = MeshUpdateError.badlyFormedJson(message: error.localizedDescription)
            self.savedCompletion?(nil, e)
        }
    }
    
    private func checkForUpdatesPeriodically(status: MeshUpdateStatus) {
        self.lastUpdate = status
        if status.progressComplete {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if let meshId = self.lastUpdate?.meshId,
               let completion = self.savedCompletion {
                self.getUpdateProgress(meshId: meshId, completion: completion)
            }
        }
    }
}

// MARK: - Response objects
struct MeshUpdateStatus: Codable {
    let meshId: String
    let veeaHubSerialNumber: String
    let totalSteps: Int
    
    let progress: Float // The total progress as a percentage
    
    let steps: [MeshUpdateStep]
}

// MARK: - Helper vars
extension MeshUpdateStatus {
    var progressComplete: Bool {
        return lastStep?.step == totalSteps
    }
    
    var lastStep: MeshUpdateStep? {
        if steps.isEmpty { return nil }
        return steps.first
    }
    
    // Progress for the current step as a percentage
    var stepProgress: Float {
        guard let lastStep = lastStep else { return 0.0 }
        return lastStep.progress
    }
}

struct MeshUpdateStep: Codable {
    let step: Int
    let totalSteps: Int
    let isLastStep: Bool
    let progress: Float
    let description: String
}
