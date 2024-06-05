//
//  DashViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 02/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking


class DashViewController: UIViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .advanced_veeahub_settings

    var flowController: HubInteractionFlowController?
    
    var colorManager = InterfaceManager.shared.cm
    private var renameDialog: UIView?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ipConnectButton: UIBarButtonItem!
    private var refreshingData = false
    
    private let vm = DashViewModel()
    private let refreshControl = UIRefreshControl()
    private var workingAlert: UIAlertController?
    
    public var connectionInfo: ConnectionInfo?
    
    private lazy var titleLabel: UILabel = {
        let titleView = UILabel()
        titleView.text = "VeeaHub settings".localized()
        //titleView.textColor = UIColor.white
        titleView.textAlignment = .center
        titleView.font = FontManager.regular(size: 15)
        titleView.numberOfLines = 2
        
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
        return titleView
    }()
    
    @objc private func titleTapped() {
        let alert = UIAlertController(title: "Connection Details".localized(),
                                      message: vm.connectionInfoDialogMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))

        present(alert, animated: true, completion: nil)
    }
    
    @objc private func refreshData(_ sender: Any) {
        setIpOverrideIfNeeded()
        refreshingData = true
        self.tableView.reloadData()
        
        titleLabel.text = "Fetching... "
        vm.refresh { (error) in
            self.refreshingData = false
            
            DispatchQueue.main.async {
                if let e = error {
                    self.titleLabel.text = "Error Hub Config".localized()
                    self.showErrorInfoMessage(message: e)
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    return
                }
                
                self.titleLabel.text = "VeeaHub settings".localized()
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        tableView.accessibility(config: AccessibilityConfigurations.veeahubSettingsTable)
        let veeaColor = UIColor(named: "Veea Background")
        refreshControl.tintColor = veeaColor
        refreshControl.attributedTitle = NSAttributedString(string: "Updating...".localized(), attributes: nil)
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        setTheme()

        titleLabel.text = "VeeaHub settings".localized()
        self.becomeFirstResponder()
        
        addMoreMenu()
        
        //observeConnectionMonitoring()
    }

    private func addMoreMenu() {
        let rename = UIAction(title: "Rename VeeaHub",
                              image: UIImage(systemName: "pencil")) {_ in
            self.tappedRename()
        }

        // TODO: The connect via IP button
        var menuItems = [rename]
        if Target.currentTarget != .RELEASE {
            let ipConnect = UIAction(title: "Connect via IP",
                                     image: UIImage(systemName: "app.connected.to.app.below.fill")) {_ in
                self.tappedConnectViaIp()
            }
            menuItems.append(ipConnect)
        }

        let menu = UIMenu(title: "",
                          options: .displayInline,
                          children: menuItems)

        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                         primaryAction: nil, menu: menu)

        self.navigationItem.rightBarButtonItem = moreButton
    }

    private func tappedRename() {

        if let name = connectionInfo?.selectedMeshNode.name {
            let message = "Names should be under 32 characters, begin with an alphabetic character. Only letters, numbers, _ and - are allowed.".localized()

            let dialogView = RenameDialogView(title: "Rename Veeahub".localized(),
                                              message: message,
                                              textFieldText: name) { okTapped, newName in
                if okTapped && name != newName {
                    self.sendNameUpdate(newName: newName)
                }

                self.renameDialog?.fadeOut {
                    self.renameDialog?.removeFromSuperview()
                }
            }

            self.renameDialog = SwiftUIUIView<RenameDialogView>(view: dialogView,
                                                                requireSelfSizing: true).make()
            renameDialog?.alpha = 0
            if let window = UIApplication.shared.windows.filter ({$0.isKeyWindow}).first {
                self.renameDialog!.frame = window.frame
                window.addSubview(renameDialog!)
                renameDialog?.fadeIn {}
            }
        }
    }

    private func sendNameUpdate(newName: String) {
        let m = HubDataModel.shared.baseDataModel
        guard let serial = m?.nodeInfoConfig?.unit_serial_number else { return }

        // Check the name validity
        if let message = NameValidation.hubNameHasErrors(name: newName) {
            showInfoWarning(message: "Could not rename: ".localized() + message)
            return
        }

        Task {
            let result = await MeshAndHubRenameManager.setHubName(newName, for: serial)
            if result.0 == false {
                DispatchQueue.main.async {
                    self.showInfoWarning(message: "Could not rename: " + (result.1 ?? "Unknown Error"))
                }

                return
            }

            self.refreshData(self)
        }

    }

    private func tappedConnectViaIp() {
        if let vc = UIStoryboard.initialViewController(storyboardName: .IPConnection) {
            present(vc, animated: true)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    func setTheme() {
        updateNavBarWithDefaultColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordScreenAppear()
        setIpOverrideIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(hubTokenChanged), name: NSNotification.Name.TokenUpdated, object: nil)
        
        if HubDataModel.shared.isDataSetComplete {
            showNeedsRestartIfNeeded {
                if HubDataModel.shared.connectedVeeaHub != nil {
                    self.vm.restart { (message) in
                        showAlert(with: "Restart".localized(), message: message)
                        self.refreshData(self)
                    }
                }
            }
        }
        else { refreshData(self) }
        
        checkWifiNetworkIsAsExpected()
        self.tableView.reloadData()

        if UpdateRequired.updateRequired {
            UpdateManager.shared.showUpdateRequiredPopUp()
        }
    }
    
    private func setIpOverrideIfNeeded() {
        self.navigationController?.navigationBar.barTintColor = vm.setIpOverrideIfNeeded() ? .red : .vPurple
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.TokenUpdated, object: nil)
    }
    
    // MARK: - IES Change detection
    @objc func hubTokenChanged() {
        let message = "This may indicate that the connected hub has changed. Please check the hub identity and ensure it is correct".localized()
        
        let actions = UIAlertController(title: "Auth Token Updated".localized(), message: message, preferredStyle: .alert)
        actions.addAction(UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil))
        
        present(actions, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if HubDataModel.shared.isDataSetComplete == false {
            if vm.gatewayAddress != "0.0.0.0" {
                refreshData(self)
            }
        }
    }
    
    // MARK: - Shake detection
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            showTestersMenu()
        }
    }
}

extension DashViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if vm.sections.count == section { // Then this is remove
            return ""
        }
        
        if section < vm.sections.count && vm.sections[section].visibleModels.count == 0 {
            return ""
        }
        
        return vm.sections[section].sectionTitle
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        
        if vm.sections.count == section { // Then this is remove
            headerView.textLabel?.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < vm.sections.count && vm.sections[section].visibleModels.count == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section < vm.sections.count && vm.sections[section].visibleModels.count == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if refreshingData { return }
        
        if vm.sections.count == indexPath.section { // Then this is remove
            removeIfPossible()
            return
        }
        
        let model = vm.sections[indexPath.section].visibleModels[indexPath.row]
        if !model.isEnabledForThisHub { return }
        
        vm.handleSelected(model: model, dashVc: self)
    }
    
    private func removeIfPossible() {
        let r = HubRemover.canHubBeRemoved(connectionInfo: connectionInfo)
        if !r.0 {
            showInfoAlert(title: "Cannot remove VeeaHub".localized(),
                          message: r.1 ?? "Please disconnect from the hub, reconnect and try to remove again".localized())

            return
        }

        let alert = UIAlertController.init(title: "Remove VeeaHub".localized(),
                                           message: "Are you sure you want to remove this VeeaHub?".localized(),
                                           preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "REMOVE".localized(), style: .destructive, handler: { [weak self] (action) in
            
            self?.displayWorkingAlert()
            self?.doRemoveHub()
        }))
        
        present(alert, animated: true, completion: nil)
    }

    private func doRemoveHub() {
        // The optionality of connection info is checked in the calling method
        HubRemover.remove(node: connectionInfo!.selectedMeshNode) { (success, errorMessage) in
            if success {
                self.hubRemovalSuccess()
                return
            }

            self.showInfoAlert(title: "Remove failed.".localized(), message: errorMessage ?? "Please try again later".localized())
        }
    }
    
    private func displayWorkingAlert() {
        workingAlert = UIAlertController(title: "Working...", message: nil, preferredStyle: .alert)
        present(workingAlert!, animated: true, completion: nil)
    }
    
    private func hubRemovalSuccess() {
        let hubName = connectionInfo?.veeaHub.hubName ?? ""
        workingAlert?.title = "Success"
        workingAlert?.message = "You have successfully removed your VeeaHub".localized() + " " + hubName
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
            self.workingAlert?.dismiss(animated: true, completion: {
                self.popToRootAnimated()
            })
        }
    }
}

extension DashViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.sections.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vm.sections.count == section { // Then this is remove
            return 1
        }
        
        return vm.sections[section].visibleRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if vm.sections.count == indexPath.section { // Then this is remove
            return tableView.dequeueReusableCell(withIdentifier: "RemoveCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DashCell
        
        let section = vm.sections[indexPath.section]
        let rowModel = section.visibleModels[indexPath.row]
        cell.populate(model: rowModel)
        
        cell.isEnabled(enabled: !refreshingData)

        return cell
    }
}

class DashCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var warningImage: UIImageView!
    
    @IBOutlet weak var textFieldsTrailingConstraint: NSLayoutConstraint!
    
    private let trailingNoError: CGFloat = 0.0
    private let trailingWithError: CGFloat = 40.0
    
    func populate(model: DashItemModel) {
        accessoryType = model.isEnabledForThisHub ? .disclosureIndicator : .none
        
        titleLabel.text = model.title
        subTitleLabel.text = model.subTitle
        cellImage.image = model.icon
        
        isEnabled(enabled: model.isEnabledForThisHub)
        
        if let warningColor = model.warningIconColor.colorForIconState() {
            warningImage.setImageColor(color: warningColor)
            warningImage.isHidden = false
            textFieldsTrailingConstraint.constant = trailingWithError
            return
        }
            
        warningImage.isHidden = true
        textFieldsTrailingConstraint.constant = trailingNoError
    }
    
    // Visually disable while reloading
    public func isEnabled(enabled: Bool) {
        titleLabel.alpha = enabled ? 1.0 : 0.3
        subTitleLabel.alpha = enabled ? 1.0 : 0.3
        cellImage.alpha = enabled ? 1.0 : 0.3
        
        if !enabled {
            cellImage.setImageColor(color: .gray)
        }
    }
    
    @IBAction func warningButtonTapped(_ sender: Any) {
        //print("To do for future jira")
    }
}
