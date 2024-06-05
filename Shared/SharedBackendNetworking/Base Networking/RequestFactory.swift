//
//  RequestFactory.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 25/05/2023.
//

import Foundation

public struct RequestFactory {

    // Create a request. Prefer using async alternative
    /// - Parameters:
    ///   - url: the url to send to
    ///   - authToken: authorisation token. Get this from URLRequest extension method
    ///   - method: method GET POST PATCH
    ///   - body: optional body data
    /// - Returns: The UrlRequest
    public static func authenticatedRequest(url: String,
                                            authToken: String,
                                            method: String,
                                            body: Data?) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)

        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.httpMethod = method
        
        if let body = body {
            request.httpBody = body
        }

        return request
    }


    /// Creates a request with a valid token. If the token is expired, a new one is requested and applied.
    /// - Parameters:
    ///   - url: url
    ///   - method: method
    ///   - body: optional body
    /// - Returns: URL request
    public static func authenticatedRequest(url: String,
                                            method: String,
                                            body: Data?) async -> URLRequest {
        var request = URLRequest(url: URL(string: url)!,timeoutInterval: Double.infinity)

        if let token = await URLRequest.getAuthToken() {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.httpMethod = method

        if let body = body {
            request.httpBody = body
        }

        return request
    }
}
