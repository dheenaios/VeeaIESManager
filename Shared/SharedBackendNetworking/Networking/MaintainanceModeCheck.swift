//
//  MaintainanceModeCheck.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 01/09/2022.
//

import Foundation


public struct MaintainanceModeCheck {

    private let endPoint = "/enrollment/health"


    /// Checks if the backend is in maintainance mode
    /// - Parameter sendMaintainaceModeNotification: Should the app be notified if it is in maintainance mode. False be default
    /// - Returns: Bool indicating if in maintainance mode
    public func isInMaintainanceMode(sendMaintainaceModeNotification: Bool = false) async -> Bool {
        let config = EndPointConfigManager().currentConfig()
        let baseUrl = config.enrollmentEndpoint
        guard let url = URL(string: "https://" + baseUrl + endPoint) else {
            assertionFailure("URL issue")
            return false
        }

        // Make call
        let request = URLRequest(url: url)

        do {
            let result = try await URLSession.sendDataWith(request: request)

            if sendMaintainaceModeNotification && !result.isHttpResponseGood {
                notify(result: result)
            }

            return !result.isHttpResponseGood
        }
        catch {
            SharedLogger.shared.logMessage(tag: "MaintainanceModeCheck",
                                           message: "Error getting maintainance mode state: \(error)")

            return false
        }
    }

    private func notify(result: URLRequestResult) {
        guard let data = result.data else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name.BackendDidGoIntoMaintainanceMode,
                                                object: nil)
            }

            return
        }

        let decoder = JSONDecoder()

        do {
            let decoded = try decoder.decode(ErrorMetaDataModel.self, from: data)
            if let maintainanceMode = decoded.response.maintenanceMode {
                if maintainanceMode {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name.BackendDidGoIntoMaintainanceMode,
                                                        object: decoded)
                    }

                }
                else {
                    SharedLogger.shared.logMessage(tag: "MaintainanceModeCheck", message: "503 Error. No maintainance mode set to false")
                }
            }
            else {
                SharedLogger.shared.logMessage(tag: "MaintainanceModeCheck", message: "503 Error. No maintainance mode")
            }


        } catch {
            SharedLogger.shared.logMessage(tag: "MaintainanceModeCheck", message: "Error json is unexpected")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name.BackendDidGoIntoMaintainanceMode,
                                                object: nil)
            }
        }
    }


    /// Checks if the endpoint is available. Times out after 5 seconds. Useful for online status checking
    /// - Returns: True if it is available. Else false
    public func isEndpointAvailable() async -> Bool {
        let config = EndPointConfigManager().currentConfig()
        let baseUrl = config.enrollmentEndpoint
        guard let url = URL(string: "https://" + baseUrl + endPoint) else {
            assertionFailure("URL issue")
            return false
        }

        // Make call
        let request = URLRequest(url: url)

        do {
            _ = try await URLSession.sendDataWith(request: request)

            return true
        }
        catch {
            return false
        }
    }

    public init(){}
}
