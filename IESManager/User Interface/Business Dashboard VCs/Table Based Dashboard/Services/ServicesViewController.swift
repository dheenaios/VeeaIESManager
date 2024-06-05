//
//  ServicesViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 30/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

class ServicesViewController: UIViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .subscriptions_screen

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectToHubButton: UIBarButtonItem!
    @IBOutlet weak var ipConnectButton: UIBarButtonItem!
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    private var vm: ServicesViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = ServicesViewModel(updateHandler: {
            self.update()
        })
        vm?.loadAvailableServices()
        
        hideConnectionOptions()
        
        title = "Subscriptions".localized()
        
        inlineHelpView.setText(labelText: "Any optional subscriptions available will appear below".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    private func update() {
        title = "Subscriptions".localized() + " (\(vm?.numberOfServices ?? 0))"
        tableView.reloadData()
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .services, push: true)
    }
    
    private func hideConnectionOptions() {
        connectToHubButton.isEnabled = false
        connectToHubButton.tintColor = .clear
        
        ipConnectButton.isEnabled = false
        ipConnectButton.tintColor = .clear
    }
}

extension ServicesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let package = vm?.packages![indexPath.row] {
            vm?.handleSelected(package: package, vc: self)
        }
    }
}

extension ServicesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm?.numberOfServices ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageCell", for: indexPath) as! PackageCell
        let package = vm!.packages![indexPath.row]

        cell.populate(package: package)
        
        return cell
    }
}

class PackageCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func populate(package: VHMeshNodePackage) {
        titleLabel.text = package.displayTitle ?? "Unknown"
        subTitleLabel.text = package.description ?? ""
        priceLabel.text = package.type?.uppercased() ?? "Unknown"
    }
}
