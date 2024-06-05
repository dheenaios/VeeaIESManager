//
//  UserDefaultsBacked.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 16/06/2022.
//

import Foundation

@propertyWrapper
public struct UserDefaultsBacked<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    public var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct SharedUserDefaultsBacked<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = SharedUserDefaults.suite

    public var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
