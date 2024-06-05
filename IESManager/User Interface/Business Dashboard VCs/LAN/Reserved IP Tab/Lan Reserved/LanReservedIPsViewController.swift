//
//  StaticIPsViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 25/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

/// TAB 3: RESERVED IP
class LanReservedIPsViewController: BaseConfigViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .lan_settings_screen
    private let sb = UIStoryboard(name: "LanConfiguration", bundle: nil)

    private let tag = "StaticIPsViewController"
    var vm: LanReservedIPsViewModel!
    private var updated = false
    
    @IBOutlet weak var addReservedButton: UIButton!
    @IBOutlet weak var addReservedButtonCircle: UIButton!
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet weak var lanSelector: LanPickerView!
    @IBOutlet private weak var modelsTableView: UITableView!
    @IBOutlet weak var addIPView: UIView!
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    weak var delegate: LanConfigurationParentDelegate?

    static func new(delegate: LanConfigurationParentDelegate,
                    parentVm: LanConfigurationViewModel) -> LanReservedIPsViewController {
        let sb = UIStoryboard(name: "LanConfiguration", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "StaticIPsViewController") as! LanReservedIPsViewController
        vc.delegate = delegate
        vc.vm = LanReservedIPsViewModel(parentViewModel: parentVm)

        return vc
    }
    
    @IBAction func addRule(_ sender: Any) {
        showNewReservationDialog()
    }
    
    override func setTheme() {
        addReservedButton.backgroundColor = colorManager
            .themeTint
            .colorForAppearance
        addReservedButtonCircle.backgroundColor = colorManager
            .themeTint
            .colorForAppearance
    }
    
    func deleteItem(configModel: NodeLanStaticIpModel,
                    selectedLan: Int,
                    reservationNumber: Int) {
        vm.staticIpDetails.lans[selectedLan].remove(at: reservationNumber)

        modelsTableView.reloadData()
        showHideFooter()
        
        guard let ies = veeaHubConnection else { return }
        
        ApiFactory.api.setConfig(connection: ies, config: vm.staticIpDetails) { (result, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.showInfoMessage(message: "Reserved IP Deleted".localized())
                    self.vm.staticIpDetails.updateOriginalJson()
                }
                //print("\("Uploaded reservation deletion.".localized()) \(result ?? "No info".localized()), \(error?.localizedDescription ?? "")")
                self.requestDataModelUpdate()
            }
        }
    }
    
    private func requestDataModelUpdate() {
        HubDataModel.shared.updateConfigInfo(observer: nil)
    }
    
    private func showNewReservationDialog() {
        if let vc = UIStoryboard(name: "LanConfiguration", bundle: nil).instantiateViewController(withIdentifier: "NewStaticIpViewController") as? NewLanReservedIpsViewController {
            vc.lanNumber = lanSelection
            vc.modalPresentationStyle = .formSheet
            vc.delegate = self
            
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lanSelector.hostVc = self
        modelsTableView.keyboardDismissMode = .onDrag
        showHideFooter()
        
        inlineHelpView.setText(labelText: "Individual devices on wireless APs or LAN ports can be assigned reserved IP addresses. You can add up to 10 reserved IP addresses on each LAN.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
    }

    private func updateForIpManagementSetting() {
        let disabled = vm.tableViewDisabled(lan: lanSelection)
        modelsTableView.disableView(disabled: disabled)
        addReservedButtonCircle.isHidden = disabled
        if disabled {
            showInfoMessage(message: "Reserved IPs can only be created if WAN MODE is \"Routed\" and IP MDOE is set to \"Server\".".localized())
        }
    }

    private func pushToHelp() {
        displayHelpFile(file: .lan_reserved_ips, push: true)
    }
    
    private func showHideFooter() {
        let currentLanModels = vm.staticIpDetails.lans[lanSelection]
        addIPView.isHidden = !currentLanModels.isEmpty
    }
    
    private var lanSelection: Int {
        return delegate?.selectedLan ?? 0
    }
    
    func validateEntries() -> String {
        let lans = vm.staticIpDetails.lans
        var errorMessage = ""
        
        for (index, lan) in lans.enumerated() {
            for entry in lan {
                if entry.use {
                    // Check there is a name OR a mac address
                    if entry.host.isEmpty && entry.mac.isEmpty {
                        errorMessage.append("LAN \(index + 1): \("Device Name or MAC Address required\n".localized())")
                    }
                }
                
                let errorStr = LanReservedIPsViewModel.validateAgainstDHCPSettings(hostIpAddress: entry.ip,
                                                               lanNumber: index)
                if !errorStr.isEmpty {
                    errorMessage.append("LAN \(index + 1): \(errorStr)\n")
                }
                
                if !entry.mac.isEmpty && !AddressAndPortValidation.isMacAddressValid(string: entry.mac) {
                    errorMessage.append("\("MAC address on entry on LAN".localized()) \(index + 1) " + "is invalid\n".localized())
                }
            }
        }
        
        return errorMessage
    }
    
    func configDidChange(model:NodeLanStaticIpModel,
                         lanNumber: Int,
                         reservation: Int) {
        vm.staticIpDetails.lans[lanNumber][reservation] = model
        
        let original = HubDataModel.shared.optionalAppDetails?.nodeLanStaticIpConfig
        if original != vm.staticIpDetails {
            updated = true
            delegate?.childUpdateStateChanged(updated: true)
            
            return
        }
        
        updated = false
        delegate?.childUpdateStateChanged(updated: false)
    }
}

extension LanReservedIPsViewController: NewLanReservedIpsViewControllerDelegate {
    func didCreateNewItem(model: NodeLanStaticIpModel, lan: Int) {
        vm.staticIpDetails.lans[lan].append(model)
        
        guard let ies = veeaHubConnection else {
            //print("No VeeaHub")
            return
        }
        
        ApiFactory.api.setConfig(connection: ies, config: vm.staticIpDetails) { (result, error) in
            if error == nil { self.vm.staticIpDetails.updateOriginalJson() }
            
            self.requestDataModelUpdate()
        }
        
        modelsTableView.reloadData()
        let count = vm.staticIpDetails.lans[lan].count
        modelsTableView.scrollToRow(at: IndexPath(item: 0, section: (count - 1)),
                                    at: .bottom,
                                    animated: true)
        showHideFooter()
    }
}

extension LanReservedIPsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Enter EITHER the device name OR the device MAC address, AND the IP address".localized()
    }
}

extension LanReservedIPsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StaticIpConfigCell
        
        let model = vm.staticIpDetails.lans[lanSelection][indexPath.section]
        cell.configure(model: model,
                       lan: lanSelection,
                       reservationNumber: indexPath.section,
                       hostVc: self)
                
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.staticIpDetails.lans[lanSelection].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\("Reserved IP".localized()) \(section + 1)"
    }
}

extension LanReservedIPsViewController: LanConfigurationChildViewControllerProtocol {
    func shouldShowRestartWarning() -> Bool {
        hasUpdated
    }
    func returnErrorMessage() -> String? {
        return ""
    }
    
    func entriesAreValid() -> Bool {
        let errorMessage = validateEntries()
        
        if !errorMessage.isEmpty {
            showInfoAlert(title: "Error".localized(), message: errorMessage)
            return false
        }
        
        return true
    }
    
    func sendUpdate(completion: @escaping BaseConfigViewModel.CompletionDelegate) {
        guard let ies = veeaHubConnection else {
            completion(nil, APIError.NoConnection)
            //print("No IES")
            return
        }
        
        ApiFactory.api.setConfig(connection: ies, config: self.vm.staticIpDetails, completion: completion)
    }
    
    var hasUpdated: Bool {
        return updated
    }
    
    func childDidUpdateSelectedLan(lan: Int) {
        delegate?.selectedLan = lan

        modelsTableView.reloadData()
        updateForIpManagementSetting()
        showHideFooter()
    }
    
    func childDidBecomeActive() {
        guard let lan = delegate?.selectedLan else { return }
        
        let sLan = LanPickerView.Lans.lanFromInt(lan: lan)
        lanSelector.selectedLan = sLan
    }
}
