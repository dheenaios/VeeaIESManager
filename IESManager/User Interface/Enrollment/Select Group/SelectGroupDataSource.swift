//
//  SelectGroupDataSource.swift
//  VeeaHub Manager
//
//  Created by Bajirao Bhosale on 01/06/21.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class SelectGroupDataSource: NSObject, UITableViewDataSource {
    
    private let cellIdentifier = "meshCell"
    var groupVM : GroupsViewModel?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (groupVM?.groups?.count ?? 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? VUITableViewCell
        
        if cell == nil {
            cell = VUITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        // Add create new mesh option
        if let gvm = groupVM {
            cell?.setupcell(cellModel: self.getCellModel(for: gvm.groups![indexPath.row]))
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a Group to add to".localized()
    }
    
    // MARK - Helper Methods
    
    func getCellModel(for groupData: GroupModel) -> VUITableCellModel {
        var cellModel = VUITableCellModel()
        cellModel.title = groupData.name
        var meshesStr = groupData.counts.meshes == 0 ? "No mesh".localized() : "\(groupData.counts.meshes) \("meshes".localized())"
        if groupData.counts.meshes == 1 {
            meshesStr = "1 mesh".localized()
        }
        cellModel.subtitle = meshesStr
        cellModel.icon = "group_list_icon"
        cellModel.roundedIcon = false
        return cellModel
    }
    
}
