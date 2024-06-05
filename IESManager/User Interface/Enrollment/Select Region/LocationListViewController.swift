//
//  TimezoneListViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 2/7/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

protocol LocationSettingSelectorDelegate {
    func didSelect(value: String)
}

class LocationListViewController: TabTableViewController {
    
    var values: [String] = []
    var titleString: String!
    
    var delegate: LocationSettingSelectorDelegate?
    
    convenience init(data: [String], title: String, delegate: LocationSettingSelectorDelegate) {
        self.init()
        self.values = data
        self.delegate = delegate
        self.titleString = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset.bottom = self.navbarMaxY
        
    }
}


extension LocationListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: String(describing: UITableViewCell.self))
        }
        
        cell?.textLabel?.text = values[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\("Select".localized()) " + titleString
    }
}

extension LocationListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show selection with checkmark
        let selected = tableView.cellForRow(at: indexPath)
        selected?.tintColor = .vPurple
        selected?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.delegate?.didSelect(value: values[indexPath.row])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}
