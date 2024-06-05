//
//  HubHealthFetcher.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 21/06/2022.
//

import Foundation

struct HubHealthFetcher {
    public static func fetchHealthFor(nodes: [NodeModel]) {
        let baseUrl = BackEndEnvironment.masApiBaseUrl

        let ids = nodes.map{ $0.id }


    }
}
