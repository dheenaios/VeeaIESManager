//
//  VeeaKit.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/23/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

#if DEBUG
fileprivate let _env_inDebugMode = true
#else
fileprivate let _env_inDebugMode = false
#endif

public typealias ErrorCallback = (_ message: String) -> Void

public struct VeeaKit {
    
    // MARK: - Debug
    
    /// Returns true if app is in debug mode.
    public static var debug: Bool {
        return _env_inDebugMode
    }
    
    // MARK: - Versions
    
    public struct versions {
        
        /// Returns the Application Version.
        public static var application: String {
            get {
                let _env_ApplicationVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
                return _env_ApplicationVersion
            }
        }
        
        /// Returns the Application build.
        public static var build: String {
            get {
                let _env_ApplicationBuild = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? ""
                return _env_ApplicationBuild
            }
        }
        
    }
    
    // MARK: - Language Helpers
    
    public struct language {
        
        /// Returns the device's prefered locale.
        public static var preferedLocale: String {
            get {
                let preferredLocale: AnyObject = Locale.preferredLanguages[0] as AnyObject
                return "\(preferredLocale)"
            }
        }
        
    }
    
    // MARK: - Date Helpers
    
    public struct date {
        
        /// Returns the current time in UNIX Timestamp.
        public static var timestamp: Double {
            get {
                return (Date()).timeIntervalSince1970
            }
        }
        
    }
}


public func VKLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line ) {
    
    if _env_inDebugMode {
         //print("\n *** From \(file):\(line) | \(function) | \(message) *** \n")
    }
}
