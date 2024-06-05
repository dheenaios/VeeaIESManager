//
//  VKHTTPRequestCallType.swift
//  VeeaKit
//
//  Created by Atesh Yurdakul on 12/7/17.
//  Copyright © 2017 Max2. All rights reserved.
//

import Foundation

public enum VKHTTPRequestCallType: String {
    
    /// Make a HTTP GET request.
    case get = "GET"
    
    /// Make a HTTP POST request.
    case post = "POST"
    
    /// Make a HTTP DELETE request.
    case delete = "DELETE"
    
    /// Make a HTTP PUT request.
    case put = "PUT"
    
    case patch = "PATCH"
}
