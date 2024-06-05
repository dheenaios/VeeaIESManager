//
//  URL+Extension.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/30/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

extension URL {
    
    public var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return nil
        }
        
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        
        return parameters
    }
}
