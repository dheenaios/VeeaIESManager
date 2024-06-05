//
//  VKHTTPManager+Error.swift
//  VeeaKit
//
//  Created by Atesh Yurdakul on 12/6/17.
//  Copyright © 2017 Max2. All rights reserved.
//

import Foundation

/// VKHTTPManager related errors.
/// See the enum for description for each error.
public enum VKHTTPManagerError: Error, CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        get {
            return self.localizedDescription
        }
    }
    
    public var debugDescription: String {
        get {
            return self.localizedDescription
        }
    }
    
    /// VeeaKit was not configured.
    case veeaKitNotConfigured
    
    /// The HMAC authentication data is missing.
    /// Make sure the user is logged in?
    case authenticationDataMissing
    
    /// An invalid URL was passed.
    case invalidURLProvided
    
    /// HMAC header creation has failed.
    case hmacCreationFailed(error: Error?)
    
    /// Server did not return anything or the
    /// network connection was cut off resulting in a
    /// nil response.
    case didNotReceiveData
    
    /// Server returned HTML or corrupt JSON.
    case didNotReceiveValidResponse
    
    /// The JSON that was returned by the server
    /// did not meet the JSON specifications required
    /// (for example, was missing the ``meta`` field.)
    case invalidJSON
    
    /// Server returned an error in the ``meta`` field.
    case serverError(error: String)
    
    /// Server refused to accept the request because the
    /// application is out of date.
    case updateRequired
    
    /// Server refused to accept the request because
    /// authentication has failed.
    case unauthorized

    /// Might be triggered if an unknown group or mesh is passed in
    case forbidden
    
    /// No network connection.
    case noConnection

    /// 400
    case badRequest

    /// 404
    case notFound
    
    case didReceiveInValidResponse
    
    public var localizedDescription: String {
        get {
            switch self {
            case .authenticationDataMissing:
                return "User authentication data missing from VKUserManager. Did you set the currentUser there?"
            case .invalidURLProvided:
                return "You've passed an invalid URL. Try again."
            case .didNotReceiveData:
                return "No data received."
            case .didNotReceiveValidResponse:
                return "A server error occurred. Please try again later."
            case .didReceiveInValidResponse:
                return "Oops! Looks like there's an issue with the application. Please give it another try later."
            case .invalidJSON:
                return "Could not parse JSON. It might be invalid."
            case .updateRequired:
                return "Please update your app to continue."
            case .unauthorized:
                return "Server did not accept your credentials."
            case .serverError(error: let err):
                return err
            case .badRequest:
                return "Bad request"
            case .notFound:
                return "Not found error (404)"
                
            case .noConnection:
                return "No connection. Please check your internet connection."
            default:
                return "Unknown error"
            }
        }
    }
    
    public static func parseError(error: Error?) -> String {
        var errString = error?.localizedDescription ?? VKHTTPManagerError.didReceiveInValidResponse.description
        if let err = error as? VKHTTPManagerError {
            errString = err.description
        }
        return errString
    }
    
}
