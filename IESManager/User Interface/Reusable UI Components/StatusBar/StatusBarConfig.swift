//
//  StatusBarConfig.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 26/01/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit


/// Subclass this to configure the Status Bar
class StatusBarConfig {
    var barBackgroundColor: UIColor?
    var iconColor: UIColor?
    var icon: UIImage?
    var text: String?
    
    // MARK: Common icons
    lazy var notConfiguredIcon: UIImage = {
        return UIImage() // Empty image
    }()
    
    lazy var stopIcon: UIImage = {
        return UIImage(named: "state-circle + cross")!.withRenderingMode(.alwaysTemplate)
    }()
    
    lazy var checkIcon: UIImage = {
        return UIImage(named: "state-circle + tick")!.withRenderingMode(.alwaysTemplate)
    }()
    
    lazy var lockIcon: UIImage = {
        return UIImage(named: "state-not-enabled")!.withRenderingMode(.alwaysTemplate)
    }()
    
    lazy var warningInvalidIcon: UIImage = {
        return UIImage(named: "state-warning")!.withRenderingMode(.alwaysTemplate)
    }()
    
    lazy var needsSubmit: UIImage = {
        return UIImage(named: "state-change-not-submitted")!.withRenderingMode(.alwaysTemplate)
    }()
    
    lazy var portNeverUpIcon: UIImage = {
        return UIImage(named: "portNeverUpIcon")!
    }()
    
    // MARK: Common colors
    let backgroundGreen = UIColor(named: "statusBarGreen")!
    let backgroundOrange = UIColor(named: "statusBarOrange")!
    let backgroundRed = UIColor(named: "statusBarRed")!
    let backgroundBlue = UIColor(named: "statusBarTeal")!
    let backgroundYellow = UIColor(named: "statusBarYellow")!
    let backgroundGrey = UIColor(named: "statusGrey")
    let portNeverUpGrey = UIColor(named: "portNeverUpGrey")
    
    let iconGreen = UIColor.systemGreen
    let iconOrange = UIColor.orange
    let iconRed = UIColor.red
    let iconBlue = UIColor.systemTeal
}

// MARK: - Subclasses

class PortStatusBarConfig: StatusBarConfig {
    enum State {
        case otherInUseHub
        case otherInUseMesh
        case disabled
        case notOperational
        case active
        case inactive
        case editingNotValid
        case editingValid
        case neverUsed
    }
    
    /// Set this to true to override the state color and show as grey
    var state: State
    
    init(state: State) {
        self.state = state
        super.init()
        setUp(state: state)
    }
    
    func setUp(state: State) {
        switch state {
        case .otherInUseHub:
            barBackgroundColor = backgroundBlue
            iconColor = iconBlue
            text = "Hub In Use".localized()
            icon = checkIcon
            break
        case .otherInUseMesh:
            barBackgroundColor = backgroundBlue
            iconColor = iconBlue
            text = "Network In Use".localized()
            icon = checkIcon
            break
        case .inactive:
            barBackgroundColor = backgroundGrey
            iconColor = UIColor.darkGray
            text = "Not in use".localized()
            icon = notConfiguredIcon
            break
        case .disabled:
            barBackgroundColor = backgroundOrange
            iconColor = iconOrange
            text = "Disabled".localized()
            icon = lockIcon
            break
        case .notOperational:
            barBackgroundColor = backgroundRed
            iconColor = iconRed
            text = "Non-Operational".localized()
            icon = stopIcon
            break
        case .active:
            barBackgroundColor = backgroundGreen
            iconColor = iconGreen
            text = "Active".localized()
            icon = checkIcon
            break
        case .editingNotValid:
            barBackgroundColor = backgroundYellow
            iconColor = .black
            text = "Incomplete".localized()
            icon = warningInvalidIcon
        case .editingValid:
            barBackgroundColor = backgroundGrey
            iconColor = .black
            text = "Changes not applied".localized()
            icon = needsSubmit
        case .neverUsed:
            barBackgroundColor = portNeverUpGrey
            iconColor = .gray
            text = "Never Active".localized()
            icon = portNeverUpIcon
        }
    }
}

class ApStatusBarConfig: StatusBarConfig {
    enum State {
        case notConfigured
        case otherInUseHub
        case otherInUseMesh
        case useButNotEnabled
        case operational
        case notOperational
        case editingNotValid
        case editingValid
    }
    
    private(set) var state: State
    
    init(state: State) {
        self.state = state
        super.init()
        setUp(state: state)
    }
    
    func setUp(state: State) {
        self.state = state
        
        switch state {
        case .notConfigured:
            barBackgroundColor = backgroundGrey
            iconColor = UIColor.darkGray
            text = "Not in use".localized()
            icon = notConfiguredIcon
            
        case .otherInUseHub:
            barBackgroundColor = backgroundBlue
            iconColor = iconBlue
            text = "Hub In Use".localized()
            icon = checkIcon
            break
        case .otherInUseMesh:
            barBackgroundColor = backgroundBlue
            iconColor = iconBlue
            text = "Network In Use".localized()
            icon = checkIcon
            break
        case .useButNotEnabled:
            barBackgroundColor = backgroundOrange
            iconColor = iconOrange
            text = "Disabled".localized()
            icon = lockIcon
        case .operational:
            barBackgroundColor = backgroundGreen
            iconColor = iconGreen
            text = "Active".localized()
            icon = checkIcon
        case .notOperational:
            barBackgroundColor = backgroundRed
            iconColor = iconRed
            text = "Non-Operational".localized()
            icon = stopIcon
        case .editingNotValid:
            barBackgroundColor = backgroundYellow
            iconColor = .black
            text = "Incomplete".localized()
            icon = warningInvalidIcon
        case .editingValid:
            barBackgroundColor = backgroundGrey
            iconColor = .black
            text = "Changes not applied".localized()
            icon = needsSubmit
        }
    }
}
