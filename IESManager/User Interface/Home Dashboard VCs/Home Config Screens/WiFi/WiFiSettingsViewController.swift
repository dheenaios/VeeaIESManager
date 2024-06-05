//
//  WiFiSettingsViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 11/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

class WiFiSettingsViewController: HomeUserBaseViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .home_wifi_screen

    fileprivate var connectionProgressAlert: ConnectionProgressAlert?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var advanced: WifiGoToAdvancedSettingsView!
    
    fileprivate var vm: WiFiSettingsViewModel!
    
    private struct TableStructure {
        static let wifiName = IndexPath(row: 0, section: 0)
        static let pwd = IndexPath(row: 1, section: 0)

        static let enableSwitch = IndexPath(row: 0, section: 1)
        static let guestWifiName = IndexPath(row: 1, section: 1)
        static let guestPwd = IndexPath(row: 2, section: 1)
    }
    
    static func new(mesh: VHMesh,
                    meshDetailViewModel: MeshDetailViewModel) -> WiFiSettingsViewController {
        let vc = UIStoryboard(name: StoryboardNames.WiFiSettings.rawValue,
                              bundle: nil).instantiateInitialViewController() as! WiFiSettingsViewController
        
        vc.vm = WiFiSettingsViewModel(mesh: mesh,
                                      meshDetailViewModel: meshDetailViewModel)
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        advanced.delegate = self
        vm.addAsObserver { type in
            self.updateUI(type: type)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()

        // Update the details incase we have just come back from advanced
        vm.updateApModel()
    }
    
    private func updateUI(type: ViewModelUpdateType?) {
        showWorkingAlert(show: false)
        
        guard let type = type else {
            showAdvancedPlaceHolderIfNeeded()
            return
        }

        switch type {
        case .sendingData:
            break
        case .dataModelUpdated:
            showAdvancedPlaceHolderIfNeeded()
            break
        case .sendingDataSuccess:
            showAdvancedPlaceHolderIfNeeded()
            break
        case .sendingDataFailed(let message):
            showError(message: message)
            break
        case .noChange:
            break
        }
    }
    
    private func showError(message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showAlert(with: "Error".localized(), message: message)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showAdvancedPlaceHolderIfNeeded()
        setTheme()
    }
    
    private func showAdvancedPlaceHolderIfNeeded() {
        advanced.isHidden = !vm.showGoToAdvancedSettings

        if !vm.aps2GhzAnd5GhzDetailsSame {
            advanced.setForIssue(.WifiDetailsDoNotMatch)

        }
        if !vm.primaryApIsPreSharedKey {
            advanced.setForIssue(.SecurityNotSupported)
        }
    }

    override func setTheme() {
        super.setTheme()
        self.view.backgroundColor = cm.background2.colorForAppearance

        let navbarColor = cm.background2
        setTitleItemBar(color: navbarColor, transparent: true)
    }
}

// MARK: - Selection handling
extension WiFiSettingsViewController {
    private func handleSsidSelection() {
        let vc = HomeEditSsidPwdViewController.new(mode: .ssid) { result, mode in
            self.handleSsidPwdEditResult(result: result, mode: mode)
        }

        let nc = UINavigationController(rootViewController: vc)

        vc.modalPresentationStyle = .pageSheet
        present(nc, animated: true, completion: nil)
    }



    private func handlePwdSelection() {
        let vc = HomeEditSsidPwdViewController.new(mode: .pwd) { result, mode in
            self.handleSsidPwdEditResult(result: result, mode: mode)
        }

        let nc = UINavigationController(rootViewController: vc)

        vc.modalPresentationStyle = .pageSheet
        present(nc, animated: true, completion: nil)
    }

    private func handleGuestSsidSelection() {
        let vc = HomeEditSsidPwdViewController.new(mode: .guestSsid) { result, mode in
            self.handleSsidPwdEditResult(result: result, mode: mode)
        }

        let nc = UINavigationController(rootViewController: vc)

        vc.modalPresentationStyle = .pageSheet
        present(nc, animated: true, completion: nil)
    }



    private func handleGuestPwdSelection() {
        let vc = HomeEditSsidPwdViewController.new(mode: .guestPwd) { result, mode in
            self.handleSsidPwdEditResult(result: result, mode: mode)
        }

        let nc = UINavigationController(rootViewController: vc)

        vc.modalPresentationStyle = .pageSheet
        present(nc, animated: true, completion: nil)
    }

    private func handleSsidPwdEditResult(result: String,
                                         mode: HomeEditSsidPwdViewController.HomeEditSsidPwdViewControllerMode) {

        switch mode {
        case .ssid:
            vm.aps.primaryAp.ssid = result
            break
        case .pwd:
            vm.aps.primaryAp.pass = result
            break
        case .guestSsid:
            vm.aps.guestAp.ssid = result
            break
        case .guestPwd:
            vm.aps.guestAp.pass = result
            break
        }

        tableView.reloadData()
    }
}

extension WiFiSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == TableStructure.wifiName {
            handleSsidSelection()
        }
        else if indexPath == TableStructure.pwd {
            handlePwdSelection()
        }
        if indexPath == TableStructure.guestWifiName {
            handleGuestSsidSelection()
        }
        else if indexPath == TableStructure.guestPwd {
            handleGuestPwdSelection()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vm.headerForSection(section: section)
    }
}

extension WiFiSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == TableStructure.enableSwitch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GuestCell", for: indexPath) as! GuestSwitchCell
            cell.enableSwitch.isOn = vm.aps.guestAp.enabled
            cell.delegate = self

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WiFiSettingsTableViewCell

        if indexPath == TableStructure.wifiName {
            cell.isSecureField = false
            cell.titleLabel.text = "Wi-Fi Name".localized()
            cell.valueText = vm.wifiName
            cell.iconImageView.image = UIImage(named: "wifi_logo_ssid")
        }
        else if indexPath == TableStructure.pwd {
            cell.isSecureField = true
            cell.titleLabel.text = "Password".localized()
            cell.valueText = vm.pwd
            cell.iconImageView.image = UIImage(named: "wifi_logo_pwd")
        }
        else if indexPath == TableStructure.guestWifiName {
            cell.isSecureField = false
            cell.titleLabel.text = "Wi-Fi Name".localized()
            cell.valueText = vm.guestWifiName
            cell.iconImageView.image = UIImage(named: "wifi_logo_ssid")
        }
        else if indexPath == TableStructure.guestPwd {
            cell.isSecureField = true
            cell.titleLabel.text = "Password".localized()
            cell.valueText = vm.guestPwd
            cell.iconImageView.image = UIImage(named: "wifi_logo_pwd")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }

        // Guest wifi
        if vm.aps.guestAp.enabled {
            return 3
        }

        return 1 // Just show the switch
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
}

extension WiFiSettingsViewController: WifiGoToAdvancedSettingsViewActionDelegate {
    func didTapRestore() {
        let alert = UIAlertController(title: "Restore Defaults".localized(),
                                      message: "This option will restore your Wi-Fi network name and password to the factory default. After restoration, you can change your Wi-Fi network name and password again from this page."
                                      , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "Continue".localized(), style: .destructive, handler: { alert in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.resetToPassword()
            }
        }))
        
        self .present(alert, animated: true)
    }
    
    private func resetToPassword() {
        showWorkingAlert(show: true)
        vm.resetToDefaultValues()
    }
    
    func didTapGoToAdvanced() {
        guard let model = vm.men else { return }
        
        let connectionInfo = vm.getConnectionInfoForModel(model)
        makeConnection(connectionInfo: connectionInfo)
    }
}

// MARK: - Connection Advanced
extension WiFiSettingsViewController {
    private func makeConnection(connectionInfo: ConnectionInfo) {
        HubDataModel.shared.snapShotInUse = false
        let hub = connectionInfo.veeaHub
        
        if connectionProgressAlert == nil {
            connectionProgressAlert = ConnectionProgressAlert.init(frame: self.view.frame)
        }
        
        connectionProgressAlert?.connectToHub(hub: hub, completion: { (success, message) in
            if success {
                if !HubDataModel.shared.isDataSetComplete {
                    self.makeConnection(connectionInfo: connectionInfo)
                    return
                }
                
                self.pushToTheDash(connection: connectionInfo)
            }
            else {
                self.showFailDialog()
                self.removeConnectionProgressAlert()
            }
        })
        
        connectionProgressAlert!.alpha = 0.0
        UIWindow.sceneWindow?.addSubview(connectionProgressAlert!)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.connectionProgressAlert!.alpha = 1.0
        })
    }
    
    private func pushToTheDash(connection: ConnectionInfo?) {
        if let d = UIStoryboard(name: "Dash", bundle: nil)
            .instantiateViewController(withIdentifier: "DashViewController") as? DashViewController {
            d.connectionInfo = connection
            d.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(d, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    private func showFailDialog() {
        showAlert(with: "Connection Failed".localized(), message: "Please try again later".localized())
    }
    
    private func removeConnectionProgressAlert() {
        connectionProgressAlert?.tearDown()
        connectionProgressAlert = nil
    }
}

extension WiFiSettingsViewController: GuestSwichCellProtocol {
    func switchChanged(enabled: Bool, cell: GuestSwitchCell) {
        vm.aps.guestAp.enabled = enabled

        cell.showActivitySpinner(show: true)

        vm.sendGuestNetworkEnableUpdate(enabled: enabled) { success in
            cell.showActivitySpinner(show: false)
        }

        // Reload the section 2 cells
        if vm.aps.guestAp.enabled {
            self.tableView.insertRows(at: [TableStructure.guestWifiName,
                                           TableStructure.guestPwd],
                                      with: .automatic)
        }
        else {
            self.tableView.deleteRows(at: [TableStructure.guestWifiName,
                                           TableStructure.guestPwd],
                                      with: .automatic)
        }
    }
}

class WiFiSettingsTableViewCell: UITableViewCell {

    private let circles = "•••••••••••"

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!

    @IBOutlet weak var eyeButton: UIButton!

    var isSecureField: Bool = false {
        didSet {
            eyeButton.isHidden = isSecureField ? false : true
            updateValueText()
        }
    }

    var valueText: String = "" {
        didSet {
            updateValueText()
        }
    }

    // Default to hiding the text and showing circles
    private var showSecureText = false

    @IBAction func eyeButtonTapped(_ sender: Any) {
        showSecureText = !showSecureText
        updateValueText()
    }

    private func updateValueText() {
        if isSecureField && !showSecureText {
            valueLabel.text = circles
            return
        }

        valueLabel.text = valueText
    }
}

protocol GuestSwichCellProtocol: UIViewController {
    func switchChanged(enabled: Bool, cell: GuestSwitchCell)
}

class GuestSwitchCell: UITableViewCell {

    weak var delegate: GuestSwichCellProtocol?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var enableSwitch: UISwitch!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!





    @IBAction func enableSwitchChanged(_ sender: UISwitch) {
        guard let delegate = delegate else {
            return
        }

        let enable = sender.isOn
        let message = enable ? "Enable Guest Network?".localized() : "Disable Guest Network?".localized()
        let buttonText = enable ? "Enable".localized() : "Disable".localized()

        let alert = UIAlertController(title: message,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(),
                                      style: .cancel,
                                      handler: { action in
            sender.isOn = !sender.isOn
        }))
        alert.addAction(UIAlertAction(title: buttonText,
                                      style: .default,
                                      handler: { alert in
            delegate.switchChanged(enabled: enable,
                                   cell: self)
        }))

        delegate.present(alert, animated: true)
    }

    /// When sending the switch should be unusable, and an activity spinner is shown
    /// - Parameter show: show activity spinner /
    func showActivitySpinner(show: Bool) {
        if show {
            activitySpinner.startAnimating()
        }
        else {
            activitySpinner.stopAnimating()
        }

        enableSwitch.isEnabled = !show
        enableSwitch.alpha = show ? 0.3 : 1.0
    }
}
