//
//  VeeaHubModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 6/10/21.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

public enum VeeaHubHardwareModel: CustomStringConvertible, CaseIterable {
    
    case vhc05
    case vhc06
    case vhe09
    case vhe10
    case vhc25
    case vhh09
    case unknown
    
    init(serial: String) {
        let prefix = String(serial.prefix(3))
        self = VeeaHubHardwareModel.getType(for: prefix)
    }
    
    init(qrCode: String) {
        let prefix = qrCode.split(from: 2, to: 4)
        self = VeeaHubHardwareModel.getType(for: prefix)
    }
    
    public var description: String {
        switch self {
        case .vhc05:
            return "VHC05"
        case .vhc06:
            return "VHC06"
        case .vhe09:
            return "VHE09"
        case .vhe10:
            return "VHE10"
        case .vhc25:
            return "VHC25"
        case .vhh09:
            return "VHH09"
        case .unknown:
            return "Unknown".localized()
        }
    }
    
    public static func getType(for prefix: String) -> VeeaHubHardwareModel {
        switch prefix {
        case "C05":
            return .vhc05
        case "C06":
            return .vhc06
        case "E09":
            return .vhe09
        case "E10":
            return .vhe10
        case "C25":
            return .vhc25
        case "VHH09":
            return .vhh09
        default:
            return unknown
        }
    }
}

extension VeeaHubHardwareModel {
    var numberOfUserConfigurableSsids: Int {
        switch self {
        case .vhc05:
            return 3
        default:
            return 4
        }
    }
    
    
    // AP Radio Config
    var canShowBandwidthOptions: Bool {
        return self != .vhe09
    }
    
    func isvhe09AndAp2(isAp2: Bool) -> Bool {
        return isAp2 && self == .vhe09
    }
}
