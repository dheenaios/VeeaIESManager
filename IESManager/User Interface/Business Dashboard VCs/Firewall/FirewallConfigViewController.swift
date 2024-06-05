//
//  FirewallConfigViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 27/04/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit


class FirewallConfigViewController: BaseConfigViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .firewall_settings_screen

    var flowController: HubInteractionFlowController?
    
    let vm = FirewallViewModel()
    
    @IBOutlet weak var addRuleButton: UIButton!
    
    @IBOutlet weak var segmentedController: VeeaSegmentedControl!
    @IBOutlet private weak var rulesTable: UITableView!
    @IBOutlet private weak var noRulesView: UIView!
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rulesTable.keyboardDismissMode = .onDrag
        
        if HubDataModel.shared.isMN {
            segmentedController.removeSegment(at: 1, animated: false)
        }
        
        title = "Firewall".localized()
        
        inlineHelpView.setText(labelText: "This screen allows configuration of firewall rules. Existing rules are displayed on two tabs, ACCEPT/DROP RULES and FORWARD RULES.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
        
        setTheme()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .firewall, push: true)
    }
    
    override func setTheme() {
        addRuleButton.backgroundColor = colorManager
            .themeTint
            .colorForAppearance
        
        updateNavBarWithDefaultColors()
    }
    
    // MARK: - Rules
    
    /// Rules to be displayed in the tableView. Delete rules are
    /// ommitted, but remain in acceptDenyRules / forwardRules
    
    private var tableViewRules: [FirewallRule] {
        if segmentedController.selectedSegmentIndex == 0 { return acceptDenyTableViewRules }
        else { return forwardTableViewRules }
    }
    
    private var acceptDenyTableViewRules: [FirewallRule] {
        get {
            let allRules = vm.acceptDenyFiltered
            noRulesView.isHidden = !allRules.isEmpty
            
            return allRules
        }
    }
    
    private var forwardTableViewRules: [FirewallRule] {
        get {
            let allRules = vm.forwardFiltered
            noRulesView.isHidden = !allRules.isEmpty
            
            return allRules
        }
    }
    
    @IBAction func ruleTypeSelectionChanged(_ sender: Any) {
        rulesTable.reloadData()
    }
    
    // MARK: Fetch Rules
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchRules()
    }
    
    private func fetchRules() {
        vm.fetchRules { [weak self] (message, error) in
            if let e = error {
                self?.showInfoAlert(title: message!, message: e.errorDescription())
                
                return
            }
            
            self?.rulesTable.reloadData()
        }
    }
    
    @IBAction func addRuleTapped(_ sender: Any) {
        showNewRuleDialog()
    }
    
    private func showNewRuleDialog() {
        if let vc = UIStoryboard(name: "Firewall", bundle: nil).instantiateViewController(withIdentifier: "NewFirewallRuleViewController") as? NewFirewallRuleViewController {
            
            vc.modalPresentationStyle = .formSheet
            let rule = FirewallRule(with: newID)
            
            let isFwd = segmentedController.selectedSegmentIndex == 1
            vc.configure(rule: rule, isFwd: isFwd)
            vc.delegate = self
            
            let navController = UINavigationController(rootViewController: vc)
            
            present(navController, animated: true, completion: nil)
        }
    }
    
    /// The top most ID + 1 if connected to the mas
    /// nil if connected to the Hub API
    private var newID: Int? {
        get {
            if let connection = veeaHubConnection {
                if connection is MasConnection {
                    let nId = vm.getTopId() + 1
                    return nId
                }
            }
            
            return nil
        }
    }
    
    // MARK: Push Rules to IES
    
    override func applyConfig() {
        if vm.forwardRules.isEmpty && vm.acceptDenyRules.isEmpty {
            dismissCard()
        }
        
        if vm.forwardRules.count > 10 {
            let message = "\("You have".localized("You have xxx accept/deny rules. 10 is the maximum.")) \(vm.forwardRules.count) \("forward rules. 10 is the maximum.".localized("You have xxx forwarding rules. 10 is the maximum."))"
            showInfoAlert(title: "\("Update failed".localized())", message: message)
            return
        }
        else if vm.acceptDenyRules.count > 10 {
            let message = "\("You have".localized("You have xxx accept/deny rules. 10 is the maximum.")) \(vm.acceptDenyRules.count) \("accept/deny rules. 10 is the maximum.".localized("You have xxx accept/deny rules. 10 is the maximum."))"
            showInfoAlert(title: "Update failed".localized(), message: message)
            return
        }
        
        var errorsString = ""
        for rule in vm.forwardRules {
            if let error = AddressAndPortValidation.validateRule(rule: rule) {
                errorsString.append("\(error)\n")
            }
        }
        for rule in vm.acceptDenyRules {
            if let error = AddressAndPortValidation.validateRule(rule: rule) {
                errorsString.append("\(error)\n")
            }
        }
        
        if !vm.forwardRulesHaveUniquePorts() {
            errorsString.append("Two or more of your forward rules use the same port and protocol. Make sure ports are unique.\n".localized())
        }
        
        if !vm.forwardRulesHaveUniqueLocalPorts() {
            errorsString.append("Two or more of your forward rules use the same local port on the same host. Make sure ports are unique.\n".localized())
        }
        
        if errorsString.count > 0 {
            showInfoAlert(title: "Rule Error".localized(), message: "\("The following errors were found".localized()):\n\(errorsString)")
            return
        }
        
        pushChanges(popBackToDashOnFinish: true)
    }
    
    private func pushChanges(popBackToDashOnFinish: Bool) {
        guard let ies = veeaHubConnection else {
            return
        }
        
        if sendingUpdate == true { return }
        var rulesToAction = [FirewallRule]()
        
        if veeaHubConnection is MasConnection {
            rulesToAction.append(contentsOf: vm.forwardRules)
            rulesToAction.append(contentsOf: vm.acceptDenyRules)
        }
        else {
            for rule in vm.acceptDenyRules {
                if rule.mUpdateState != .CURRENT || rule.mUpdateState != .NEW_DELETED {
                    if rule.isValid == true {
                        rulesToAction.append(rule)
                    }
                }
            }
            for rule in vm.forwardRules {
                if rule.mUpdateState != .CURRENT || rule.mUpdateState != .NEW_DELETED {
                    if rule.isValid == true {
                        rulesToAction.append(rule)
                    }
                }
            }
        }
        
        self.view.endEditing(true)
        
        sendingUpdate = true
        updateUpdateIndicatorState(state: .uploading)
        
        sendUpdate(connection: ies, rulesToAction: rulesToAction, popBackToDashOnFinish: popBackToDashOnFinish)
    }
    
    fileprivate func sendUpdate(connection: HubConnectionDefinition,
                                rulesToAction: [FirewallRule],
                                popBackToDashOnFinish: Bool) {
        ApiFactory.api.updateFirewall(connection: connection,
                                      rules: rulesToAction) { [weak self]  (rules, error) in
            self?.sendingUpdate = false
            
            if error != nil {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                
                self?.showErrorUpdatingAlert(error: error!)
                
                return
            }
            
            if popBackToDashOnFinish {
                HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
            }
            else {
                self?.vm.fetchRules { [weak self] (message, error) in
                    if let e = error {
                        self?.showInfoAlert(title: message!, message: e.errorDescription())
                        
                        return
                    }
                    
                    self?.updateUpdateIndicatorState(state: .completeWithSuccessNoPop)
                    self?.rulesTable.reloadData()
                }
            }
        }
    }
    
    private func updateApplyButtonState() {
        var changes = false
        
        for rule in vm.acceptDenyRules {
            if rule.mUpdateState == .UPDATE {
                if rule.isValid == true {
                    changes = true
                }
            }
        }
        for rule in vm.forwardRules {
            if rule.mUpdateState == .UPDATE {
                if rule.isValid == true {
                    changes = true
                }
            }
        }
        
        applyButtonIsHidden = !changes
    }
}

//====================================================
// FirewallConfigViewController Extensions
//====================================================

extension FirewallConfigViewController: NewFirewallRuleCreationProtocol {
    func checkForwardPortsValid(rule: FirewallRule) -> Bool {
        if rule.ruleActionType != .FORWARD {
            return true
        }

        return vm.areRulePortsAreAvailable(rule: rule)
    }

    func createNewFireWall(rule: FirewallRule) {
        if rule.ruleActionType == FirewallRule.FirewallRuleActionType.FORWARD {
            vm.forwardRules.insert(rule, at: 0)
            segmentedController.selectedSegmentIndex = 1
        }
        else {
            vm.acceptDenyRules.insert(rule, at: 0)
            segmentedController.selectedSegmentIndex = 0
        }
        
        rulesTable.reloadData()
        
        if !tableViewRules.isEmpty {
            rulesTable.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
        
        doBackgroundUpdate()
    }
    
    private func doBackgroundUpdate() {
        pushChanges(popBackToDashOnFinish: false)
    }
}

extension FirewallConfigViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let ruleID = tableViewRules[section].ruleID {
            if let updateState = tableViewRules[section].mUpdateState?.updateState {
                return "RULE ID: \(ruleID) (\(updateState))"
            }
            
            return "RULE ID: ".localized() + "\(ruleID)"
        }
        
        return "RULE ID: ?".localized()
    }
}

extension FirewallConfigViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewRules.isEmpty { return 0 }
        
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewRules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ruleCell", for: indexPath) as! FirewallRuleCell
        let rule = tableViewRules[indexPath.section]
        cell.configure(rule: rule, delegate: self)
        
        return cell
    }
}

extension FirewallConfigViewController: FirewallRuleCellProtocol {
    func ruleChanged(filewallRule: FirewallRule) {
        updateApplyButtonState()
    }
    
    func deleteRule(filewallRule: FirewallRule) {
        filewallRule.mUpdateState = .DELETE
        rulesTable.reloadData()
        
        deleteRuleFromHub()
    }
    
    // When the user taps delete, do the delete immediately
    private func deleteRuleFromHub() {
        guard let connection = veeaHubConnection else {
            return
        }
        
        if sendingUpdate == true { return }
        var rulesToAction = [FirewallRule]()
        
        if veeaHubConnection is MasConnection {
            rulesToAction.append(contentsOf: vm.forwardRules)
            rulesToAction.append(contentsOf: vm.acceptDenyRules)
        }
        else {
            for rule in vm.acceptDenyRules {
                if rule.mUpdateState != .CURRENT || rule.mUpdateState != .NEW_DELETED {
                    if rule.isValid == true {
                        rulesToAction.append(rule)
                    }
                }
            }
            for rule in vm.forwardRules {
                if rule.mUpdateState != .CURRENT || rule.mUpdateState != .NEW_DELETED {
                    if rule.isValid == true {
                        rulesToAction.append(rule)
                    }
                }
            }
        }
        
        sendUpdate(connection: connection, rulesToAction: rulesToAction, popBackToDashOnFinish: false)
    }
}

extension FirewallConfigViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}
