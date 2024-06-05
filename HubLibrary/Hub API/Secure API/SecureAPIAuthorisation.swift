//
//  SecureAPIAuthorisation.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 12/04/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation
import KeychainSwift
import JWTDecode


// NSObject due to requerement for URLSessionDelegate
public class SecureAPIAuthorisation: NSObject {
    
    private let tag = "SecureAPIAuthorisation"
    
//    private let timeoutIntervalForRequest = 5.0
//    private let timeoutIntervalForResource = 15.0
    
    private let authorisationResponseKey = "Authorization"
    private let authTokenKey = "AuthTokenKey"
    private let keychain = KeychainSwift()
    private let twelveHours: TimeInterval = 43200;
    private var authRetryCount = 0
    private let maxAuthRetrys = 3
    
    
    /// Gate to make sure we dont spam the system with login requests
    private var isLoggingIn = false {
        didSet {
            let delay = DispatchTime.now() + .seconds(10)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.isLoggingIn = false
            }
        }
    }
    
    public static let shared = SecureAPIAuthorisation()
    public typealias LoginSuccessDelegate = (SuccessAndOptionalMessage) -> Void

    private var authTokenString: String? {
        get {
            return keychain.get(authTokenKey)
        }
        set {            
            if let newToken = newValue {
                if let oldToken = keychain.get(authTokenKey) {
                    if oldToken != newToken {
                        NotificationCenter.default.post(name: NSNotification.Name.TokenUpdated, object: nil)
                    }
                }
                
                keychain.set(newToken, forKey: authTokenKey)
            }
        }
    }
    
    public func getCachedToken() -> String? {
        guard let token = authTokenString else {
            return nil
        }
        
        do {
            let jwt = try decode(jwt: token)
            if tokenIsValid(token: jwt) {
                return token
            }
            
            // Delete the invalid key
            deleteToken()
            
            return nil
        }
        catch {
            //print("Failed to decode JWT: \(error)")
        }

        return nil
    }
    
    public func deleteToken() {
        Logger.log(tag: tag, message: "Delete auth token called")
        keychain.delete(authTokenKey)
    }
    
    /// Check the token is valid
    ///
    /// - Parameter token: JWT Token
    /// - Returns: is the token valid
    private func tokenIsValid(token: JWT) -> Bool {
        guard let expiryDate = token.expiresAt else {
            return false
        }
        
        // Check the token is still valid. Each token is valid for 24 hours
        // Really we should get the connection time
        // However the goal of caching is just to ensure we're not making a login call too often
        // We assume that the device and connection will not be more than 12 hours apart
        // If they are then we will not be able to connect, however this will just result in
        // a new token being download.
        let newPlusTwelve = Date().addingTimeInterval(twelveHours)
        let interval: Double = expiryDate.timeIntervalSince(newPlusTwelve)
        if interval > 0 {
            return true
        }
        
        return false
    }
    
    @discardableResult public func login(connection: VeeaHubConnection, successHandler: @escaping LoginSuccessDelegate) -> Bool {
        
        Logger.log(tag: tag, message: "Logging in on hub...\n \(connection.debugDescription)")
        
        authRetryCount = 0
        
        if isLoggingIn == false {
            attemptToGetAuthToken(connection: connection, successHandler: successHandler)
            return true
        }
        
        successHandler((false, "Another process requesting a login"))
        
        return false
    }
    
    private func attemptToGetAuthToken (connection: VeeaHubConnection,
                                        successHandler: @escaping LoginSuccessDelegate) {
        
        if connection.getBaseURL().contains("0.0.0.0") {
            successHandler((false, "No hub ip"))
            return
        }
        
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue.main)
        
        guard let request = SecureURLRequestFactory.createLoginURLRequest(connection: connection) else {
            Logger.log(tag: tag, message: "Failed to create login url request")
            return
        }
        
        isLoggingIn = true
        Logger.log(tag: self.tag, message: "Beginning authorisation token request call")

        session.sendDataWith(request: request) { result, error in
            self.isLoggingIn = false

            if let response = result.response as? HTTPURLResponse {
                let statusCode = response.statusCode
                Logger.log(tag: self.tag, message: "Login request returned with code \(statusCode)")

                let headers = response.allHeaderFields

                if let e = error {
                    self.respond(success: false, description: e.localizedDescription, closure: successHandler)
                    return
                }

                if let header = headers[self.authorisationResponseKey] {
                    let authString = self.trimmedToken(token: header as! String) //header as? String
                    self.authTokenString = authString
                    self.respond(success: true, description: authString, closure: successHandler)
                }
                else {
                    self.respond(success: false, description: "No auth token received: \(statusCode)", closure: successHandler)
                }
            }
            else {
                if let e = error {
                    if self.authRetryCount < self.maxAuthRetrys {
                        self.isLoggingIn = false
                        self.authRetryCount += 1
                        self.attemptToGetAuthToken(connection: connection, successHandler: successHandler)
                    }
                    else {
                        self.respond(success: false, description: "No response from the Hub. Response Code \(e.localizedDescription)", closure: successHandler)
                    }
                }
                else {
                    self.respond(success: false, description: "No response from the Hub", closure: successHandler)
                }
            }
        }


//        session.dataTask(with: request) { (data, response, error) in
//            self.isLoggingIn = false
//
//            if let response = response as? HTTPURLResponse {
//                let statusCode = response.statusCode
//                Logger.log(tag: self.tag, message: "Login request returned with code \(statusCode)")
//
//                let headers = response.allHeaderFields
//
//                if let e = error {
//                    self.respond(success: false, description: e.localizedDescription, closure: successHandler)
//                    return
//                }
//
//                if let header = headers[self.authorisationResponseKey] {
//                    let authString = self.trimmedToken(token: header as! String) //header as? String
//                    self.authTokenString = authString
//                    self.respond(success: true, description: authString, closure: successHandler)
//                }
//                else {
//                    self.respond(success: false, description: "No auth token received: \(statusCode)", closure: successHandler)
//                }
//            }
//            else {
//                if let e = error {
//                    if self.authRetryCount < self.maxAuthRetrys {
//                        self.isLoggingIn = false
//                        self.authRetryCount += 1
//                        self.attemptToGetAuthToken(connection: connection, successHandler: successHandler)
//                    }
//                    else {
//                        self.respond(success: false, description: "No response from the Hub. Response Code \(e.localizedDescription)", closure: successHandler)
//                    }
//                }
//                else {
//                    self.respond(success: false, description: "No response from the Hub", closure: successHandler)
//                }
//            }
//
//            session.invalidateAndCancel()
//            }.resume()
    }
    
    private func trimmedToken(token: String) -> String {
        return token.replacingOccurrences(of: "Bearer ", with: "")
    }
    
    private func respond(success: Bool, description: String, closure: @escaping LoginSuccessDelegate) {
        DispatchQueue.main.async {
            closure((success, description))
        }
    }
}

// SSL challenge handling for build >180
extension SecureAPIAuthorisation: URLSessionDelegate {

    public func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        Logger.log(tag: tag, message: "Received a ssl challenge")
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:challenge.protectionSpace.serverTrust!))
    }
}
