//
//  HubNameValidation.swift
//  IESManager
//
//  Created by Richard Stockdale on 02/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

struct NameValidation {
    private static let allowed = "_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-"

    /// Returns a string if the name is valid
    /// - Parameter name: The mesh name
    /// - Returns: An error message if there is one.
    static func meshNameHasErrors(name: String) -> String? {
        return hubNameHasErrors(name: name)
    }
    
    /// Returns a string if the name is valid
    /// - Parameter name: The hub name
    /// - Returns: An error message if there is one.
    static func hubNameHasErrors(name: String) -> String? {
        var errors = ""
        
        // It must have a character
        if name.isEmpty {
            errors.append("Please enter a name.".localized())
            errors.append(" ")
        }
        
        // Name has to be less than 32 chars
        if name.count > 32 {
            errors.append("Names should be under 32 characters.".localized())
            errors.append(" ")
        }
        
        // First char must be alpha
        if !firstCharIsAlpha(name: name) {
            errors.append("Names should begin with an alphabetic character.".localized())
            errors.append(" ")
        }
        
        // Check for presence of invalid chars
        let components = name.components(separatedBy: CharacterSet(charactersIn: allowed).inverted)
        let filtered = components.joined(separator: "")
    
        if name != filtered {
            errors.append("Only letters, numbers, _ and - are allowed.".localized())
            errors.append(" ")
        }
        
        if errors.isEmpty { return nil }
        
        return errors
    }
    
    private static func firstCharIsAlpha(name: String) -> Bool {
        if let firstChar = name.first {
            return firstChar >= "a" && firstChar <= "z" || firstChar >= "A" && firstChar <= "Z"
        }
        
        return false
    }
}
