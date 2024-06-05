//
//  RoutesTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/10/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

class RoutesTableViewController: UITableViewController {

    private struct RouteOptions {
        static let masOnline = 0
        static let lan = 1
        static let ap = 2
        static let masOnOffline = 3
    }
    
    @IBOutlet weak var masApiCell: UITableViewCell!
    @IBOutlet weak var lanCell: UITableViewCell!
    @IBOutlet weak var hubApCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        save()
    }
    
    private func populate() {
        let routes = TesterDefinedConnectionRoutes.selectedRoutes
        
        masApiCell.accessoryType = .none
        lanCell.accessoryType = .none
        hubApCell.accessoryType = .none
        
        for route in routes {
            switch route {
            case .hubAvailableOnMas:
                masApiCell.accessoryType = .checkmark
            case .lan:
                lanCell.accessoryType = .checkmark
            case .ap:
                hubApCell.accessoryType = .checkmark
            }
        }
    }
    
    private func save() {
        var routes = Set<TesterDefinedConnectionRoutes.ConnectionRoute>()
        let cells = [masApiCell, lanCell, hubApCell]
        
        for (index, cell) in cells.enumerated() {
            guard let cell = cell else {
                continue
            }
            
            if cell.accessoryType != .checkmark {
                continue
            }
            
            if index == RouteOptions.masOnline {
                routes.insert(TesterDefinedConnectionRoutes.ConnectionRoute.hubAvailableOnMas)
            }
            else if index == RouteOptions.lan {
                routes.insert(TesterDefinedConnectionRoutes.ConnectionRoute.lan)
            }
            else if index == RouteOptions.ap {
                routes.insert(TesterDefinedConnectionRoutes.ConnectionRoute.ap)
            }
        }
        
        TesterDefinedConnectionRoutes.selectedRoutes = routes
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType =  cell.accessoryType == .checkmark ? .none : .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
