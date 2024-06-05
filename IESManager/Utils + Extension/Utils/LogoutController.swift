//
//  LogoutController.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit
import SharedBackendNetworking
import WidgetKit

class LogoutController {

    enum LogoutResult: Error, Equatable {
        case success
        case noAuthToken
        case noFbToken
        case FbTokenError(String)
        case couldNotMakeRequestBody
        case unknown(String)

        var message: String {
            if Target.currentTarget.isQA {
                return qaMessage
            }

            return releaseMessage
        }

        var qaMessage: String {
            switch self {
            case .success:
                return ""
            case .noAuthToken:
                return "Auth token is invalid"
            case .noFbToken:
                return "No Firebase Token"
            case .FbTokenError(let string):
                return "Firebase token error: \(string)"
            case .unknown(let string):
                return "Unknown token error: \(string)"
            case .couldNotMakeRequestBody:
                return "Could not make the fbToken request"
            }
        }

        var releaseMessage: String {
            "Failed to log out, Please check your network and try again.".localized()
        }
    }

    static var isLoggingOut = false

    // MARK: - Logging out
    
    /*
     Logout consists of 3 steps...
     1. Delete the firebase token
     2. Logout of the realm
     3. Flush user details from the device
     */
    
    static func logout() async -> LogoutResult {
        isLoggingOut = true

        // Step 1...
        // Delete the firebase token first as we need data to do it
        let logoutResult = await PushNotificationRequest.deleteFireBaseTokenFromBackend()
        switch logoutResult {
        case .success, .couldNotMakeRequestBody:
            // If we could not make the body, then logging out is probably
            // be the best thing to do.
            return await endSession()
        default:
            Logger.log(tag: "LogoutController", message: "Failed to delete fbtoken from backend")
            let _ = await endSession()
            return logoutResult
        }
    }
    
    public static func endSession() async -> LogoutResult {
        let appDelegate = await UIApplication.shared.delegate as! AppDelegate
        let success = await UserSessionManager.shared.logoutUser(authFlowSessionManager: appDelegate)
        await MainActor.run {
            isLoggingOut = false
            // Show login view
            NotificationCenter.default.post(name: .logoutNotification, object: nil)
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        let result: LogoutResult = success ? .success : .unknown("Unknown in end session")
        
        return result
    }
}
