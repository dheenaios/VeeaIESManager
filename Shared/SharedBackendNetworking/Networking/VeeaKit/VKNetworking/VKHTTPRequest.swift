//
//  HTTPRequest.swift
//  VeeaKit
//
//  Created by Atesh Hicks on 12/1/17.
//  Copyright © 2017 Max2. All rights reserved.
//

import Foundation

/**
 
 VKHTTPRequest is used to make a call.
 
 It stores information such as the URL,
 request type (GET, POST, etc.), the POST body,
 the POST body MIME type, timeout, etc.
 
 - note:
 You need to set your VKApplication up in VeeaKit.init
 for VKHTTPRequest.create to work.
 
 For more information, see the
 [documentation](https://max2team.atlassian.net/wiki/spaces/VeeaKitiOS/pages/110788637/VKHTTPRequest)
 
 */
public struct VKHTTPRequest {
    
    /// The URL that will be called.
    public var url: URL!
    
    /// VKHTTPManager will try to send the current
    /// device location if this is set to true.
    public var sendLocation = true
    
    /// HTTP request type
    public var type = VKHTTPRequestCallType.get
    
    /// Post Body
    public var data: Data? = nil
    
    /// Post Body MIME content type
    public var dataContentType: String = "application/json"
    
    /// Timeout in seconds.
    public var timeout: Double = 30
    
    /// VKHTTPManager will not try to create an HMAC
    /// header for this nor throw an error if authentication
    /// data does not exist if this is set to true.
    public var unauthenticatedCall = false
    
    /// Creates an relative call (ie: "/user/create")
    /// - parameter url:    The relative URL to call (ie: ``/user/create/``)
    /// - parameter type:   The type of HTTP request (GET, POST, etc.)
    /// - parameter data:   The body that will be posted. Only used in POST, PUT and DELETE requests. Has no affect on GET.
    /// - important: Unless ``unauthenticatedCall`` is set to true, the request will log the user out and delete user data when it receives an ``Unauthorized`` status from the server. After creation, always set ``unauthenticatedCall`` to true if you don't want the data wiped if the call fails or if its an actual unauthenticated call such as a login call.
    /// - note: If you need to change the MIME type, do it after creation using ``dataContentType`` variable.
    /// - note: If you need to change the timeout, do it after creation using ``timeout`` variable.
    public static func create(url: String, type: VKHTTPRequestCallType = .get, data: Data? = nil) throws -> VKHTTPRequest {
        
        let endpoint = url
        guard let requestURL = URL.init(string: endpoint) else {
            throw VKHTTPManagerError.invalidURLProvided
        }
        
        var toReturn = VKHTTPRequest()
        toReturn.url = requestURL
        toReturn.type = type
        toReturn.data = data
        
        return toReturn
        
    }
    
    /// Creates an absolute call (ie: "http://xyz.com/a/b/c")
    ///
    /// - important: If you are making a call to Veea backend, use VKHTTPRequest.create instead.
    @available(*, message: "Unless you know what you are doing, do not call this method. Use VKHTTPRequest.create instead.")
    static func createAbsolute(url: String, type: VKHTTPRequestCallType = .get, data: Data? = nil) throws -> VKHTTPRequest {
        
        guard let requestURL = URL.init(string: url) else {
            throw VKHTTPManagerError.invalidURLProvided
        }
        
        var toReturn = VKHTTPRequest()
        toReturn.url = requestURL
        toReturn.type = type
        toReturn.data = data
        
        return toReturn
        
    }
    
}
