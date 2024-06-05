//
//  HTTPManager+RequestPatching.swift
//  VeeaKit
//
//  Created by Atesh Hicks on 12/1/17.
//  Copyright © 2017 Max2. All rights reserved.
//

import Foundation

public extension VKHTTPManager {
    
    /// Takes a VKHTTPRequest and creates a native URLRequest with
    /// the headers that the server is expecting from us. This should be
    /// an internal function and should not be made public/open.
    internal class func createRequest(request: VKHTTPRequest) throws -> URLRequest {
        
        var urlRequest = URLRequest(url: request.url,
                                    cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy,
                                    timeoutInterval: request.timeout)
        
        urlRequest.httpMethod = request.type.rawValue
        urlRequest.httpBody = request.data
        
        if (!request.unauthenticatedCall && !TestsRouter.interceptForMocking) {
            if AuthorisationManager.shared.formattedAuthToken == nil {
                throw VKHTTPManagerError.authenticationDataMissing
            }
        }

        if let auth = AuthorisationManager.shared.formattedAuthToken {            
            urlRequest.addValue(auth, forHTTPHeaderField: "Authorization")
        }

        return urlRequest
    }
    
}
