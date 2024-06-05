//
//  APConfigurationViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 14/02/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

class APConfigurationViewController: BaseConfigViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .wifi_settings_screen

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    var vm: APConfigurationViewModel?
    
    public var tabController: APConfigSelectionViewController?
    
    private var isMN: Bool {
        get {
            return HubDataModel.shared.isMN
        }
    }
    
    public func configure(freq: SelectedAP,
                          hub: HubConnectionDefinition,
                          tabBarVc: APConfigSelectionViewController) {
        veeaHubConnection = hub
        self.tabController = tabBarVc
        vm = APConfigurationViewModel.init(freq: freq)
    }
    
    override func applyConfig() {
        sendingUpdate = true
        updateUpdateIndicatorState(state: .uploading)
        
        tabController?.vcIsDoneWithUpdates(handler: { [weak self]  (error) in
            if let error = error {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                self?.showErrorUpdatingAlert(error: error)
                
                return
            }
        })
    }
    
    override func cancel(_ sender: Any) {
        tabController?.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag
        vm?.selectedOperation = vm?.operationOptionOfWIFI ?? .Start
        inlineHelpView.setText(labelText: "These Wi-Fi settings allow configuration of different Wi-Fi parameters.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
        self.tableView.reloadData()
    }
    
    public func refreshScreenWhenOperationDisabled() {
        self.tableView.reloadData()
    }

    private func pushToHelp() {
        displayHelpFile(file: .wifi_aps, push: true)
    }
    
    func cellWasUpdated() {
        tabController?.childVcDataModelWasUpdated()
    }
    
    public func isDataModelUpdated() -> Bool {
        return vm?.isDataModelUpdated ?? false
    }
    
    func showIsMnWarning() {
        if isMN {
            showInfoAlert(title: "Unable to select Network".localized(), message: "The \"Network\" AP is not configured. If you want to select or use the \"Network\" AP, please configure it from MEN.".localized())
        }
    }
}

extension APConfigurationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if vm?.selectedOperation == .Disabled {
            return 60.0
        }
        return 330
    }
}

extension APConfigurationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vm?.selectedOperation == .Disabled {
            return 1
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if vm?.selectedOperation == .Disabled {
            return 1
        }
        return vm?.tableViewModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if vm?.selectedOperation == .Disabled {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DisabledInfoCell", for: indexPath) as! DisabledInfoCell
            cell.backgroundColor = .clear
            return cell
        }
        
        guard let nodeCapabilitiesConfig = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig else {
            Logger.log(tag: "APConfigurationViewController", message: "No data model")
            return UITableViewCell()
        }
        
        if nodeCapabilitiesConfig.hasWifiSecurity {
            let cell = tableView.dequeueReusableCell(withIdentifier: "apConfigCell", for: indexPath) as! APConfigurationCell
            guard let  cellModel = vm?.tableViewModels?[indexPath.section] else { return cell }
            cell.configure(model: cellModel)
            cell.hostViewController = self
            
            return cell
        }
        else {
            let legacyCell = tableView.dequeueReusableCell(withIdentifier: "legacyCell", for: indexPath) as! LegacyAPConfigurationCell
            guard let  cellModel = vm?.tableViewModels?[indexPath.section] else { return legacyCell }
            legacyCell.configure(model: cellModel)
            legacyCell.hostViewController = self
            
            return legacyCell
        }
    }
}
