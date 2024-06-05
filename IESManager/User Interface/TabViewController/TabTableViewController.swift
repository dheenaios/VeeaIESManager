//
//  TabTableViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/7/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class TabTableViewController: VUIViewController {
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.contentInset.bottom = self.tabBarHeight
        tableView.verticalScrollIndicatorInsets.bottom = self.navbarMaxY
        tableView.alwaysBounceVertical = true
        tableView.separatorInsetReference = .fromAutomaticInsets
        self.tableView.separatorInset = .zero
        self.view.addSubview(tableView)
    }
    
}
