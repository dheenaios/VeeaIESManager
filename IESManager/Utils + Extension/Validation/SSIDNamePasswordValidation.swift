//
//  SSIDNamePasswordValidation.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 06/02/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

class SSIDNamePasswordValidation {
    
    static let password = "Password".localized()

    static func ssidNameValidForEnrollment(str: String) -> (SuccessAndOptionalMessage) {
        if str.isEmpty {
            return (false, "SSID contains no characters".localized())
        }
        else if str.count < 1 {
            return (false, "SSID must contain at least 1 character".localized())
        }
        else if str.count > 32 {
            return (false, "SSID must contain less than 32 characters".localized())
        }
        
        let matches = str.matches("^[a-zA-Z0-9!@#$&()_`.+,;/-]{1,32}$")
        //print("SSID: \(matches)")
         
         if !matches {
             return (false, "SSID invalid (Valid characters are 0–9, a-z, A-Z, and special characters: ! # @ $ ( ) – ‘. , / ; _".localized())
         }
        
        return (true, nil)
    }
    
    static func ssidNameValid(str: String) -> (SuccessAndOptionalMessage) {
        if str.isEmpty {
            return (false, "SSID contains no characters".localized())
        }
        else if str.count < 1 {
            return (false, "SSID must contain at least 1 character".localized())
        }
        else if str.count > 32 {
            return (false, "SSID must contain less than 32 characters".localized())
        }
        
        return (true, nil)
    }
    
    static func passwordValid(passString: String, ssid: String?) -> (SuccessAndOptionalMessage) {
        var ssidString = ""
        if let ssid = ssid {
            ssidString = "\("for".localized("For ssid")) \(ssid) "
        }
        if ssidString.isEmpty {
            ssidString = "for empty SSID".localized()
        }
        
        if passString.isEmpty {
            return (false, "\(password) \(ssidString) \("contains no characters".localized())")
        }
        else if passString.count < 8 {
            return (false, "\(password) \(ssidString) \("is too short. It must contain between 8 and 63 characters".localized())")
        }
        else if passString.count > 63 {
            return (false, "\(password) \(ssidString)\("is too long. It must contain between 8 and 63 characters".localized())")
        }
        
        return (true, nil)
    }
    
    static func passwordValidForEnrollment(passString: String, ssid: String?) -> (SuccessAndOptionalMessage) {
        var ssidString = ""
        if let ssid = ssid {
            ssidString = "\("for".localized("For SSID".localized())) \(ssid) "
        }
        
        if passString.isEmpty {
            return (false, "\(password) \(ssidString) \("contains no characters".localized())")
        }
        else if passString.count < 8 {
            return (false, "\(password) \(ssidString) \("is too short. It must contain between 8 and 63 characters".localized())")
        }
        else if passString.count > 63 {
            return (false, "\(password) \(ssidString) \("is too long. It must contain between 8 and 63 characters".localized())")
        }
        
        let matches = passString.matches("^[a-zA-Z0-9!@#$&()_`.+,;/-]{8,64}$")
        
        if !matches {
            return (false, "\(password) \(ssidString) invalid (Valid characters are 0–9, a-z, A-Z, and special characters:  ! # @ $ ( ) – ‘. , / ; _".localized())
        }
        
        return (true, nil)
    }
    
    static func passwordsMatching(passString: String, confirmPass: String?) -> (SuccessAndOptionalMessage) {
        
        if passString == confirmPass {
            return (false, "Please check that passwords match.".localized())
        }
        
        return (true, nil)
    }
    
}
