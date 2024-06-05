//
//  AnalyticsEventHelper.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 04/02/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import SharedBackendNetworking

// See: https://max2team.atlassian.net/wiki/spaces/VHM/pages/754712639/Google+Analytics+for+VHM
class AnalyticsEventHelper {
    
    private struct ParamKeys {
        static let deviceIdKey = "deviceID"
        static let userIdKey = "userID"
        static let screenNameKey = "screenName"
        static let reasonKey = "reason"
        static let qrCodeDetailsKey = "qrCodeDetails"
        static let typeOfUser = "type_user"
        static let isVeeaUser = "isVeeaUser"
    }

    //====================================================
    // MARK: - User Enrollment

    static public func recordUserEnrollmentStart() {
        var params = [String : Any]()
        params[ParamKeys.userIdKey] = currentUserId
        recordEvent(name: AnalyticsEvents.user_onboarding_for_enrollment_start,
                    params: params)
    }

    static public func recordUserEnrollmentCancelled(screenName: String) {
        var params = [String : Any]()
        params[ParamKeys.userIdKey] = currentUserId
        params[ParamKeys.screenNameKey] = screenName
        recordEvent(name: AnalyticsEvents.user_onboarding_for_enrollment_cancelled,
                    params: params)
    }

    //====================================================
    // MARK: - Login

    /// Record that the user has started a login attempt
    static public func recordUserLoginStart() {
        recordEvent(name: AnalyticsEvents.user_login_begin,
                    params: [String : Any]())
    }

    /// Record that the user has logged in
    static public func recordLoginSuccess() {
        var params = [String : Any]()
        params[ParamKeys.userIdKey] = currentUserId
        recordEvent(name: AnalyticsEvents.login_succeeded,
                    params: params)
    }

    /// Record that the user has failed to login
    /// - Parameter reason: Reason for the failure
    static public func recordLoginFail(reason: String) {
        var params = [String : Any]()
        params[ParamKeys.userIdKey] = currentUserId
        params[ParamKeys.reasonKey] = reason

        recordEvent(name: AnalyticsEvents.login_failed,
                    params: params)
    }

    //====================================================
    // MARK: - Device Enrolment

    /// Record that the user has started device enrollment
    /// - Parameter deviceId: the id of the device being enrolled
    static public func recordDeviceEnrollmentStart(deviceId: String) {
        recordEvent(name: AnalyticsEvents.enrollment_device_start,
                    params: enrolmentParams(deviceId: deviceId))
    }

    /// Record that the user has enrolled their device
    /// - Parameter deviceId: the id of the device being enrolled
    static public func recordDeviceEnrollmentSuccess(deviceId: String) {
        recordEvent(name: AnalyticsEvents.enrollment_device_succeed,
                    params: enrolmentParams(deviceId: deviceId))
    }

    /// Record that the user has failed to enroll their device
    /// - Parameter deviceId: the id of the device being enrolled
    static public func recordDeviceEnrollmentFailed(deviceId: String, reason: String) {
        var params = enrolmentParams(deviceId: deviceId)
        params[ParamKeys.reasonKey] = reason

        recordEvent(name: AnalyticsEvents.enrollment_device_failed,
                    params: params)
    }

    //====================================================
    // MARK: - QR Code scanning
    static public func qrCodeScanFailed(reason: String, qrCodeDetails: String) {
        var params = [String : Any]()
        params[ParamKeys.qrCodeDetailsKey] = qrCodeDetails
        params[ParamKeys.reasonKey] = reason

        recordEvent(name: AnalyticsEvents.user_scan_qrcode_failed,
                    params: params)
    }

    //====================================================
    // MARK: - Screens

    static public func logScreenEvent(screenName: AnalyticsEvents.ScreenNames, screenClass: String) {
        let params = [AnalyticsParameterScreenName: screenName.rawValue,
                     AnalyticsParameterScreenClass: screenClass]

        recordEvent(name: AnalyticsEventScreenView,
                    params: params)
    }

    //====================================================
    // MARK: - Connection attempts

    static func logConnection(connection: AnalyticsEvents.ApiConnection) {
        recordEvent(name: connection.eventName,
                    params: connection.params)
    }
}

extension AnalyticsEventHelper {


    /// Funnel all event details through this method
    /// - Parameters:
    ///   - name: The name of the event
    ///   - params: The params for the even. Usertypw and isVeeaUser are added automatically
    private static func recordEvent(name: String, params: [String : Any]) {
        var modifiedParams = params
        modifiedParams[ParamKeys.typeOfUser] = currentUserType
        modifiedParams[ParamKeys.isVeeaUser] = isVeeaUser

        Analytics.setUserProperty(isVeeaUser,
                                  forName: ParamKeys.isVeeaUser)

        print("---\nSending analytics package named: \(name)\nIsVeeaUser: \(isVeeaUser)\nParams: \(modifiedParams)\n---")

        Analytics.logEvent(name, parameters: modifiedParams)
    }

    private static var isVeeaUser: String {
        guard let user = UserSessionManager.shared.currentUser,
              let email = user.email else {
            return "false"
        }

        return EmailValidation.isVeeaUser(email: email) ? "true" : "false"
    }

    private static var currentUserType: String {
        Target.currentTarget.isHome ? "home" : "enterprise"
    }

    private static var currentUserId: String {
        get {
            let userIdTuple = UserSessionManager.shared.currentUserId

            return userIdTuple.string
        }
    }

    private static func enrolmentParams(deviceId: String) -> [String: Any] {
        var params = [String : Any]()
        params[ParamKeys.userIdKey] = currentUserId
        params[ParamKeys.deviceIdKey] = deviceId

        return params
    }
}
