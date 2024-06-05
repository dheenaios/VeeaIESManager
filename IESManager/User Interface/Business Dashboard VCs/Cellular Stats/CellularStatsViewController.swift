//
//  CellularStatsViewController.swift
//  VeeaHub Manager
//
//  Created by Al on 17/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit


class CellularStatsViewController: UIViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .cell_info_screen

    var flowController: HubInteractionFlowController?
    
    @IBOutlet private weak var plmnLabel: UILabel!
    @IBOutlet private weak var signalStrengthIcon: UIImageView!
    @IBOutlet private weak var statsTableView: UITableView!
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    private var loadingWarning: UIAlertController?
    // Quectel Info
//    @IBOutlet weak var footerView: UIView!
//    @IBOutlet weak var simStatusValue: UILabel!
//    @IBOutlet weak var networkRegStatValue: UILabel!
    
    private var refreshTimer: Timer?
    
    var hubConnection: HubConnectionDefinition?  = {
        return HubDataModel.shared.connectedVeeaHub
    }()
    
    private var viewModel = CellularStatsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            //self.footerView.isHidden = true
            self.refresh()
        }
        
        inlineHelpView.setText(labelText: "These readonly statistics are available on gateway VeeaHubs enabled for 4G backhaul.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .cellular_stats, push: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
        self.statsTableView.reloadData()
        self.showLoadingView(show: true)
        
        // Call refresh every 7 seconds
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 7, repeats: true, block: { (timer) in
            self.refresh()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        refreshTimer?.invalidate()
    }
    
    func refresh() {
        viewModel.updateDataModel { [weak self] (stats, error) in
            self?.showLoadingView(show: false)
            guard let stats = stats else {
                //self?.footerView.isHidden = true
                self?.signalStrengthIcon.image = UIImage(named: "strength_0_bars")
                
                return
            }
            
            self?.plmnLabel.text = stats.plmn
            self?.setSignalStrengthImage(stats: stats)

            self?.statsTableView.reloadData()
        }
    }
    
    private func setSignalStrengthImage(stats: CellularStats) {
        let image = viewModel.signalStrengthImage
        signalStrengthIcon.image = image
    }
}

extension CellularStatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

extension CellularStatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellularStatsCell", for: indexPath) as! KeyValueCell
        let model = viewModel.tableViewRows[indexPath.row]
        
        cell.keyLabel.text = model.key
        cell.valueLabel.text = model.value
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewRows.count
    }
}

extension CellularStatsViewController {
    func showLoadingView(show: Bool) {
        if show {
            if loadingWarning == nil {
                loadingWarning = UIAlertController(title: "Loading".localized(),
                                                   message: "Getting cellular information".localized(),
                                                   preferredStyle: .alert)
            }
            
            self.present(loadingWarning!,
                         animated: true,
                         completion: nil)
        }
        else {
            guard let loadingWarning = loadingWarning else { return }
            loadingWarning.dismiss(animated: true, completion: nil)
        }
    }
}
