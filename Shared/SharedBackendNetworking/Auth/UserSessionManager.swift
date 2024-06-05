//
//  UserSessionManager.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 06/06/2023.
//

import Foundation


// Replaces UserSessionManager
// Loads the users store login state
// Provides a mechanism to logout of a session
public class UserSessionManager {

    public static let shared = UserSessionManager()

    private let defaults = SharedUserDefaults.suite

    @SharedUserDefaultsBacked(key: "isLoggedInRecord",
                        defaultValue: false)
    public var isUserLoggedIn: Bool

//    @SharedUserDefaultsBacked(key: "VHUSER_IS_ACTIVE",
//                        defaultValue: false)
//    public var userIsActive: Bool?

    public var currentUser: VHUser? {
        AuthorisationManager.shared.lastUser
    }

    public var currentUserId: (int: Int64, string: String) {
        let id = self.currentUser?.id ?? 0
        return (int: id, string: id.description)
    }

    /// Forces the token to update
    public func loadUser() async {
        let access = await AuthorisationManager.shared.accessToken()
        self.isUserLoggedIn = access == nil ? false : true
    }

    init() {
        Task { await loadUser() }
    }
}

// MARK: - Logout
public extension UserSessionManager {

    /// Sends the logout request then clears the local user detail. Do not call directly.
    /// User the logoutcontroller from the main app
    /// - Parameter authFlowSessionManager: Probably the App Delegate
    /// - Returns: Success of the logout call
    func logoutUser(authFlowSessionManager: AuthFlowSessionManagerProtocol) async -> Bool {
        let success = await AuthorisationManager.shared.logout(authFlowSessionManager: authFlowSessionManager)
        if(!success) {
            SharedLogger.shared.logMessage(tag: "UserSessionManager",
                                           message: "Remote log out failed. Flushing user any way")
        }
        DispatchQueue.main.async {
            self.flushUserFromDevice()
        }

        return success
    }

    func flushUserFromDevice() {
        self.isUserLoggedIn = false

        // Flush all locally stored data here
        let domain = Bundle.main.bundleIdentifier!

        // Keep the endpoint and realm info if this is a internal build
        let base = BackEndEnvironment.enrollmentBaseUrl
        let authUrl = BackEndEnvironment.authUrl
        let ub = BackEndEnvironment.ub
        let authCallbackUrl = BackEndEnvironment.authCallbackUrl
        let authRealm = BackEndEnvironment.authRealm
        let masUrl = BackEndEnvironment.masApiBaseUrl
        let realms = VeeaRealmsManager.userAddedRealms

        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()

        SharedUserDefaults.clearSuite()

        VeeaRealmsManager.userAddedRealms = realms

        if BackEndEnvironment.internalBuild {
            BackEndEnvironment.enrollmentBaseUrl = base
            BackEndEnvironment.authUrl = authUrl
            BackEndEnvironment.ub = ub
            BackEndEnvironment.authCallbackUrl = authCallbackUrl
            BackEndEnvironment.authRealm = authRealm
            BackEndEnvironment.masApiBaseUrl = masUrl
        }
    }
}
