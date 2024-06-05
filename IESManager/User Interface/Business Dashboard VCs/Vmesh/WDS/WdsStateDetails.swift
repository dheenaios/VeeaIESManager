//
//  WdsStateDetails.swift
//  IESManager
//
//  Created by Richard Stockdale on 09/11/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

struct NodeInfoModel: Hashable {

    let name: String
    let bssid: String

    // Report items
    let hops: String?
    let snr: String?

    var detailsText: [String] {
        guard let hops,
              let snr else {
            return ["BSSID: ".localized() + bssid]
        }

        return ["BSSID: ".localized() + bssid,
                "Hops: ".localized() + hops,
                "SNR: ".localized() + snr]
    }

    internal init(name: String,
                  bssid: String,
                  hops: String? = nil,
                  snr: String? = nil) {
        self.name = name
        self.bssid = bssid
        self.hops = hops
        self.snr = snr
    }
}

struct WdsStateDetails {
    private var lastReport: WdsScanReport?

    private var odm: OptionalAppsDataModel? {
        return HubDataModel.shared.optionalAppDetails
    }

    private lazy var meshWdsTopologyConfig: MeshWdsTopologyConfig? = {
        return odm?.meshWdsTopologyConfig
    }()

    var nodesConnectedString: String {
        let connectedNodesSingle = "Node Connected".localized()
        let connectedNodesPlural = "Nodes Connected".localized()
        guard lastReport != nil else {
            if numberNodesConnected == 1 {
                return "\(numberNodesConnected) \(connectedNodesSingle)"
            }

            return "\(numberNodesConnected) \(connectedNodesPlural)"
        }

        if nodesPresent.count == 1 {
            return "\(nodesPresent.count) \(connectedNodesSingle)"
        }

        return "\(nodesPresent.count) \(connectedNodesPlural)"
    }

    var nodesPresent: [NodeInfoModel] {
        var arr = [NodeInfoModel]()

        for node in allTopologyNodes {
            if let report = reportInfoFor(node: node) {
                arr.append(report)
            }
        }

        return arr
    }

    private var numberNodesConnected: Int {
        guard let nodes = odm?.meshWdsTopologyConfig?.nodes else {
            return 0
        }

        return nodes.count
    }

    private func reportInfoFor(node: MeshWdsTopologyConfig.WdsTopologyNode) -> NodeInfoModel? {
        // Do not return the currently connected hubs report
        if let currentHubName = HubDataModel.shared.baseDataModel?.nodeConfig?.node_name {
            if currentHubName == node.node_name {
                return nil
            }
        }

        guard let lastReport,
              let bssidReport = lastReport.bssid_report[node.firstBssidAp] else {
            return nil
        }

        return NodeInfoModel(name: node.node_name, bssid: node.firstBssidAp,
                       hops: "\(bssidReport.hops)",
                       snr: "\(bssidReport.rssi)")
    }

    private var nodes: [String : MeshWdsTopologyConfig.WdsTopologyNode] {
        guard let nodes = HubDataModel.shared.optionalAppDetails?.meshWdsTopologyConfig?.nodes else {
            return [String : MeshWdsTopologyConfig.WdsTopologyNode]()
        }

        return nodes
    }

    private var allTopologyNodes: [MeshWdsTopologyConfig.WdsTopologyNode] {
        var arr = [MeshWdsTopologyConfig.WdsTopologyNode]()
        for key in nodes.keys {
            if let item = nodes[key] {
                arr.append(item)
            }
        }

        return arr
    }

    init(lastReport: WdsScanReport?) {
        self.lastReport = lastReport
    }
}
