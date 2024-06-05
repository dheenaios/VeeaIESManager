//
//  SelectMeshDataSource.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/17/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class SelectMeshDataSource: NSObject, UITableViewDataSource {
    
    private let cellIdentifier = "meshCell"
    var meshes: [VHMesh]?
    
    var searchTerm = ""
    var searchedMeshes: [VHMesh]? {
        if searchTerm.isEmpty { return meshes }
        
        let filtered = meshes?.filter({ item in
            item.name.lowercased().contains(searchTerm.lowercased())
        })
        
        return filtered
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchedMeshes?.count ?? 0) + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? VUITableViewCell
        
        if cell == nil {
            cell = VUITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }

        cell?.accessibilityLabel = "Row_\(indexPath.row)"
        cell?.isAccessibilityElement = true
        
        // Add create new mesh option
        let meshCount = searchedMeshes?.count ?? 0
        if indexPath.row >= meshCount || (indexPath.row == 0 && meshCount == 0) {
            cell?.setupcell(cellModel: self.getLastCellModel())
            cell?.accessibilityLabel = self.getLastCellModel().title
            cell?.isAccessibilityElement = true
        } else {
            if searchedMeshes != nil {
                cell?.setupcell(cellModel: self.getCellModel(for: searchedMeshes![indexPath.row]))
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select Mesh to add to".localized()
    }
    
    // MARK - Helper Methods
    
    func getCellModel(for meshData: VHMesh) -> VUITableCellModel {
        var cellModel = VUITableCellModel()
        cellModel.title = meshData.name
        let deviceCount = meshData.devices?.count ?? 0
        var devicesCountText = "1 VeeaHub".localized()
        if deviceCount > 1 {
            devicesCountText = "\(deviceCount) VeeaHubs"
        }
        cellModel.subtitle = devicesCountText
        cellModel.icon = "mesh_black_small"
        return cellModel
    }
    
    func getLastCellModel() -> VUITableCellModel {
        var cellModel = VUITableCellModel()
        cellModel.type = .text
        cellModel.title = "+ Create new mesh...".localized()
//        cellModel.icon = "iconVHMesh"
        return cellModel
    }
}
