//
//  LoggingHelper.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 30/10/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation
import UIKit


class LoggingHelper {
    
    
    /// Gets all logs and formats them as a report
    ///
    /// - Returns: String describing the logs
    static func getLogReport() -> String {
        let systemVersion = UIDevice.current.systemVersion
        
        let versionInfo = "\n\niOS Version: \(systemVersion) App Version: \(Target.currentVersion)-\(Target.currentBundleString))"
        
        var shareText = Logger.shared.getSessionLog()
        shareText.append(versionInfo)
        
        return shareText
    }
    
    static func clearLogs() {
        Logger.shared.clearLogs()
    }
}
