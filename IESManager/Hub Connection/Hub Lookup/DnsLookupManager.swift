//
//  DnsLookupManager.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 25/07/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking


class DnsLookupManager: HubLookupManager {
    
    override init(groupId : String) {
        super.init(groupId: groupId)
    }
    
    override func requestIps() {
        getIPs()
        loadingState = .LOADED
    }
    
    private func getIPs() {
        if availableNodes.isEmpty {
            return
        }
        
        // Filter to make sure we only have one instance of each id
        var filteredNodes = [VHMeshNode]()
        for node in availableNodes {
            guard let id = node.id else {
                continue
            }
            
            if node.status != VHNodeStatus.ready {
                continue
            }
            
            // Make sure there is only one instance of this id
            for filteredNode in filteredNodes {
                if filteredNode.id == id {
                    continue
                }
            }
            
            filteredNodes.append(node)
        }
        
        for node in filteredNodes {
            var nd = NodeIPDetails()
            
            guard let id = node.id else { continue }

            nd.nodeName = node.name
            nd.nodeId = id
            
            if let dnsIp = DnsLookUp.getIPFrom(dnsName: id) {
                nd.nodeIp = dnsIp
                
                nodeIpDetails.append(nd)
            }
        }
    }
}
