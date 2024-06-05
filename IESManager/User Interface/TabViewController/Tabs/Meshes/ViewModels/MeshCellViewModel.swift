//
//  MeshCellViewModel.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 4/9/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

struct MeshCellViewModel: VUITableCellModelProtocol {
    
    let imageName: String!
    let titleText: String!
    let detailText: String!
    let rightText: String!
    
    init(meshData: VHMesh) {
        self.rightText = ""
        self.imageName = "mesh_black_small"
        
        // Check for corrupted mesh, will avoid unnecessary crash
        if meshData.name == nil {
            self.titleText = "Corrupted Mesh".localized()
            self.detailText = "This mesh is corrupt and unreadable.".localized()
        } else {
            self.titleText = meshData.name
            
            let deviceCount = meshData.devices?.count ?? 0
            var devicesCountText = "1 VeeaHub".localized()
            if deviceCount > 1 {
                devicesCountText = "\(deviceCount) \("VeeaHubs".localized())"
            }
            self.detailText = devicesCountText
        }
    }
}
