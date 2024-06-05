//
//  MeshesDataSource.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/18/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit


final class MeshesDataSource: NSObject, UITableViewDataSource {
    
    private let cellIdentifier = String(describing: VHMeshTableCell.self)
    var meshViewModels: [VUITableCellModelProtocol] = []
    var hasMultipleGroups : Bool = false
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meshViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! VHMeshTableCell

        if let model = meshViewModels.at(index: indexPath.row) {
            cell.setupcell(cellModel: model)
        }

        return cell
    }
    
    // Header title
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
        if self.meshViewModels.count > 0 {
            return "My Meshes".localized()
        }
        return nil
    }
    
}
