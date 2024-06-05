//
//  AccessabilityLabels.swift
//  IESManager
//
//  Created by Richard Stockdale on 28/11/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation


/// These should be added in code, not in the Storyboards (if can be helped)
struct AccessibilityConfigurations {

    // MARK: - Alerts

    static let alertOkButton = AccessibilityConfig(label: "OK Button",
                                                   identifier: "OK_Button")

    // MARK: - Login page
    static let loginOrSignUpButton = AccessibilityConfig(label: "Login or Sign Up",
                                                         identifier: "Login_Sign_Up_Button")

    // MARK: - Enterprise Main Tab Bar
    static let manageTab = AccessibilityConfig(label: "Manage",
                                               identifier: "Manage_tab_item")

    static let guidesTab = AccessibilityConfig(label: "Guides",
                                               identifier: "Guide_tab_item")

    static let myAccountTab = AccessibilityConfig(label: "My Account",
                                                  identifier: "My_account_tab_item")

    // MARK: - Settings Screen - My AccountTableViewController
    static let logoutRow = AccessibilityConfig(label: "Logout",
                                               identifier: "Logout_row")

    static let alertLogoutButton = AccessibilityConfig(label: "Logout",
                                                       identifier: "Logout_button")

    // MARK: - Enrollment
    static let buttonAddFirstHub  = AccessibilityConfig(label: "Add New VeeaHub",
                                                          identifier: "No_Veea_Hubs_yet_button")

    // The add hub button on the groups page
    static let buttonAddHub  = AccessibilityConfig(label: "Add VeeaHub",
                                                          identifier: "Add_VeeaHub_button")

    static let buttonAddVeeaHub  = AccessibilityConfig(label: "Add New VeeaHub",
                                                          identifier: "Add_New_VeeaHub_button")

    // Same continue button for hub and mesh naming
    static let textFieldNameHub = AccessibilityConfig(label: "Name Hub", identifier: "Enrol_Name_Hub_Textfield")
    
    static let searchMeshTxtField = AccessibilityConfig(label: "Search Mesh", identifier: "Search_Mesh_Text_Field")
    
    static let buttonNameContinue  = AccessibilityConfig(label: "Continue",
                                                          identifier: "Naming_screen_continue_button")
    

    static let buttonSkipSettingWifiPassword  = AccessibilityConfig(label: "Skip it",
                                                          identifier: "Wifi_Name_Password_Skip_Button")

    static let buttonTimezoneContinue  = AccessibilityConfig(label: "Continue",
                                                          identifier: "Timezone_screen_continue_button")

    static let buttonConfirmSettings  = AccessibilityConfig(label: "Confirm",
                                                          identifier: "Confirm_settings_button")

    static let buttonConnectDeviceDone  = AccessibilityConfig(label: "Done",
                                                          identifier: "Connect_device_done_button")
    
    static let meshDetailsHeadStatus = AccessibilityConfig(label: "Status", identifier: "mesh_head_status")
    static let veeahubSettingsTable = AccessibilityConfig(label: "VeeaHub Settings Table", identifier: "veeahub_settings_table")
}
