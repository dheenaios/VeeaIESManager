//
//  AnayticsEvents.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 04/02/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

// See: https://veea.atlassian.net/wiki/spaces/VHM/pages/239202107453/Google+Analytics+event+details+for+VHM
public struct AnalyticsEvents {

    // MARK: - Significant Events

    ///The user began an enrolment attempt. The user taps the login button
    static let user_login_begin = "user_login_start"
    
    ///The VHM receives a login success response from the backend
    static let login_succeeded = "login_succeeded"
    
    ///The VHM receives a login failed response from the backend.
    static let login_failed = "log_failed"
    
    ///The VHM requests enrolment to the backend
    static let enrollment_device_start = "enrollment_device_start"
    
    ///The VHM receives a success response from the backend
    static let enrollment_device_succeed = "enrollment_device_succeed"
    
    ///The VHM receives a fail response from the backend
    static let enrollment_device_failed = "enrollment_device_failed"
    
    ///The user starts the enrollment process by tapping continue on the Add Device page
    static let user_onboarding_for_enrollment_start = "user_onboarding_for_enrollment_start"
    
    ///The user cancels the enrollment process
    static let user_onboarding_for_enrollment_cancelled = "user_onboarding_for_enrollment_cancelled"
    
    ///The user failed to scan QRcode
    static let user_scan_qrcode_failed = "user_scan_qrcode_failed"


    // MARK: - Screen Events

    // Names of the screens. Should be sent to analytics upon screen presentation
    // Names are the same in iOS and Android. Consult and update the confluence page if any are added
    public enum ScreenNames: String {
        case groups_screen
        case meshes_screen
        case mesh_details_screen
        case enterprise_onboarding_screen
        case installing_veeahub_screen
        case advanced_veeahub_settings
        case home_dashboard_screen
        case home_wifi_screen
        case home_cell_data_usage_screen
        case home_security_settings_screen
        case home_manage_veeahubs_screen
        case wifi_settings_screen
        case lan_settings_screen
        case lan_static_ip
        case wan_settings_screen
        case mesh_settings_screen
        case ports_settings_screen
        case ip_address_settings_screen
        case router_settings_screen
        case cell_info_screen
        case data_usage_screen
        case firewall_settings_screen
        case subscriptions_screen
        case bt_details_screen
        case about_screen
        case guides_screen
        case my_account_screen
    }

    public struct ApiConnection {

        let eventName = "ApiConnection"

        let route: ConnectionRoute
        let stage: ConnectionStage

        var apiType: ApiType {
            if route == .mas {
                return ApiType.masApi
            }

            return ApiType.hubApi
        }

        var params: [String: String] {
            ["route" : route.rawValue,
             "stage" : stage.rawValue,
             "apiType" : apiType.rawValue]
        }

        enum ConnectionRoute: String { case mas, lan, ap }
        enum ConnectionStage: String { case start, succeed, fail }
        enum ApiType: String { case masApi, hubApi }
    }
}
