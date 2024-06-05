//
//  UserDefaultsBacked.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 27/10/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

@propertyWrapper struct UserDefaultsBacked<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard
    
    var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}

@propertyWrapper struct SharedUserDefaultsBacked<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = SharedUserDefaults.suite

    var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
