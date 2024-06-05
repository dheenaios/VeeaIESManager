//
//  LanConfigurationViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 24/03/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation


// As of VHM-1595 the lan configuration tabs will need to share state info.
// So it seems sensible to lift the state out of the individual vc vms to a single class
// that can be refererenced by all
class LanConfigurationViewModel {
    private var bdm: HubBaseDataModel
    private var odm: OptionalAppsDataModel

    private(set) var nodeLanConfig: NodeLanConfig
    private(set) var meshLanConfig: MeshLanConfig
    private(set) var nodeWanConfig: NodeWanConfig
    private(set) var nodeLanStatus: NodeLanStatusConfig
    private(set) var staticIpDetails: NodeLanStaticIpConfig
    var nodeLanConfigStaticIpDetails: NodeLanConfigStaticIp? // Need to support legacy

    private let originalNodeLanConfig: NodeLanConfig
    private let originalMeshLanConfig: MeshLanConfig
    private let originalNodeWanConfig: NodeWanConfig
    private let originalNodeLanStatus: NodeLanStatusConfig
    private let originalStaticIpDetails: NodeLanStaticIpConfig
    private var originalNodeLanConfigStaticIpDetails: NodeLanConfigStaticIp? // Need to support legacy


    var nodeLanConfigChanged: Bool { nodeLanConfig != originalNodeLanConfig }
    var meshLanConfigChanged: Bool { meshLanConfig != originalMeshLanConfig }
    var nodeWanConfigChanged: Bool { nodeWanConfig != originalNodeWanConfig }
    var nodeLanStatusChanged: Bool { nodeLanStatus != originalNodeLanStatus }
    var staticIpDetailsChanged: Bool { staticIpDetails != originalStaticIpDetails }
    var nodeLanConfigStaticIpDetailsChanges: Bool {
        guard let nodeLanConfigStaticIpDetails,
              let originalNodeLanConfigStaticIpDetails else { return false }
        return nodeLanConfigStaticIpDetails != originalNodeLanConfigStaticIpDetails
    }

    var supportsBackpack: Bool {
        bdm.nodeCapabilitiesConfig?.usesNodeLanConfigStaticIpTable ?? false
    }

    var supportsIpMode: Bool {
        bdm.nodeCapabilitiesConfig?.usesSomeIpModeTable ?? false
    }

    init?() {
        guard let bdm = HubDataModel.shared.baseDataModel,
              let odm =  HubDataModel.shared.optionalAppDetails else {
            return nil
        }

        self.bdm = bdm
        self.odm = odm

        guard let nodeLanConfig = odm.nodeLanConfig,
              let meshLanConfig = bdm.meshLanConfig,
              let nodeWanConfig = bdm.nodeWanConfig,
              let nodeLanStatus = odm.nodeLanStatus,
              let staticIpDetails = odm.nodeLanStaticIpConfig else {
            return nil
        }

        self.nodeLanConfig = nodeLanConfig
        self.meshLanConfig = meshLanConfig
        self.nodeWanConfig = nodeWanConfig
        self.nodeLanStatus = nodeLanStatus
        self.staticIpDetails = staticIpDetails

        self.originalNodeLanConfig = nodeLanConfig
        self.originalMeshLanConfig = meshLanConfig
        self.originalNodeWanConfig = nodeWanConfig
        self.originalNodeLanStatus = nodeLanStatus
        self.originalStaticIpDetails = staticIpDetails

        self.nodeLanConfigStaticIpDetails = odm.nodeLanConfigStaticIp
        self.originalNodeLanConfigStaticIpDetails = odm.nodeLanConfigStaticIp
    }
}

// WanMode
extension LanConfigurationViewModel {
    /// Get the wan mode for a given lan
    /// - Parameter lan: The lans position (0 indexed, so 0 = lan 1)
    /// - Returns: The wan mode
    func getWanMode(for lan: Int) -> WanMode {
        meshLanConfig.lans[lan].wanMode
    }

    func setMeshLan(meshLan: MeshLan?,
                    for lan: Int) {
        guard let meshLan else { return }

        switch lan {
        case 0:
            meshLanConfig.lan_1 = meshLan
        case 1:
            meshLanConfig.lan_2 = meshLan
        case 2:
            meshLanConfig.lan_3 = meshLan
        case 3:
            meshLanConfig.lan_4 = meshLan
        default:
            Logger.log(tag: "LanConfigurationViewModel", message: "Tried to set unsupported meshLan (\(lan)")
        }
    }
}

// IP Management
extension LanConfigurationViewModel {

    func getIpManagementMode(for lan: Int) -> IpManagementMode? {
        meshLanConfig.lans[lan].ipManagementMode
    }

    /// Default mode for the current selection (VHM-1596)
    func defaultIpManagementMode(lan: Int) -> IpManagementMode {
        let wanMode = getWanMode(for: lan)
        return wanMode.defaultIpManagementMode
    }

    func isIpModeValidForWanMode(ipMode: IpManagementMode, for lan: Int) ->  Bool {
        let modes = availableIpManagementModes(lan: lan)
        let valid = modes.contains { $0 == ipMode }

        return valid
    }

    // Get valid IP management modes available for the given wan mode  (VHM-1596)
    func availableIpManagementModes(lan: Int) -> [IpManagementMode] {
        let wanMode = getWanMode(for: lan)
        return wanMode.availableIpManagementModes
    }
}

/*

 TODO:
 The LAN screens where all written at different times and then brought together under
 the lan configuration view controller. How the handle diffing and updating varies.
 Using this view model, we could unify a significant chunck of that code and reduce
 complexity.

 -[ ] Centralise updating in the model
 -[ ] Centralise config mode diffing

 */
