//
//  UpdateRequired.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 28/06/2022.
//

import Foundation
public class UpdateRequired {
    public static var updateRequired: Bool = false
    public static var updateRequiredShownThisSession: Bool = false

    public static func reset() {
        updateRequired = false
        updateRequiredShownThisSession = false
    }
}
