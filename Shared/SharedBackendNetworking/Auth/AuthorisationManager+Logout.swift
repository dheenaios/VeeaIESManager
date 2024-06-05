//
//  AuthorisationManager+Logout.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 04/11/2022.
//

import Foundation

// MARK: - LOGOUT
extension AuthorisationManager {

    /// Makes the logout api call. You should use Logout controller from the main app as this will
    /// End the user session locally, send the logout call, and provide a closure in which you can do
    /// any UI handling
    /// - Parameters:
    ///   - authFlowSessionManager: The authFlowSession manager. Probably the App delegate
    ///   - completion: Completion block with success
    public func logout(authFlowSessionManager: AuthFlowSessionManagerProtocol,
                       completion:  @escaping (Bool)->()) {
        DeviceOptionsManager.deleteCachedDeviceDetails()

        guard let refreshToken = self.authState?.refreshToken else {
            self.keychain.delete(self.authStateKey)
            VeeaRealmsManager.selectedRealm = "veea"
            DispatchQueue.main.async { completion(true) }

            return
        }

        let parameters = "client_id=vhm&refresh_token=\(refreshToken)"
        let postData =  parameters.data(using: .utf8)

        var request = URLRequest(url: logoutUrl,timeoutInterval: Double.infinity)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        lastUser = nil

        URLSession.sendDataWith(request: request) { result, error in
            SharedLogger.log(tag: "FBTokenSend", message: "Sending logout from LogoutController")
            self.removeLocalAuthItems(authFlowSessionManager: authFlowSessionManager)
            let statusCode = result.httpCode
            if(statusCode == 200 || statusCode == 204 || statusCode == 302) {
                completion(true)
            }
            else {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    public func logout(authFlowSessionManager: AuthFlowSessionManagerProtocol) async -> Bool {
        DeviceOptionsManager.deleteCachedDeviceDetails()

        guard let refreshToken = self.authState?.refreshToken else {
            self.keychain.delete(self.authStateKey)
            VeeaRealmsManager.selectedRealm = "veea"

            return true
        }

        let parameters = "client_id=vhm&refresh_token=\(refreshToken)"
        let postData =  parameters.data(using: .utf8)

        var request = URLRequest(url: logoutUrl,timeoutInterval: Double.infinity)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        lastUser = nil

        do {
            SharedLogger.log(tag: "FBTokenSend", message: "Sending logout from LogoutController")
            let result = try await URLSession.sendDataWith(request: request)
            self.removeLocalAuthItems(authFlowSessionManager: authFlowSessionManager)
            if result.isHttpResponseGood {
                return true
            }

            return false
        }
        catch {
            SharedLogger.log(tag: "FBTokenSend",
                             message: "Sending logout failed \(error.localizedDescription)")
            return false
        }
    }

    private func removeLocalAuthItems(authFlowSessionManager: AuthFlowSessionManagerProtocol) {
        // Remove local items
        authFlowSessionManager.currentAuthorizationFlow = nil
        self.authState = nil
        VeeaRealmsManager.selectedRealm = "veea"
        self.deleteAuthState()
        self.keychain.delete(self.authStateKey)
    }
}
