//
//  StringValidation.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 31/01/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

class StringValidation {
    
    public static func doesStringContainLetters(candidate: String) -> Bool {
        let range = candidate.rangeOfCharacter(from: NSCharacterSet.letters)

        // range will be nil if no letters is found
        if range != nil {
            return true
        }
        else {
           return false
        }
    }
}
