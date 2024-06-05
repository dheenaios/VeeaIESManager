//
//  Logger.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 16/08/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation
import SharedBackendNetworking

// Wrapper for Shared Logger so we do not have to import SharedBackendNetworking everywhere
public class Logger {
    public static let shared = Logger()

    public static func log(tag: String, message: String) {
        if !isDebug { return }
        
        DispatchQueue.main.async {
            SharedLogger.log(tag: tag, message: message)
        }
    }

    public func getSessionLogsWithTag(_ tag: String, reversed: Bool = true) -> String {
        SharedLogger.shared.getSessionLogsWithTag(tag, reversed: reversed)
    }
    
    public func getSessionLog() -> String {
        SharedLogger.shared.getSessionLog()
    }
    
    public func getSessionLogReverse() -> String {
        SharedLogger.shared.getSessionLogReverse()
    }
    
    public func clearLogs() {
        SharedLogger.shared.clearLogs()
    }

    private static var isDebug: Bool {
        Target.currentTarget != .RELEASE
    }

    public static func logDecodingError(className: String, tag: String, error: Error) {
        let message = "JSON \(className) decoding error: \(error)"
        SharedLogger.shared.logMessage(tag: tag, message: message)
    }
}
