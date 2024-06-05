//
//  StringValidator.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 06/02/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

// A protocol for string validation.
protocol StringValidator {
    func validate(str: String) -> (SuccessAndOptionalMessage)
}

// Some common validation objects.

// MARK: - SSID Validation Objects

class SsidNameValidator: StringValidator {
    func validate(str: String) -> (SuccessAndOptionalMessage) {
        return SSIDNamePasswordValidation.ssidNameValidForEnrollment(str: str)
    }
}

class SsidPasswordNameValidator: StringValidator {
    func validate(str: String) -> (SuccessAndOptionalMessage) {
        return SSIDNamePasswordValidation.passwordValidForEnrollment(passString: str, ssid: nil)
    }
}

class SsidConfirmPasswordNameValidator: StringValidator {
    func validate(str: String) -> (SuccessAndOptionalMessage) {
        return SSIDNamePasswordValidation.passwordsMatching(passString: str, confirmPass: nil)
    }
}


