//
//  VKReachabilityManager+Delegate.swift
//  VeeaKit
//
//  Created by Atesh Yurdakul on 12/15/17.
//  Copyright © 2017 Max2. All rights reserved.
//

import Foundation

public protocol VKReachabilityManagerDelegate: AnyObject {
    
    func reachabilityStatusChanged(status: VKReachabilityManagerStatus)
    
}
