//
//  ApplicationTargets.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 18/06/2022.
//

import Foundation

enum ApplicationTargets {
    case QA
    case RELEASE

    static var current: ApplicationTargets {
        let bundle = Bundle.main.bundleIdentifier

        if bundle == "com.veea.iesmanager.internal.Widgets-Internal" ||
            bundle == "com.veea.iesmanager.internal" ||
            bundle == "com.veea.iesmanager.internal.HealthWidgetIntentHandler-Internal" {
            return .QA
        }

        return .RELEASE
    }

    var keychainGroup: String {
        if ApplicationTargets.current == .QA {
            return "9SQVV53FAV.com.veea.ies.manager.sharedKeychain-internal"
        }

        return "9SQVV53FAV.com.veea.iesmanager.sharedKeychain"
    }
}
