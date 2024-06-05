//
//  ApScanViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 20/04/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit


class ApScanViewController: BaseConfigViewController {
    
    let viewModel = ApScanViewModel()
    @IBOutlet weak var reportTimeLabel: UILabel!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var rescanButton: UIBarButtonItem!
    
    // DFS Exclusion
    @IBOutlet weak var tableViewTopContraint: NSLayoutConstraint! // Show hide DFS
    @IBOutlet weak var reportTableView: UITableView!
    
    var hasWifiRadioBkgndScan = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel.scanTypeToShow == .ghz2 {
            self.title = "2.4 GHz Radio"
        }
        else if viewModel.scanTypeToShow == .ghz5 {
            self.title = "5 GHz Radio"
        }
        else if viewModel.scanTypeToShow == .mesh {
            self.title = "vMesh Radio"
        }
        
        if let cap = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig {
            hasWifiRadioBkgndScan = cap.hasWifiRadioBkgndScan
        }
                
        if traitCollection.userInterfaceStyle == .dark {
            reportTimeLabel.textColor = .label
        }
        if let ies = veeaHubConnection {
            viewModel.getLastScanDetails(veeaHub: ies) { [weak self] (success) in
                if success {
                    self?.reportTableView.reloadData()
                    self?.reportTimeLabel.text = self?.viewModel.lastReportDateCorrectedForTimezone
                    self?.footerLabel.text = self?.viewModel.footerLabelText
                }
                else {
                    self?.showErrorInfoMessage(message: "Error loading the report".localized())
                }
            }
        }
    }
    
    override func setTheme() {
        super.setTheme()
        rescanButton.tintColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
    }
    
    @IBAction func rescanTapped(_ sender: Any) {
        var message = "Starting a scan may take up to 30 seconds to complete. Would you like to continue?".localized()
        if veeaHubConnection?.connectionRoute == ConnectionRoute.CURRENT_GATEWAY {
            message = "Starting a scan will interrupt your connection to the VeeaHub.".localized()
        }
        
        let a = UIAlertController(title: "Warning".localized(), message: message, preferredStyle: .alert)
        
        a.addAction(UIAlertAction.init(title: "Cancel".localized(), style: .cancel, handler: nil))
        a.addAction(UIAlertAction.init(title: "Begin Scan".localized(), style: .destructive, handler: { (alert) in
            self.sendRecanRequest()
        }))
        
        present(a, animated: true, completion: nil)
    }
    
    private func sendRecanRequest() {
        guard let ies = veeaHubConnection else {
            return
        }
        
        let a = UIAlertController(title: "Requesting scan".localized(), message: "Please wait".localized(), preferredStyle: .alert)
        present(a, animated: true, completion: nil)
        
        viewModel.sendScanRequest(veeaHub: ies) { [weak self] success in
            self?.dismiss(animated: true, completion: nil)
            self?.showInfoMessage(message: "Scan started\n This may take up to 30 seconds to complete. Please wait.".localized())
            self?.startCheckingForUpdate()
        }
    }
    
    private func startCheckingForUpdate() {
        guard let ies = veeaHubConnection else {
            return
        }
        
        viewModel.startCheckingForUpdate(veeaHub: ies) { [weak self] (success, message) in
            DispatchQueue.main.async {
                if success {
                    self?.showInfoMessage(message: "Scan completed".localized())
                    self?.reportTableView.reloadData()
                    self?.reportTimeLabel.text = self?.viewModel.lastReportDateCorrectedForTimezone
                    self?.footerLabel.text = self?.viewModel.footerLabelText

                    return
                }

                let alert = UIAlertController(title: "Error".localized(),
                                              message: message,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK".localized(), style: .default, handler: nil))
                self?.present(alert, animated: true)
            }
        }
    }
}

extension ApScanViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.hasWifiRadioBkgndScan {
            return 180
        }
        return 220
    }
}

extension ApScanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if hasWifiRadioBkgndScan {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ScanResultCell
            cell.populate(report: viewModel.reports[indexPath.row])
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! ScanResultCellForNotHavingCapability
            if indexPath.row >= 0 && indexPath.row < viewModel.channelReports.count {
                cell.populate(report: viewModel.channelReports[indexPath.row])
            }
        }
        return UITableViewCell()
    }
}

class ScanResultCell: UITableViewCell {
    
    
    @IBOutlet weak var ssidValueLabel: UILabel!
    @IBOutlet weak var bssidValueLabel: UILabel!
    @IBOutlet weak var channelValueLabel: UILabel!
    @IBOutlet weak var bandwidthValueLabel: UILabel!
    @IBOutlet weak var rssiValueLabel: UILabel!
    
    func populate(report: NeighbourScanReport) {
        ssidValueLabel.text = report.ssid
        channelValueLabel.text = "\(report.channel ?? "")"
        bssidValueLabel.text = "\(report.bssid ?? "")"
        bandwidthValueLabel.text = "\(report.bw ?? "")"
        rssiValueLabel.text = "\(report.rssi ?? "")"
    }
}

class ScanResultCellForNotHavingCapability: UITableViewCell {
    @IBOutlet weak var channelNumberLabel: UILabel!
    @IBOutlet weak var bssLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var noiseFloorLabel: UILabel!
    @IBOutlet weak var loadLabel: UILabel!
    
    func populate(report: ChannelScanReport) {
        channelNumberLabel.text = " \("Channel".localized()): \(report.channel) (\("Rank".localized()): \(report.rank))"
        bssLabel.text = report.bss
        rssiLabel.text = "\(report.minrssi)/\(report.maxrssi)"
        noiseFloorLabel.text = report.nf
        loadLabel.text = report.chload
    }
}
