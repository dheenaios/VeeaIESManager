//
//  SdWanCellularStatsViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/07/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class SdWanCellularStatsViewController: BaseConfigViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .data_usage_screen

    var flowController: HubInteractionFlowController?
    
    private var viewModel: SdWanCellularStatsViewModel?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SdWanCellularStatsViewModel()
        title = "Data Usage".localized()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
}

extension SdWanCellularStatsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.sectionTitles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.sectionTitles[section] ?? nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel?.bytesSent.count ?? 0
        }
        else if section == 1 {
            return viewModel?.bytesReceived.count ?? 0
        }
        else {
            return viewModel?.billing.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        guard let viewModel = viewModel else {
            return cell
        }
        
        var rowModel: SdWanCellularStatsViewModel.ConfigRow?
        
        if indexPath.section == 0 {
            rowModel = viewModel.bytesSent[indexPath.row]
        }
        else if indexPath.section == 1 {
            rowModel = viewModel.bytesReceived[indexPath.row]
        }
        else if indexPath.section == 2 {
            rowModel = viewModel.billing[indexPath.row]
        }
        
        guard let model = rowModel else {
            return cell
        }
        
        cell.textLabel?.text = model.mTitle
        cell.detailTextLabel?.text = model.value
        
        return cell
    }
}
