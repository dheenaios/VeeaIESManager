//
//  MeshWdsTopologyConfig.swift
//  IESManager
//
//  Created by Richard Stockdale on 12/10/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

public struct MeshWdsTopologyConfig: TopLevelJSONResponse, Codable {
    static let tableName = "mesh_wds_topology"
    var originalJson: JSON = JSON()
    let nodes: [String : WdsTopologyNode]?

    private enum CodingKeys: String, CodingKey {
        case nodes
    }

    public struct WdsTopologyNode: Codable, Hashable {

        let mode: String
        let bssid_ap: [String] // '00:76:3d:01:4b:18',
        let bssid_sta: [String] // '06:76:3d:01:4b:18',
        let node_name: String // 'VH-1490',
        //let connected_uplink_bssid: ] // {}



        /// Returns an empty string if there is no bssid_ap
        var firstBssidAp: String {
            bssid_ap.first ?? ""
        }

        // 12 October 2022 14:29:03: Not sure what values connected_uplink_bssid should have
    }
}
