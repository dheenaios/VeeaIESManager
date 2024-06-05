//
//  MeshHardwareIncompatability.swift
//  IESManager
//
//  Created by Richard Stockdale on 22/05/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation

struct MeshHardwareInCompatibilityResult {

    /// A users readable description of the issue
    let message: String

    /// Is the incompatibility total or partial.
    /// If partial, then inform the user and allow them to continue
    /// If total, then they should not be allowed to contunue
    let totalIncompatibility: Bool
}

/// VHM-1571:
/// Some compinations of veeahubs can limit the availability of some features.
/// This struct codifies the limitations.
struct MeshHardwareIncompatability {

    /// Returns a string if there are any limitations the user should know about
    /// - Parameter men: The hardware model of the men being used to create the mesh
    /// - Returns: Optional MeshHardwareInCompatibilityResult detailing any issues.
    static func createMeshWith(men: VeeaHubHardwareModel) -> MeshHardwareInCompatibilityResult? {
        if men == .vhc05 {
            let m = "If your gateway VeeaHub is a VHC05, the mesh must be built only with VHC05 VeeaHubs.".localized()
            return MeshHardwareInCompatibilityResult(message: m,
                                                     totalIncompatibility: false)
        }

        return nil
    }


    /// Returns details of any compatability issues between hub models
    /// - Parameters:
    ///   - mn: The model of MN
    ///   - men: The model of MEN at the core of the mesh
    /// - Returns: Optional MeshHardwareInCompatibilityResult detailing any issues.
    static func add(mn: VeeaHubHardwareModel, toMenModel men: VeeaHubHardwareModel) -> MeshHardwareInCompatibilityResult? {
        if men == .vhe09 {
            if mn == .vhe10 {
                let m = "When using a VHE09 as a gateway with a VHE10, wireless meshing may not work.".localized()
                return MeshHardwareInCompatibilityResult(message: m,
                                                         totalIncompatibility: false)
            }
        }

        if men == .vhc05 {
            if mn != .vhc05 {
                let m = "Your gateway VeeaHub is a VHC05. This mesh should only be extended using VHC05 VeeaHubs.".localized()
                return MeshHardwareInCompatibilityResult(message: m,
                                                         totalIncompatibility: true)
            }
        }

        return nil
    }
}
