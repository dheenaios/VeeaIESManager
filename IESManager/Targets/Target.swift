//
//  Target.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

enum Target {
    
    private static let kQaTargetName = "QA VHM"
    private static let kQaHomeTargetName = "QA VHM Home"
    private static let kQaRobotTargetName = "QA VHM Robot"
    private static let kReleaseTargetName = "IESManager"
    
    case QA
    case QA_HOME
    case QA_ROBOT
    case RELEASE
    
    static var currentTarget: Target {
        switch targetName {
        case kQaTargetName:
            return .QA
        case kQaHomeTargetName:
            return .QA_HOME
        case kQaRobotTargetName:
            return .QA_ROBOT
        case kReleaseTargetName:
            return .RELEASE
        default:
            fatalError("Target not found")
        }
    }

    var isQA: Bool {
        return self != .RELEASE
    }
    
    var isHome: Bool {
        // Get the realm name. If it contains home, then this is the home app
        let realm = BackEndEnvironment.authRealm + VeeaRealmsManager.selectedRealm
        if realm.lowercased().contains("home") {
            return true
        }
        
        return isHomeBuild
    }

    var isHomeBuild: Bool {
        return self == .QA_HOME
    }
    
    var isRobotBuild: Bool {
        return self == .QA_ROBOT
    }
    
    /// The current targets human readable product name
    static var targetDisplayName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
    }
    
    /// The current targets bundle name
    static var targetName: String {
        Bundle.main.infoDictionary?["CFBundleName"] as! String
    }
    
    static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    static var currentBundleString: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    }
}
