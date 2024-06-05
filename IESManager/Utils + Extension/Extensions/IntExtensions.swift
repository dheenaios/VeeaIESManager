//
//  IntExtensions.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 12/01/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

extension Int {
    
    
    /// Is the Int between the two supplied values?
    /// - Parameters:
    ///   - start: The lower value
    ///   - end: The upper value
    /// - Returns: Is it between the two values
    func between(lowerValue: Int, and upperValue: Int) -> Bool {
        return self > lowerValue && self < upperValue
    }
}
