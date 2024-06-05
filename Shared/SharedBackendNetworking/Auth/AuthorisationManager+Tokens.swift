//
//  AuthorisationManager+Tokens.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 04/11/2022.
//

import Foundation

// MARK: - Token access
extension AuthorisationManager {
    /// Returns the last access token. Only call this if you a are certain the token is still valid
    public var lastAccessToken: String? {
        return authState?.lastTokenResponse?.accessToken
    }

    func accessToken() async -> String? {
        if lastAccessToken == nil { setup() }
        guard lastAccessToken != nil else { return nil }

        // If we are intercepting for mocking, then we dont care that the
        // token is out of date
        if TestsRouter.interceptForMocking {
            return self.authState?.lastTokenResponse?.accessToken
        }

        if tokenExpired {
            let success = await refreshTokenAndUserInfo()
            if !success { return nil }
        }

        return self.authState?.lastTokenResponse?.accessToken
    }

    public func accessToken(token: @escaping (String?) -> Void) {
        if lastAccessToken == nil {
            setup()
        }

        guard lastAccessToken != nil else {
            token(nil)
            return
        }

        // If we are intercepting for mocking, then we dont care that the
        // token is out of date
        if TestsRouter.interceptForMocking {
            token(self.authState?.lastTokenResponse?.accessToken)
            return
        }

        if tokenExpired {
            refreshTokenAndUserInfo { (success) in
                if !success {
                    token(nil)
                    return
                }

                token(self.authState?.lastTokenResponse?.accessToken)
            }

            return
        }

        token(authState?.lastTokenResponse?.accessToken)
    }

    public var formattedAuthToken: String? {
        guard let t = authState?.lastTokenResponse?.accessToken else {
            return nil
        }

        return "Bearer \(t)"
    }

    public var tokenExpired: Bool {
        guard let expires = expiryDate else {
            return true
        }

        return expires < Date()
    }

    public var expiryDate: Date? {
        guard let expires = authState?.lastTokenResponse?.accessTokenExpirationDate else {
            return nil
        }

        return expires
    }

    public func refreshAuthTokenIfNeeded(completed: @escaping (Bool) -> Void) {
        // If we are intercepting for mocking, then we dont care that the
        // token is out of date
        if TestsRouter.interceptForMocking {
            completed(true)
            return
        }

        if tokenExpired {
            refreshTokenAndUserInfo(completed: completed)
            return
        }

        completed(true)
    }

    public func refreshAuthTokenIfNeeded() async -> Bool {
        if !tokenExpired { return true }
        return await refreshTokenAndUserInfo()
    }
}
