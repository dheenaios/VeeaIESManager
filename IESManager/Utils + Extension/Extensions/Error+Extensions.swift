//
//  Error+Extensions.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 23/04/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
