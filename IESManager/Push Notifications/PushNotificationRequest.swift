//
//  PushNotificationRequest.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import Firebase
import SharedBackendNetworking

class PushNotificationRequest: NSObject {

    private static let kToken = "kNotificationToken"
    private static let kUpdateRecord = "kUpdateRecord"
    private static let kFailReason = "kFailReason"
    private static let kTokenUpdated = "kNotificationTokenUpdated"

    // Use this as it is never cleared. We need this to persist between logouts
    private static var defaults = SharedUserDefaults.suite

    /// The APN Token
    static var apnToken: String? {
        get {
            return defaults.string(forKey: kToken)
        }
        set { // Set by the callback in the app delegate
            let oldValue = apnToken
            defaults.set(newValue, forKey: kToken)
            apnTokenUpdated = Date()
            
            // If this is set then the user probably just authorised
            if oldValue != newValue && tokenShouldBeSent {
                sendFireBaseTokenToBackend()
            }
        }
    }

    private static func eraseFirebaseToken() {
        Messaging.messaging().deleteToken { error in
            if let error = error {
                Logger.log(tag: "PushNotificationRequest", message: "Failed to FB delete token: \(error.localizedDescription)")
            }
        }
    }

    static var failureMessage: String? {
        get {
            return defaults.string(forKey: kFailReason)
        }
        set {
            defaults.set(newValue, forKey: kFailReason)
        }
    }

    static func sendTokenToBackendIfNeeded() {
        if tokenShouldBeSent {
            sendFireBaseTokenToBackend()
        }
    }

    private(set) static var apnTokenUpdated: Date? {
        get {
            if let date = defaults.object(forKey: kTokenUpdated) as? Date {
                return date
            }

            return nil
        }
        set {
            defaults.set(newValue, forKey: kTokenUpdated)
        }
    }

}

// Sending to the backend
extension PushNotificationRequest {
    private static func sendFireBaseTokenToBackend() {
        URLRequest.getAuthToken { authToken in
            guard let authToken = authToken,
                  let fbToken = Messaging.messaging().fcmToken else {
                return
            }

            guard let request = makeRequest(authToken: authToken,
                                            fbToken: fbToken,
                                            method: "PUT") else {
                return
            }

            Task {
                let success = await sendRequest(request:request, fbToken: fbToken)
                if !success.0 { Logger.log(tag: "PushNotificationRequest", message: "Token send failed - 1") }
            }
        }
    }

    static func deleteFireBaseTokenFromBackend() async -> LogoutController.LogoutResult {
        guard let authToken = await URLRequest.getAuthToken() else { return .noAuthToken }
        guard let fbToken = try? await Messaging.messaging().token() else { return .noFbToken }
        guard let request = makeRequest(authToken: authToken,
                                        fbToken: fbToken,
                                        method: "DELETE") else {
            return .couldNotMakeRequestBody
        }

        let result = await sendRequest(request: request,
                                       fbToken: fbToken)
        let success = result.0
        let message = result.1

        var logoutResult: LogoutController.LogoutResult = .success
        if success {
            eraseFirebaseToken()
        }
        else {
            logoutResult = .unknown(message)
            Logger.log(tag: "PushNotificationRequest", message: "Token send failed - 1")
        }

        return logoutResult
    }

    static func makeRequest(authToken: String,
                                    fbToken: String,
                                    method: String) -> URLRequest? {
        let url = _GroupEndPoint("/notifications/notification/device-tokens")
        guard let data = bodyData(fbToken: fbToken) else { return nil }
        let request = RequestFactory.authenticatedRequest(url: url,
                                                   authToken: authToken,
                                                   method: method,
                                                   body: data)

        return request
    }

    private static func sendRequest(request: URLRequest,
                                    fbToken: String) async -> (Bool, String) {
        let method = request.httpMethod!
        guard let result = try? await URLSession.sendDataWith(request: request) else {
            return (false, "Logout error")
        }

        var success = result.httpCode == 201 || result.httpCode == 204
        if method == "DELETE" && result.httpCode == 404 { success = true }

        recordResult(fbToken: fbToken,
                     method: method,
                     success: success)

        let message = success ? "" : "Token \(method) failed with HTTP code: \(result.httpCode)"
        return (success, message)
    }

    static func bodyData(fbToken: String) -> Data? {
        guard let contactId = UserSessionManager.shared.currentUser?.sub else {
            return nil
        }

        let platform = "IOS"

        var dict = [String : String]()
        dict["platform"] = platform
        dict["userId"] = contactId
        dict["token"] = fbToken

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            return jsonData
        }
        catch {
            return nil
        }
    }
}

extension PushNotificationRequest: UNUserNotificationCenterDelegate {
    func requestNotificationPermissions(completion: (() -> Void)?) {
        if Platform.isSimulator { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            self.getSettings()

            DispatchQueue.main.async {
                if let completion = completion {
                    completion()
                }
            }
        }
    }

    private func getSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()

                // Listen for changes
                Messaging.messaging().delegate = self
            }
        }
    }
}

extension PushNotificationRequest: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if fcmToken != nil {
            PushNotificationRequest.sendTokenToBackendIfNeeded()
        }
    }
}

// MARK: - Records
extension PushNotificationRequest {

    /// Do not set this directly, set notificationRecord
    private static var _notificationRecord: NotificationSendRecord?
    private static var notificationRecord: NotificationSendRecord? {
        get {
            if let _notificationRecord = _notificationRecord {
                return _notificationRecord
            }

            if let data = defaults.object(forKey: kUpdateRecord) as? Data {
                if let n = NotificationSendRecord.loadFrom(data: data) {
                    _notificationRecord = n
                    return _notificationRecord
                }
            }

            return nil
        }
        set {
            _notificationRecord = newValue
            if let data = newValue?.data {
                defaults.set(data, forKey: kUpdateRecord)
            }
        }
    }

    private static func recordResult(fbToken: String,
                                     method: String,
                                     success: Bool) {
        guard let contactId = UserSessionManager.shared.currentUser?.individualId, !contactId.isEmpty else {
            return
        }

        let record = NotificationSendRecord(userId: contactId,
                                            fbToken: fbToken,
                                            lastSend: Date(),
                                            sendMethod: method,
                                            success: success)

        PushNotificationRequest.notificationRecord = record
    }
}

// MARK: - Logic for is the request should be sent
extension PushNotificationRequest {
    // Does a token need sending?
    private static var tokenShouldBeSent: Bool {

        if LogoutController.isLoggingOut {
            return false
        }

        if !hasAllRequiredDetailsToLogin {
            return false
        }

        // -- DELETE --
        // We dont resend deletes as if we are logged out we have no auth token
        // If the last was a delete, then we are either trying to log out again,
        // or we are trying to login, so always resend
        if lastWasDelete {
            return true
        }

        // If there is no notification record, then we should send
        guard let notificationRecord = notificationRecord else  {
            return true
        }

        // If the last was a fail
        if notificationRecord.success {
            // Is the FB token the same as records
            if notificationRecord.fbToken == Messaging.messaging().fcmToken {
                return false
            }

            return true
        }

        // If we fail, make sure its not in the last 10 seconds. Do not want to spam backend
        if notificationRecord.lastSend.inLast(seconds: 5)  {
            if notificationRecord.fbToken == Messaging.messaging().fcmToken {
                return false
            }
        }

        return true
    }

    private static var hasAllRequiredDetailsToLogin: Bool {
        if Messaging.messaging().fcmToken == nil ||
            !AuthorisationManager.shared.isLoggedIn ||
            apnToken == nil {
            return false
        }

        return true
    }

    private static var lastWasDelete: Bool {
        if let notificationRecord = notificationRecord  {
            if notificationRecord.sendMethod == "DELETE" {
                return true
            }
        }

        return false
    }
}
