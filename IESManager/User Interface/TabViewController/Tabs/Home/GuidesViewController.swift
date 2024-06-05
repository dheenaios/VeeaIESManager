//
//  HomeViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/4/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class GuidesViewController: TabTableViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .guides_screen

    
    var dataSource = HomeDataSource()
    var homeRealm: Bool = Target.currentTarget.isHome

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Guides".localized()
        tableView.dataSource = dataSource
        tableView.delegate = self
                
        updateTheme()
        loadData()
        recordScreenAppear()
    }
    
    func loadData() {
        do {
            let file = homeRealm ? "HomeDataModel-Home" : "HomeDataModel"
            if let homeData = try Bundle.main.jsonData(fromFile: file, format: "json") {
                let sections = try JSONDecoder().decode([VHHomeViewModel].self, from: homeData)
                self.dataSource.sections = sections

                if tableView != nil { // Check if this is nil to support testing when view is no on screen
                    self.tableView.reloadData()
                }

            }
        }catch let error {
            fatalError("Could not read from filepath: HomeDataModel.json \(error)")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    private func updateTheme() {
        if Target.currentTarget.isHome {
            if let nv = navigationController?.navigationBar,
               let bg = tableView.backgroundColor {
                setNavigationBarAttributes(navigationBar: nv,
                                           color: bg,
                                           transparent: true)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension GuidesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let link = self.dataSource.sections[indexPath.section].rows[indexPath.row].link {
            let webView = VUIWebViewController.init(urlString: link)
            webView.modalPresentationStyle = .overFullScreen
            self.present(webView, animated: true, completion: nil)
        }
    }
}
