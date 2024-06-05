//
//  EmailValidation.swift
//  IESManager
//
//  Created by Richard Stockdale on 21/04/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation

public struct EmailValidation {
    public static func isVeeaUser(email: String) -> Bool {
        let domains = ["max2", "veea", "veeasystems"]
        let emailDomain = email.components(separatedBy: "@")[1]
        let orgDomain = emailDomain.components(separatedBy: ".")[0]

        return domains.contains(orgDomain)
    }
}
