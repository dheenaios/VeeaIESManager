//
//  HomeDataSource.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/7/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class HomeDataSource: NSObject, UITableViewDataSource {
    
    var sections: [VHHomeViewModel] = []
    
    private let cellIdentifier = "cell"
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 //sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections.count > 0 {
            return sections[section].rows.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowItem = sections[indexPath.section].rows[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? VUILargeIconTableCell
        
        if cell == nil {
            cell = VUILargeIconTableCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell?.setupcell(cellModel: rowItem)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionItem = sections[section]
        return sectionItem.sectionTitle
    }
}
