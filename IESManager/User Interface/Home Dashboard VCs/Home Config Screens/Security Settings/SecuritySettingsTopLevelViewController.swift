//
//  SecuritySettingsTopLevelViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 25/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class SecuritySettingsTopLevelViewController: HomeUserBaseViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .home_security_settings_screen

    static func new() -> SecuritySettingsTopLevelViewController{
        let vc = UIStoryboard(name: StoryboardNames.SecuritySettings.rawValue, bundle: nil).instantiateViewController(withIdentifier: "SecuritySettingsTopLevelViewController") as! SecuritySettingsTopLevelViewController
        
        return vc
    }
    
    @IBOutlet weak var filterSegmentedControl: VeeaSegmentedControl!
    @IBOutlet weak var noRulesView: UIView!
    @IBOutlet weak var noRuleFoundLabel: UILabel!
    @IBOutlet weak var noRuleFoundInfoLabel: UILabel!
    @IBOutlet weak var addRuleBottomButton: CurvedButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var noRulesViewsHidden: Bool {
        get {
            return noRulesView.isHidden
        }
        set {
            noRulesView.isHidden = newValue
            addRuleBottomButton.isHidden = newValue
            tableView.isHidden = !newValue
        }
    }
    
    private let vm = SecuritySettingsTopLevelViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customiseSegmentedControl()
        
        // Do any additional setup after loading the view.
        noRulesViewsHidden = false
        vm.addAsObserver { type in
            self.update(type: type)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    private func customiseSegmentedControl() {
        let selectedFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let deselectedFont = UIFont.systemFont(ofSize: 13, weight: .medium)
        
        var labelColor = UIColor.black
        labelColor = .label
        
        filterSegmentedControl.selectedItemTintColor = cm.background1
        filterSegmentedControl.selectedConfiguration(font: selectedFont, color: labelColor)
        filterSegmentedControl.defaultConfiguration(font: deselectedFont, color: labelColor)
    }
    
    private func update(type: ViewModelUpdateType?) {
        guard let type = type else {
            updateUi()
            return
        }
        
        switch type {
        case .dataModelUpdated:
            updateUi()
        case .sendingData:
            handleSendingData()
        case .sendingDataSuccess:
            handleSendingSuccess()
        case .sendingDataFailed(let string):
            handleSendingError(error: string)
        case .noChange:
            break
        }
    }
    
    private func handleSendingData() {
        showWorkingAlert(show: true)
    }
    
    private func handleSendingSuccess() {
        showWorkingAlert(show: false)
        tableView.reloadData()
    }
    
    private func handleSendingError(error: String) {
        showWorkingAlert(show: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showAlert(with: "Error".localized(), message: error)
        }
    }
    
    override func setTheme() {
        super.setTheme()
        setTitleItemBar(color: cm.background2, transparent: true)
        
        self.view.backgroundColor = cm.background2.colorForAppearance
        noRuleFoundLabel.font = FontManager.medium(size: 20)
        noRuleFoundInfoLabel.font = FontManager.light(size: 17)
        noRulesView.backgroundColor = .clear
    }
    
    @IBAction func selectedFilterChanged(_ sender: Any) {
        vm.filterSetting = SecuritySettingsTopLevelViewModel.FilterSetting(rawValue: filterSegmentedControl.selectedSegmentIndex)!
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SecurityRuleCreateEditViewController
        vc.vm.newId = vm.newRuleId
        vc.delegate = self
    }
}

extension SecuritySettingsTopLevelViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rule = vm.rules[indexPath.row]
        
        let vc = SecurityRuleCreateEditViewController.new()
        vc.vm.rule = rule
        vc.delegate = self
        
        present(vc, animated: true)
    }
}

extension SecuritySettingsTopLevelViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.rules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SecurityRuleCell
        let rule = vm.rules[indexPath.row]
        cell.config(rule: rule)
        
        return cell
    }
}

// MARK: -
extension SecuritySettingsTopLevelViewController: SecurityRuleCreateEditCompletionDelegate {
    func completedWithChanges(rule: FirewallRule) {
        vm.updateRule(rule: rule)
    }
}

// MARK: - Updating
extension SecuritySettingsTopLevelViewController {
    private func updateUi() {
        showWorkingAlert(show: false)
        let hasRules = vm.hasRules
        noRulesViewsHidden = hasRules
        
        if !hasRules { return }
        
        tableView.reloadData()
    }
}

class SecuritySettingsTopLevelViewModel: HomeUserBaseViewModel {
    
    enum FilterSetting: Int {
        case all
        case access
        case forward
    }
    
    var filterSetting: FilterSetting = .all // Default to all
    
    // The firewall rules view model from enterprise.
    // No point in reinventing the wheel. It does lots
    private let firewallsRuleVm = FirewallViewModel()
    
    override init() {
        super.init()
        
        getRules()
    }
    
    var newRuleId: Int {
        return firewallsRuleVm.getTopId() + 1
    }
    
    var rules: [FirewallRule] {
        let acceptDeny = firewallsRuleVm.acceptDenyFiltered
        let forward = firewallsRuleVm.forwardFiltered
        
        switch filterSetting {
        case .all:
            return acceptDeny + forward
        case .access:
            return acceptDeny
        case .forward:
            return forward
        }
    }
    
    var hasRules: Bool {
        let acceptDeny = firewallsRuleVm.acceptDenyFiltered
        let forward = firewallsRuleVm.forwardFiltered
        
        let all = acceptDeny + forward
        return !all.isEmpty
    }
    
    func updateRule(rule: FirewallRule) {
        informObserversOfChange(type: .sendingData)
        sendRule(rule: rule)
    }
    
    private func sendRule(rule: FirewallRule) {
        guard let connection = connectedHub else {
            informObserversOfChange(type: .sendingDataFailed("No connection to the VeeaHub. Please try again".localized()))
            return
        }
        
        let acceptDeny = firewallsRuleVm.acceptDenyFiltered
        let forward = firewallsRuleVm.forwardFiltered
        var allRules = acceptDeny + forward
        
        switch rule.mUpdateState {
        case .NEW:
            allRules.append(rule)
            break
        case .CURRENT, .UPDATE:
            for (i, r) in allRules.enumerated() {
                if rule.ruleID == r.ruleID {
                    allRules[i] = rule
                    break
                }
            }
            break
        case .NEW_DELETED, .DELETE:
            for (i, r) in allRules.enumerated() {
                if rule.ruleID == r.ruleID {
                    allRules.remove(at: i)
                    break
                }
            }
            break
        case .none:
            self.informObserversOfChange(type: .sendingDataFailed("Could not update rules".localized()))
            return
        }
        
        ApiFactory.api.updateFirewall(connection: connection, rules: allRules) { rule, error in
            if let error = error {
                self.informObserversOfChange(type: .sendingDataFailed(error.errorDescription()))
                return
            }
            
            // Do a fetch then tell the view controller to update
            self.getRules()
        }
    }
    
    func getRules() {
        firewallsRuleVm.fetchRules { message, error in
            if let error = error {
                self.informObserversOfChange(type: .sendingDataFailed(error.localizedDescription))
                return
            }
            
            self.informObserversOfChange(type: .dataModelUpdated)
        }
    }
}

class SecurityRuleCell: UITableViewCell {
    
    private var backgroundSet = false
    
    private let acceptImageName = "SecuritySettings-Accept"
    private let denyImageName = "SecuritySettings-Deny"
    private let forwardImageName = "SecuritySettings-Forward"
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var backingView: UIView!
    
    func config(rule: FirewallRule) {
        setBackground()
        setImages(rule: rule)
        setText(rule: rule)
    }
    
    private func setImages(rule: FirewallRule) {
        // Images
        switch rule.ruleActionType {
        case .ACCEPT:
            typeImageView.image = UIImage(named: acceptImageName)
            break
        case .DROP:
            typeImageView.image = UIImage(named: denyImageName)
            break
        case .FORWARD:
            typeImageView.image = UIImage(named: forwardImageName)
            break
        case .none:
            assertionFailure("Rule has no type")
        }
    }
    
    private func setText(rule: FirewallRule) {
        switch rule.ruleActionType {
        case .ACCEPT:
            
            titleLabel.text = "Accept Port ".localized() + rule.portRangeDescription
            break
        case .DROP:
            titleLabel.text = "Deny Port ".localized() + rule.portRangeDescription
            break
        case .FORWARD:
            titleLabel.text = "Forward Port ".localized() + rule.portRangeDescription
            break
        case .none:
            assertionFailure("Rule has no type")
        }
        
        subtitle.text = "Source: ".localized() + (rule.mSource ?? "any".localized())
    }
    
    private func setBackground() {
        if backgroundSet { return }
        
        backingView.backgroundColor = InterfaceManager.shared.cm.background1.colorForAppearance
        backingView.layer.cornerRadius = 10.0
        backingView.clipsToBounds = true
        
        backgroundSet = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async {
            self.setTheme()
        }
    }
    
    func setTheme() {
        backingView.backgroundColor = InterfaceManager.shared.cm.background1.colorForAppearance
    }
}
