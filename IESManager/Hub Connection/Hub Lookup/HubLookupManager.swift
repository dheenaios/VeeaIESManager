//
//  HubLookupManagerProtocol.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 12/08/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation


/// Lookup state
///
/// - LOADING: Getting the requested information
/// - LOADED: The requests has returned successfully
/// - ERROR: There was an issue with the lookup
enum HubLookUpLoadingState {
    case LOADING
    case LOADED
    case ERROR
}

/// Struct containing details of look up results
struct NodeIPDetails {
    var nodeId: String?
    var nodeName: String?
    var nodeIp: String?
    
    init(id: String, name: String, ip: String) {
        nodeId = id
        nodeName = name
        nodeIp = ip
    }
    
    init() {
        
    }
}

/// Super class for DnsLookupManager & MdnsLookupManager.
/// Performs all the setup for the two subclasses, getting mesh
/// and Device information.
class HubLookupManager {
    
    public var loadingState: HubLookUpLoadingState = .LOADING
    
    public private(set) var availableMeshes: [VHMesh]?
    public private(set) var availableNodes = [VHMeshNode]()
    
    public var nodeIpDetails = [NodeIPDetails]()
    
    init(groupId : String) {
        loadingState = .LOADING
        
        EnrollmentService.getOwnerConfig(groupId: groupId) {[weak self] (meshes) in
            if let meshes = meshes {
                self?.updateMeshesAndNodes(meshes: meshes)
            }
        } error: { [weak self] err in
            self?.loadingState = .ERROR
        }
    }
    
    public func updateMeshesAndNodes(meshes: [VHMesh]) {
        self.loadingState = .LOADED
        self.availableMeshes = meshes
        self.populateNodes()
        self.requestIps()
    }
    
    
    /// Override this and implement the lookup code specific to the method
    internal func requestIps() {
       // print("!!!! populate needs to be implemented in sub class !!!!")
    }
    
    private func populateNodes() {
        guard let meshes = availableMeshes else {
            return
        }
        
        for mesh in meshes {
            if let nodes = mesh.devices {
                for node in nodes {
                    var found = false
                    for availableNode in availableNodes {
                        if availableNode == node { found = true }
                    }
                    
                    if !found {
                        availableNodes.append(node)
                    }
                }
            }
        }
    }
}
