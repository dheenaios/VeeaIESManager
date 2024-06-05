//
//  SharedUserDefaults.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 19/06/2022.
//

import Foundation

// See also SharedUserDefaultsBacked property wrapper


/// Shared defaults for use when data needs sharing across the app and extensions
public class SharedUserDefaults {
    public static var suite: UserDefaults {
        if ApplicationTargets.current == .QA {
            return UserDefaults(suiteName: "group.vhm.shared.internal")!
        }

        return UserDefaults(suiteName: "group.vhm.shared.release")!
    }

    public static func clearSuite() {
        removeAllFor(defaults: suite)
        suite.synchronize()
    }

    private static func removeAllFor(defaults: UserDefaults) {
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
