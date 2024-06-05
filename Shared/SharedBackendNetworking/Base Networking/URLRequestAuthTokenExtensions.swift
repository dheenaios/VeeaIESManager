//
//  URLRequestExtensions.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 16/08/2022.
//

import Foundation

public extension URLRequest {
    
    /*
     There are a few kinds of tokens
     
     - Access Token
     - Auth Token
     
     This extension only deals with the auth token used to talk to the MAS
     
     */
    
    func addUpdateAuthToken(completion: @escaping(URLRequest) -> Void) {
        var r = self
        
        URLRequest.getAuthToken { token in
            if let token = token {
                r.addValue(token, forHTTPHeaderField: "Authorization")
            }
            
            completion(r)
        }
    }
    
    /// Aysnc updates the Auth token
    mutating func addUpdateAuthToken() async {
        if let token = await URLRequest.getAuthToken() {
            addValue(token, forHTTPHeaderField: "Authorization")
        }
    }
    
    /// Get token Async
    /// - Returns: Optional token String
    static func getAuthToken() async -> String? {
        if TestsRouter.interceptForMocking {
            return AuthorisationManager.shared.formattedAuthToken
        }
        
        guard let token = AuthorisationManager.shared.formattedAuthToken,
              !AuthorisationManager.shared.tokenExpired else {
            let success = await AuthorisationManager.shared.refreshAuthTokenIfNeeded()
            if success { return AuthorisationManager.shared.formattedAuthToken }
            return nil
        }
        
        return token
    }
    
    /// Get the current auth token
    /// - Parameter completion: Completion handler with an optional token string
    static func getAuthToken(completion: @escaping (String?) -> Void) {
        if TestsRouter.interceptForMocking {
            completion(AuthorisationManager.shared.formattedAuthToken)
            return
        }
        
        guard let token = AuthorisationManager.shared.formattedAuthToken,
              !AuthorisationManager.shared.tokenExpired else {
            AuthorisationManager.shared.refreshAuthTokenIfNeeded { success in
                if success {
                    getAuthToken(completion: completion)
                }
                else {
                    completion(nil)
                }
            }
            
            return
        }
        
        completion(token)
    }
}

