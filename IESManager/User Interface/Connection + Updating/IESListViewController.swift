//
//  IESListViewController.swift
//  VeeaHub Manager
//
//  Created by Al on 21/02/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import UIKit


class IESListViewController: UIViewController {
    
    var newBeaconsFound = false
    var beaconInfoUpdated = false
    
    // TODO: Move these to the settings
    private let filterSubDomainKey = "FilterSubDomain"
    private let filterInstanceKey = "FilterInstanceId"
    
    @IBOutlet private weak var iesTableView: UITableView!
    @IBOutlet private weak var versionItem: UIBarButtonItem!
    @IBOutlet private weak var searchFilter: UISearchBar!
    @IBOutlet weak var devicesFoundButton: UIBarButtonItem!
    
    // Filters view
    @IBOutlet private weak var filtersView: UIView!
    @IBOutlet private weak var filtersViewBottomConstraint: NSLayoutConstraint!
    private let filtersViewBottomConstraintShowingValue: CGFloat = 35.0 // So the view underlaps the keyboard
    private let filtersViewBottomConstraintHiddenValue: CGFloat = 330
    
    @IBOutlet private weak var beaconKeyField: UITextField!
    @IBOutlet private weak var namespaceField: UITextField!
    @IBOutlet private weak var instanceField: UITextField!
    @IBOutlet private weak var hideWeakSignalsSwitch: UISwitch!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    var connectivityInfo: ConnectivityInfo?
    
    var listUpdateTimer: Timer?
    
    
    //   From apples documentation:RSSI The current RSSI of peripheral, in dBm. A value of 127 is reserved and indicates the RSSI was not available.
    private let notAvailable = -127
    
    lazy var progressViewController: IESConnectionProgressViewController = {
        let storyBoard: UIStoryboard = UIStoryboard(name: "ConnectionJourney", bundle: nil)
        return (storyBoard.instantiateViewController(withIdentifier: "IESConnectionProgressViewController") as? IESConnectionProgressViewController)!
    }()
    
    fileprivate let iesManager = VeeaHubDiscoveryManager.instance
    fileprivate var iesList = [VeeaHubConnection]()
    
    
    /// All the IES's sorted as per the users specifications
    fileprivate var sortedIesList: [VeeaHubConnection] {
        return applySortRules(list: self.iesList)
    }

    
    fileprivate var filteredIesList: [VeeaHubConnection] {
        get {
            guard let text = searchFilter.text else {
                return sortedIesList
            }
            
            if text.count == 0 {
                devicesFoundButton.title = "\(iesList.count) \("Hubs found".localized())"
                
                return sortedIesList
            }
            else {
                var filteredIesList = [VeeaHubConnection]()
                let sortedList = sortedIesList
                
                for ies in sortedList {
                    if ies.ssid.lowercased().contains(text.lowercased()) {
                        filteredIesList.append(ies)
                    }
                }
                
                devicesFoundButton.title = "\(filteredIesList.count) \("matched".localized())"
                
                return filteredIesList
            }
        }
    }
    
    private func applySortRules(list: [VeeaHubConnection]) -> [VeeaHubConnection] {
        if hideWeakSignalsSwitch.isOn == false {
            if sortSegmentedControl.selectedSegmentIndex == 1 {
                return list.sorted(by: {$0.ssid < $1.ssid})
            }
            
            return list.sorted(by: {$0.signalStrength.rawValue > $1.signalStrength.rawValue})
        }
        
        var filtered = [VeeaHubConnection]()
        
        for ies in list {
            if ies.signalStrength == .POOR {
                continue
            }
            
            filtered.append(ies)
        }
        
        // Sort by SSID
        if sortSegmentedControl.selectedSegmentIndex == 1 {
            return filtered.sorted(by: {$0.ssid < $1.ssid})
        }
        
        // Sort by signal strenght
        return filtered.sorted(by: {$0.rssi > $1.rssi})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeypad()

        iesManager.setDelegate(delegate: self)
        
        iesTableView.keyboardDismissMode = .interactive
        
        namespaceField.text = UserDefaults.standard.string(forKey: filterSubDomainKey) ?? ""
        instanceField.text = UserDefaults.standard.string(forKey: filterInstanceKey) ?? ""
        beaconKeyField.text = UserSettings.beaconEncryptionKey
        hideWeakSignalsSwitch.isOn = UserSettings.hideWeakSignals
        sortSegmentedControl.selectedSegmentIndex = UserSettings.sortHubsByName ? 1 : 0
        
        updateScanFilters()
        
        let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let bundleString = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        
        versionItem.title = "v\(versionString)-\(bundleString)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        connectivityInfo = ConnectivityInfo(withDelegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listUpdateTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        listUpdateTimer?.invalidate()
    }
    
    @objc func fireTimer() {
        if newBeaconsFound == true || beaconInfoUpdated == true {
            print("Updating hub list")
            
            iesTableView.reloadData()
            newBeaconsFound = false
            beaconInfoUpdated = false
        }
    }
    
    @IBAction func hideWeakSignalsSwitchChanged(_ sender: Any) {
        UserSettings.hideWeakSignals = hideWeakSignalsSwitch.isOn
    }
    
    @IBAction func sortByControllerChanged(_ sender: UISegmentedControl) {
        let selectedSegment = sender.selectedSegmentIndex
        
        UserSettings.sortHubsByName = selectedSegment == 0 ? false : true
        iesTableView.reloadData()
    }
    
    @IBAction func done(_ sender: Any) {
        saveSettings()
        iesManager.scan(enable: false)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func keypadDone() {
        instanceField.resignFirstResponder()
        
        UserDefaults.standard.set(instanceField.text, forKey: "FilterInstanceId")
        
        updateScanFilters()
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        filtersViewShowing = true
    }
    
    @IBAction func filterViewDoneTapped(_ sender: Any) {
        filtersViewShowing = false
        searchFilter.resignFirstResponder()
        instanceField.resignFirstResponder()
        namespaceField.resignFirstResponder()
        beaconKeyField.resignFirstResponder()
        
        saveSettings()
        updateScanFilters()
    }
    
    private func setupKeypad() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50)) // TODO: width
        toolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(keypadDone))
        
        toolbar.items = [flexSpace, done]
        toolbar.sizeToFit()
        
        instanceField.inputAccessoryView = toolbar
    }
    
    fileprivate func updateScanFilters() {
        iesManager.scan(enable: false)
        iesList = [VeeaHubConnection]()
        iesTableView.reloadData()
        
        let namespace = UserDefaults.standard.string(forKey: filterSubDomainKey) ?? ""
        let instanceId = UserDefaults.standard.string(forKey: filterInstanceKey) ?? ""
        
        
        
        if UserSettings.beaconEncryptionKey.count > 0 {
            iesManager.setBeaconEncryptKey(key:  UserSettings.beaconEncryptionKey)
        }
        else {
            iesManager.resetBeaconEncryptKeyToDefault()
        }
        
        iesManager.setFilters(namespace: namespace, instanceId: instanceId)
        
        iesManager.scan(enable: true)
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        iesManager.scan(enable: false)
        iesList = [VeeaHubConnection]()
        iesTableView.reloadData()
        iesManager.scan(enable: true)
    }
    
    
    fileprivate func attemptToDisconnect() {
        HubApWifiConnectionManager.shared.currentlyConnectedHub = nil
        WiFi.disconnectFromAllNetworks()
        
        let alert = UIAlertController(title: "Attempting to disconnect".localized(),
                                      message: "VeeaHub Manager is unable to disconnect if the connection was made via the settings app.\n\nIf you connected using the settings app, please disconnect using the settings app".localized(),
                                      preferredStyle: .alert)
        
        self.present(alert, animated: true) {
            let delay = DispatchTime.now() + .seconds(5)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                alert.dismiss(animated: true, completion: {
                    self.iesTableView.reloadData()
                })
            }
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(namespaceField.text, forKey: filterSubDomainKey)
        UserDefaults.standard.set(instanceField.text, forKey: filterInstanceKey)
        UserSettings.beaconEncryptionKey = beaconKeyField.text ?? ""
        UserSettings.hideWeakSignals = hideWeakSignalsSwitch.isOn
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if searchFilter.isFirstResponder {
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {            print(keyboardSize)
            let constraintValue = filtersViewBottomConstraintShowingValue - keyboardSize
            
            UIView.animate(withDuration: 0.3) {
                self.filtersViewBottomConstraint.constant = constraintValue
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.filtersViewBottomConstraint.constant = self.filtersViewBottomConstraintHiddenValue
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//
// MARK: - IesManager.Delegate
//
extension IESListViewController : VeeaHubDiscoveryManager.Delegate {
    func iesListUpdated(iesList: [VeeaHubConnection]) {
        var prefilteredList = [VeeaHubConnection]()
        
        // Have new beacons been found?
        if iesList.count != self.iesList.count {
            newBeaconsFound = true
        }
        else { // If the number of beacons have not changed, has the info changed
            for (index, ies) in iesList.enumerated() {
                let oldIes = self.iesList[index]
                
                // Checks SSID and Power catagory
                if ies != oldIes {
                    beaconInfoUpdated = true
                    break
                }
            }
        }
        
        // If the SSID name is empty, then the beacon password might be incorrect
        for ies in iesList {
            if !ies.ssid.isEmpty {
                prefilteredList.append(ies)
            }
        }
        
        self.iesList = prefilteredList
    }
}

//
// MARK: - UITableViewDataSource
//
extension IESListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredIesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IESCell", for: indexPath)
        let ies = filteredIesList[indexPath.row]
        
        // This should never happen now as the list is filtered when returned from the delegate.
        let ssid = ies.ssid.isEmpty ? "SSID name error".localized() : ies.ssid
        
        cell.textLabel?.text = ssid
        if ies.rssi == notAvailable {
            cell.detailTextLabel?.text = String("? dBm")
        }
        else {
            cell.detailTextLabel?.text = String("\(ies.rssi)dBm")
        }
        
        if let ssid = HubApWifiConnectionManager.currentSSID {
            cell.imageView?.image = (ssid == ies.ssid) ? #imageLiteral(resourceName: "IES_connected") : #imageLiteral(resourceName: "IES")
        }
        else {
            cell.imageView?.image = #imageLiteral(resourceName: "IES")
        }
        
        cell.detailTextLabel?.textColor = ies.signalStrength.getColorForStrength()
        
        return cell
    }
}

//
// MARK: - UITableViewDelegate
//
extension IESListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HubDataModel.shared.nilAllDataMembers()
        
        let ies = filteredIesList[indexPath.row]
        
        if ies.ssid.isEmpty {
            return
        }
        
        iesManager.scan(enable: false)
        
        if let ssid = HubApWifiConnectionManager.currentSSID {
            if ssid == ies.ssid {
                let alert = UIAlertController(title: "Already connected".localized(),
                                              message: "\("You are already connected to".localized()) \(ssid)",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue".localized(), style: .cancel) { _ in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(UIAlertAction(title: "Disconnect".localized(), style: .destructive) { _ in
                    self.attemptToDisconnect()
                })
                
                self.present(alert, animated: true)
                
                return
            }
        }
        
        connectToHotSpot(ies: ies)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        iesManager.scan(enable: false)
        let ies = filteredIesList[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "ConnectionJourney", bundle: nil)
        if let beaconVc = storyBoard.instantiateViewController(withIdentifier: "BeaconInfoTableViewController") as? BeaconInfoTableViewController {
            beaconVc.ies = ies
            beaconVc.delegate = self
            navigationController?.pushViewController(beaconVc, animated: true)
        }
    }
}

// MARK: - Hotspot connection
extension IESListViewController {
    private func connectToHotSpot(ies: VeeaHubConnection) {
        if ies.signalStrength == .POOR {
            let alert = UIAlertController(title: "Signal Strength is POOR".localized(),
                                          message: "\("The connection request to".localized()) \(ies.ssid) \("may fail. Move closer to the Veea Hub for better results".localized())",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel Connection Request".localized(), style: .cancel) { _ in
                //
            })
            alert.addAction(UIAlertAction(title: "Connect to Hub".localized(), style: .default) { _ in
                self.showConnectionJourneyScreen(ies: ies)
            })
            
            present(alert, animated: true)
            
            return;
        }
        
        showConnectionJourneyScreen(ies: ies)
    }
    
    private func showConnectionJourneyScreen(ies: VeeaHubConnection) {
        searchFilter.resignFirstResponder()
        progressViewController.hostingViewController = self
        progressViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(progressViewController, animated: true) {
            self.progressViewController.beginConnection(for: ies)
        }
    }
}

//
// MARK: - UITextViewDelegate
//
extension IESListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveSettings()
        updateScanFilters()

        return true
    }
}

// MARK: - UISearchBarDelegate

extension IESListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        iesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - BeaconInfoTableViewControllerProtocol

extension IESListViewController: BeaconInfoTableViewControllerProtocol {
    func autoconnectToIES(ies: VeeaHubConnection) {
        connectToHotSpot(ies: ies)
    }
}

// MARK: - Filters
extension IESListViewController {
    fileprivate var filtersViewShowing: Bool {
        get {
            return filtersViewBottomConstraint.constant == filtersViewBottomConstraintShowingValue ? true : false
        }
        set {
            let constraintValue = newValue == true ? filtersViewBottomConstraintShowingValue : filtersViewBottomConstraintHiddenValue
            
            UIView.animate(withDuration: 0.3) {
                self.filtersViewBottomConstraint.constant = constraintValue
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension IESListViewController: ConnectivityInfoDidChangeProtocol {
    func connectivityStateDidChange() {
        if connectivityInfo?.isBluetoothOn == false {
            showInfoAlert(title: "Bluetooth is Off".localized(), message: "Bluetooth is required to scan for Hubs".localized())
        }
    }
}
