//
//  WDSLinksViewModel.swift
//  UI_Playground
//
//  Created by Richard Stockdale on 13/10/2022.
//

import Foundation

class WDSLinksViewModel {
    var nodes: [String : MeshWdsTopologyConfig.WdsTopologyNode] {
        guard let nodes = HubDataModel.shared.optionalAppDetails?.meshWdsTopologyConfig?.nodes else {
            return [String : MeshWdsTopologyConfig.WdsTopologyNode]()
        }

        return nodes
    }

    // MARK: - Uplink
    var shownUplinkDetails: Bool {
        HubDataModel.shared.baseDataModel?.vmeshConfig?.vmeshLocalControlMode != .start
    }

    var uplinkNodeName: String {
        if let uplinkNode {
            return uplinkNode.node_name
        }

        return "Unknown"
    }

    var uplinkNodeBssid: String? {
        guard let bssid = HubDataModel.shared.baseDataModel?.nodeStatusConfig?.vmesh_wds_upstream_bssid,
              !bssid.isEmpty else {
            return nil
        }

        return bssid
    }

    var uplinkNodeSelection: String {
        if let bssid = HubDataModel.shared.baseDataModel?.nodeConfig?.vmesh_wds_manual_bssid,
           !bssid.isEmpty {
            for node in allNodes {
                if node.firstBssidAp == bssid {
                    return node.node_name
                }
            }
        }

        return "Auto"
    }

    private var uplinkNode: MeshWdsTopologyConfig.WdsTopologyNode? {
        guard let bssid = HubDataModel.shared.baseDataModel?.nodeStatusConfig?.vmesh_wds_upstream_bssid else {
            return nil
        }

        for node in allNodes {
            if node.bssid_ap.isEmpty { continue }
            if node.bssid_ap.first == bssid {
                return node
            }
        }

        return nil
    }

    private var allNodes: [MeshWdsTopologyConfig.WdsTopologyNode] {
        var arr = [MeshWdsTopologyConfig.WdsTopologyNode]()
        for key in nodes.keys {
            if let item = nodes[key] {
                arr.append(item)
            }
        }

        return arr
    }
}
