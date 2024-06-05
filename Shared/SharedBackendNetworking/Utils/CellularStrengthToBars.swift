//
//  CellularStrengthToBars.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 07/10/2022.
//

import Foundation

public struct CellularStrengthToBars {
    
    /// Signal Percentage to number of bars
    /// - Parameter strengthPercentage: Signal percentage
    /// - Returns: Number of bars (0 - 5)
    public static func convert(strengthPercentage: Int) -> Int {
        if strengthPercentage > 100 || strengthPercentage < 0 {
            return 0 }
        
        let result: Float = Float(strengthPercentage) / 20
        return Int(result.rounded(.up))
    }
}
