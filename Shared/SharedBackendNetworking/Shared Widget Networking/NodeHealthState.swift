//
//  NodeHealthState.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 21/06/2022.
//

import Foundation
import SwiftUI

public enum NodeHealthState {

    // In order of severity
    case healthy
    case busy
    case errors
    case installing
    case needsReboot
    case offline
    case unknown

    public var stateTitle: String {
        switch self {
        case .healthy:
            return "Healthy".localized()
        case .busy:
            return "Busy".localized()
        case .errors:
            return "Error".localized()
        case .offline:
            return "Offline".localized()
        case .installing:
            return "Installing".localized()
        case .needsReboot:
            return "Reboot Required".localized()
        case .unknown:
            return "Unknown".localized()
        }
    }

    public var color: Color {
        switch self {
        case .healthy:
            return .stateHealthy
        case .busy:
            return .stateBusy
        case .errors:
            return .stateErrors
        case .offline:
            return .stateOffLine
        case .installing:
            return .stateInstalling
        case .needsReboot:
            return .stateNeedsReboot
        case .unknown:
            return .stateUnknown
        }
    }
}

extension Color {
    static var stateHealthy: Color {
        return Color(UIColor(named: "stateHealthy")!)
    }

    static var stateBusy: Color {
        return Color(UIColor(named: "stateBusy")!)
    }

    static var stateInstalling: Color {
        return Color(UIColor(named: "stateInstalling")!)
    }

    static var stateErrors: Color {
        return Color(UIColor(named: "stateErrors")!)
    }

    static var stateOffLine: Color {
        return Color(UIColor(named: "stateOffline")!)
    }

    static var stateUnknown: Color {
        return Color(UIColor(named: "stateUnknown")!)
    }

    static var stateNeedsReboot: Color {
        return Color(UIColor(named: "stateNeedReboot")!)
    }
}
