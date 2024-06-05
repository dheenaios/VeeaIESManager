//
//  NodeConfigViewController.swift
//  VeeaHub Manager
//
//  Created by Al on 09/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit


class NodeConfigViewController: BaseConfigTableViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .about_screen

    var flowController: HubInteractionFlowController?
    
    
    @IBOutlet weak var timeCell: UITableViewCell!
    @IBOutlet weak var hubLocationCell: UITableViewCell!
    @IBOutlet weak var serialNumber: UILabel!
    @IBOutlet weak var nodeTypeLabel: UILabel!
    @IBOutlet weak var swVersion: UILabel!
    @IBOutlet weak var osVersion: UILabel!
    @IBOutlet weak var restartTime: UILabel!
    @IBOutlet weak var lastRestartReason: UILabel!
    @IBOutlet weak var restartRequiredLabel: UILabel!
    @IBOutlet weak var unitHardwareVersion: UILabel!
    @IBOutlet weak var unitHardwareRevision: UILabel!
    @IBOutlet weak var unitID: UILabel!
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    @IBOutlet weak var localeLabel: TitledTextField!
    
    private var vm = NodeConfigViewModel()
    
    var accessChannelPickerController: PickerController<Int>!
    var secondaryChannelPickerController: PickerController<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About VeeaHub".localized()
        populate()
        
        refreshControl!.attributedTitle = NSAttributedString(string: "Updating time...".localized(), attributes: nil)
        refreshControl!.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        inlineHelpView.setText(labelText: "This screen provides information about this VeeaHub. You can also set the VeeaHubs name, locale, and type.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .about_veeaHub, push: true)
    }
    
    @objc private func refreshData(_ sender: Any) {
        self.tableView.reloadData()
        
        vm.refreshTime { (message, error) in
            self.refreshControl!.endRefreshing()
            if error != nil {
                return
            }
            
            self.tableView.reloadData()
            self.populate()
        }
    }
    
    func refreshHubTime() {
            vm.refreshTime { (message, error) in
                if error != nil {
                    return
                }
                
                self.populate()
            }
        }
    
    private func populate() {
        DispatchQueue.main.async {
            self.serialNumber.text = self.vm.veeaHubUnitSerialNumber

            self.nodeTypeLabel.text = self.vm.nodeType
            self.swVersion.text = self.vm.softwareVersion
            self.osVersion.text = self.vm.osVersion
            self.restartTime.text = self.vm.restartTime
            self.lastRestartReason.text = self.vm.lastRestartReason
            self.restartRequiredLabel.text = self.vm.restartRequiredReason
            
            if self.vm.rebootRequired {
                self.restartRequiredLabel.textColor = .red
            }
            else {
                self.restartRequiredLabel.textColor = UIColor.init(named: "DashboardIconGreen")
            }
            
            self.unitHardwareRevision.text = self.vm.hardwareRev
            self.unitHardwareVersion.text = self.vm.hardwareVersion
            self.unitID.text = self.vm.nodeSerial
            self.localeLabel.text = self.vm.locale
            self.localeLabel.delegate = self
            
            // Time and Location
            self.hubLocationCell.detailTextLabel?.text = self.vm.locationText
            self.timeCell.detailTextLabel?.text = self.vm.nodeTime
            
            self.tableView.reloadData()
        }
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        accessChannelPickerController = nil
        secondaryChannelPickerController = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()

        populate()
        refreshHubTime()
        
        // Refresh again to cope with hub wierdness
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.refreshHubTime()
        }
        
        if vm.rebootRequired == true {
            let reason = vm.restartRequiredReason
            showErrorInfoMessage(message: "\("A restart is required for".localized()) \(reason) \("changes to take effect".localized())")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if indexPath.section == 2 &&
            indexPath.row == 2 &&
            !TesterMenuDataModel.UIOptions.disableDestructiveOptions {
            nodeTypeLabel.text = nodeTypeLabel.text == "MEN" ? "MN" : "MEN"
            vm.nodeType = nodeTypeLabel.text!
            applyButtonIsHidden = !vm.hasConfigChanged()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // An MN/MEN change causes the IES to restart
    override func done(_ sender: Any) {
        if vm.nodeType != nodeTypeLabel.text! {
            displayRestartRequiredWarning(customMessage: nil) { (shouldRestart) in
                if shouldRestart {
                    super.done(sender)
                }
            }
        }
        else {
            super.done(sender)
        }
    }
    
    override func applyConfig() {
        guard connection != nil else {
            //print("No IES")
            return
        }
        
        if sendingUpdate == true {
            return
        }
        
        sendingUpdate = true
        updateUpdateIndicatorState(state: .uploading)
        
        vm.nodeType = nodeTypeLabel.text!
        vm.locale = localeLabel.text!
        
        vm.update { [weak self] (result, error) in
            self?.sendingUpdate = false
            
            if error != nil {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                self?.showErrorUpdatingAlert(error: error!)
                
                return
            }
            
            HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
        }
    }
}

extension NodeConfigViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}

extension NodeConfigViewController: TitledTextFieldDelegate {
    func textDidChange(sender: TitledTextField) {
        vm.locale = localeLabel.text!
        applyButtonIsHidden = !vm.hasConfigChanged()
    }
}
