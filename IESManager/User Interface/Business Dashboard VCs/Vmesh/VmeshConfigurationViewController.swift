//
//  VmeshConfigurationViewController.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 16/03/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class VmeshConfigurationViewController: BaseConfigViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .mesh_settings_screen

    var flowController: HubInteractionFlowController?
    
    @IBOutlet weak var moreInfoBanner: InlineHelpView!
    
    private var vm = VmeshConfigViewModel()
    var isReSelected = false
    @IBOutlet weak var channelFieldTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var meshNameField: TitledTextField!
    @IBOutlet weak var ssidField: TitledTextField!
    @IBOutlet weak var passwordField: TitledPasswordField!
    
    @IBOutlet weak var vLanMeshRowView: UIView!
    @IBOutlet weak var wlanMmeshEnabledSwitch: UISwitch!
    @IBOutlet weak var wLanEnabledWiredRowView: UIView!
    @IBOutlet weak var wLanEnabledWiredRowSwitch: UISwitch!
    @IBOutlet weak var wlanOperationSelectionRow: KeyValueView!
    @IBOutlet weak var wdsNodesRow: KeyValueView!

    @IBOutlet weak var reselectButton: UIButton!
    @IBOutlet weak var channelFieldContainerView: UIView!
    @IBOutlet weak var channelField: KeyValueView!
    @IBOutlet weak var channelInUse: KeyValueView!
    @IBOutlet weak var excludeDfsSwitch: UISwitch!
    @IBOutlet weak var excludeDfsView: UIView!
    
    @IBOutlet weak var whiteList: KeyValueView!
    @IBOutlet weak var wifiNetworkScanView: KeyValueView!
    @IBOutlet weak var bandwidth: KeyValueView!
    @IBOutlet weak var bandWidthUse: KeyValueView!
    @IBOutlet weak var transmitPower: KeyValueView!
    
    @IBOutlet weak var enableBeaconSwitch: UISwitch!
    @IBOutlet weak var enableBeaconView: UIView!
    @IBOutlet weak var upperBandSwitch: UISwitch!
    @IBOutlet weak var radioView: UIView!
    
    // Pickers
    private let pickerOpenHeight: CGFloat = 162.0
    private let pickerClosedHeight: CGFloat = 0
    @IBOutlet weak var channelPicker: UIPickerView!
    @IBOutlet weak var channelPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bandwidthPicker: UIPickerView!
    @IBOutlet weak var bandwidthPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var powerPicker: UIPickerView!
    @IBOutlet weak var powerPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var wlanOperationalPicker: UIPickerView!
    @IBOutlet weak var wlanOperationalPickerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var channelFieldHeightConstraint: NSLayoutConstraint!
    // All the config views that do not turn on or off other rows
    @IBOutlet var allConfigViews: [UIView]!

    private(set) var channelPickerController: PickerController<String>!
    private(set) var bandwidthPickerController: PickerController<String>!
    private(set) var powerPickerController: PickerController<Int>!
    private(set) var wlanOperationalPickerController: PickerController<String>!
    
    let viewModel = ApScanViewModel()
    
    var selectedChannelVal = ""
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender === wlanMmeshEnabledSwitch {
            vm.locked = !wlanMmeshEnabledSwitch.isOn
            filterRowsForState()
        }
        else if sender === excludeDfsSwitch {
            vm.dfsIsOn = excludeDfsSwitch.isOn
        }
        else if sender === wLanEnabledWiredRowSwitch {
            vm.wLanEnabledWired = wLanEnabledWiredRowSwitch.isOn
            showWlanEnableChangedWarning()
        }
        else if sender === upperBandSwitch {
            vm.isUpperBand = upperBandSwitch.isOn
        }
        
        updateApplyDisplayState()
    }
    
    private func showWlanEnableChangedWarning() {
        if wLanEnabledWiredRowSwitch.isOn {
            showInfoMessage(message: vm.wlanWiredOnText) { self.pushToHelp() }
        }
        else {
            showInfoMessage(message: vm.wlanWiredOffText) { self.pushToHelp() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "vMesh"
        moreInfoBanner.setText(labelText: "vMesh enables the VeeaHubs in a network to work together. This and other mesh parameters can be configured on this screen.".localized())
        moreInfoBanner.observerTaps {
            self.pushToHelp()
        }
        
        meshNameField.text = vm.swarmName
        meshNameField.delegate = self
        ssidField.text = vm.ssid
        ssidField.delegate = self
        passwordField.text = vm.psk
        passwordField.textField.textChangeDelegate = self
        selectedChannelVal = vm.selectedAccessChannel
        channelField.isHidden = true
        self.reselectButton.isHidden = true
        self.channelFieldTrailingConstraint.constant = 5.0
        setKeyValueRows()
        setSwitchItems()
        setRadios()
        setPickers()
        filterRowsForState()
        
        openChannelPicker(open: false, animated: false)
        openBandwidthPicker(open: false, animated: false)
        openPowerPicker(open: false, animated: false)
        openWlanOperationPicker(open: false, animated: false)

        enableDisableSsidPassword()

        vm.addAsObserver { update in
            self.setKeyValueRows()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    func updateUIAfterScan() {
        //vm.currentlySelectedChannelValue = selectedChannelVal
        meshNameField.text = vm.swarmName
        meshNameField.delegate = self
        ssidField.text = vm.ssid
        ssidField.delegate = self
        passwordField.text = vm.psk
        passwordField.textField.textChangeDelegate = self
        
        setKeyValueRows()
        setSwitchItems()
        setRadios()
        setPickers()
        filterRowsForState()
        
        openChannelPicker(open: false, animated: false)
        openBandwidthPicker(open: false, animated: false)
        openPowerPicker(open: false, animated: false)
        openWlanOperationPicker(open: false, animated: false)

        enableDisableSsidPassword()

        vm.addAsObserver { update in
            self.setKeyValueRows()
        }
    }

    @IBAction func reselectButtonAction(_ sender: Any) {
        if let hasWifiRadioAcs = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioAcs {
           viewModel.hasWifiRadioAcs = hasWifiRadioAcs
        }
        viewModel.scanTypeToShow = .mesh
        isReSelected.toggle()
        self.sendRecanRequest()
    }
    
    private func sendRecanRequest() {
        guard let ies = veeaHubConnection else {
            return
        }
        
        let a = UIAlertController(title: "Requesting scan".localized(), message: "Please wait".localized(), preferredStyle: .alert)
        present(a, animated: true, completion: nil)
        
        viewModel.sendScanRequestForReselect(veeaHub: ies) { [weak self] success in
            self?.dismiss(animated: true, completion: nil)
            self?.showInfoMessage(message: "Scan started\n This may take up to 30 seconds to complete. Please wait.".localized())
            self?.callScanReport()
        }
    }
    
    func callScanReport() {
        guard let ies = veeaHubConnection else {
            return
        }
        viewModel.startCheckingForUpdate(veeaHub: ies) { [weak self] (success, message) in
            DispatchQueue.main.async {
                if success {
                    self?.showInfoMessage(message: "Updated Results".localized())
                    HubDataModel.shared.updateConfigInfoForScan(observer: self)
                }
            }
        }
    }
    
    private func enableDisableSsidPassword() {
        let alpha = vm.ssidAndPasswordFieldsReadonly ? 0.3 : 1.0
        let enabled = !vm.ssidAndPasswordFieldsReadonly

        ssidField.isUserInteractionEnabled = enabled
        ssidField.alpha = alpha
        passwordField.readOnly = !enabled
    }
    
    private func pushToHelp() {
        if HubDataModel.shared.isMN {
            displayHelpFile(file: .vmesh_help_mn, push: true)
        }
        else {
            displayHelpFile(file: .vmesh_help_men, push: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setKeyValueRows()
        updateApplyDisplayState()
        self.reselectButton.isHidden = true
        self.channelFieldTrailingConstraint.constant = 5.0
        if vm.isCurrentChannelAuto {
            if let hasWifiRadioBgndScan = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioBkgndScan {
                if hasWifiRadioBgndScan {
                    self.channelFieldTrailingConstraint.constant = 70.0
                    self.reselectButton.isHidden = false
                }
            }
        }
        HubDataModel.shared.updateConfigInfoForScan(observer: self)
    }
    
    override func done(_ sender: Any) {
        super.done(sender)
    }
    
    override func applyConfig() {
        if sendingUpdate == true {
            return
        }

        if vm.hasUpperBandChanged {
            displayRestartRequiredWarning(customMessage: "Changing the radio will require a restart".localized()) { (restart) in
                if restart {
                    self.doUpdate()
                }
            }

            return
        }

        if vm.hasUpperBandChanged {
            displayRestartRequiredWarning(customMessage: "Changing the radio will require a restart".localized()) { (restart) in
                if restart {
                    self.doUpdate()
                }
            }

            return
        }

        if vm.locked == wlanMmeshEnabledSwitch.isOn && veeaHubConnection?.connectionRoute != .MAS_API { // Then the wlan state has changed
            displayRestartRequiredWarning(customMessage: "Changing the WLAN enabled state will require a restart. It may also temporarily disrupt your connection to the hub".localized()) { (restart) in
                if restart {
                    self.doUpdate()
                }
            }
        }
        
        doUpdate()
    }
    
    @IBAction func enableBeaconToggled(_ sender: Any) {
        filterRowsForState()
        updateApplyDisplayState()
    }
    
    private func doUpdate() {
        sendingUpdate = true
        updateUpdateIndicatorState(state: .uploading)
        
        vm.ssid = ssidField.text ?? ""
        vm.updateChannelChanges(selectionText: channelField.value)
        
        vm.locked = !wlanMmeshEnabledSwitch.isOn
        //vm.selectedRadioName = nameOfSelectedRadio
        vm.swarmName = meshNameField.text ?? ""
        vm.dfsIsOn = excludeDfsSwitch.isOn
        
        vm.updateHub() { [weak self]  (result, error) in
            NSLog("got result: \(String(describing: result)), error: \(String(describing: error))") // TODO

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

// MARK: - Open close pickers
extension VmeshConfigurationViewController {
    func toggleShowChannelPicker() {
        let open = channelPickerHeightConstraint.constant == pickerOpenHeight
        openChannelPicker(open: !open, animated: true)
    }
    
    func toggleShowBandwidthPicker() {
        let open = bandwidthPickerHeightConstraint.constant == pickerOpenHeight
        openBandwidthPicker(open: !open, animated: true)
    }
    
    func toggleShowPowerPicker() {
        let open = powerPickerHeightConstraint.constant == pickerOpenHeight
        openPowerPicker(open: !open, animated: true)
    }
    
    func toggleWlanOperationPicker() {
        let open = wlanOperationalPickerHeightConstraint.constant == pickerOpenHeight
        openWlanOperationPicker(open: !open, animated: true)
    }
    
    func openChannelPicker(open: Bool, animated: Bool) {
        let height = open ? pickerOpenHeight : pickerClosedHeight
        channelPickerHeightConstraint.constant = height
        if !animated { return }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func openBandwidthPicker(open: Bool, animated: Bool) {
        let height = open ? pickerOpenHeight : pickerClosedHeight
        bandwidthPickerHeightConstraint.constant = height
        if !animated { return }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func openPowerPicker(open: Bool, animated: Bool) {
        let height = open ? pickerOpenHeight : pickerClosedHeight
        powerPickerHeightConstraint.constant = height
        if !animated { return }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func openWlanOperationPicker(open: Bool, animated: Bool) {
        let height = open ? pickerOpenHeight : pickerClosedHeight
        wlanOperationalPickerHeightConstraint.constant = height
        if !animated { return }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension VmeshConfigurationViewController: KeyValueViewDelegate {
    func viewWasTapped(sender: KeyValueView) {
        if sender === channelField {
            if !vm.channelSelectionReadOnly {
                toggleShowChannelPicker()
            }
        }
        else if sender === bandwidth {
            toggleShowBandwidthPicker()
        }
        else if sender === transmitPower {
            toggleShowPowerPicker()
        }
        else if sender === whiteList {
            performSegue(withIdentifier: "whiteList", sender: self)
        }
        else if sender === wifiNetworkScanView {
            performSegue(withIdentifier: "apScan", sender: self)
        }
        else if sender === wlanOperationSelectionRow {
            toggleWlanOperationPicker()
        }
        else if sender === wdsNodesRow {
            pushToWds()
        }
        
        updateApplyDisplayState()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MultiPickerViewController {
            if segue.identifier == vm.whiteListSegueId {
                setUpForWhiteListSelection(vc: vc)
            }
        }
        
        if let vc = segue.destination as? ApScanViewController {
            vc.viewModel.scanTypeToShow = .mesh
            if let hasWifiRadioAcs = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioAcs {
                vc.viewModel.hasWifiRadioAcs = hasWifiRadioAcs
            }
        }
    }

    private func pushToWds() {
        self.navigationController?.show(WDSLinksView.newViewController(), sender: nil)
    }
    
    private func setUpForWhiteListSelection(vc: MultiPickerViewController) {
        // Create the picker items.
        let items = vm.whiteListOptions()
        vc.createMultiplePicker(named: "Channel Whitelist".localized(),
                                withItems: items) { (pickerItems, changed) in
            var newValues = [Int]()
            for item in pickerItems {
                if item.itemIsTicked {
                    if let intVal = Int(item.itemTitle) {
                        newValues.append(intVal)
                    }
                }
            }
            
            self.vm.selectedWhiteListChannels = newValues
            self.updateApplyDisplayState()
        }
    }
}

// MARK: - Initial Setup
extension VmeshConfigurationViewController {
    private func setKeyValueRows() {
        wlanOperationSelectionRow.setUp(key: "WLAN Operation (Local Hub)".localized(),
                                        value: vm.selectedWLanOperationalOption.rawValue,
                                        showLowerSep: true,
                                        showUpperSep: true,
                                        delegate: self,
                                        questionText: nil)

        wdsNodesRow.setUp(key: "Links",
                          value: vm.wdsNodeValueText,
                          showLowerSep: true,
                          showUpperSep: false,
                          delegate: self,
                          questionText: nil)
        wdsNodesRow.showDisclosureIndicator(show: true)
        wdsNodesRow.isHidden = !vm.showWdsRow
        
        selectedChannelVal = vm.currentlySelectedChannelValue ?? ""
        channelField.setUp(key: "Channel".localized(),
                           value: vm.currentlySelectedChannelValue ?? "",
                           showLowerSep: true,
                           showUpperSep: false,
                           delegate: self,
                           questionText: nil)
        
        channelInUse.setUp(key: "Channel In Use".localized(),
                           value: "\(vm.vmeshChannelActual)",
                           showLowerSep: true,
                           showUpperSep: false,
                           delegate: nil,
                           questionText: nil)
        channelInUse.valueLabel.textColor = .lightGray
        
        whiteList.setUp(key: "Auto Channel Whitelist".localized(),
                        value: Utils.intArrayToString(arr: vm.selectedWhiteListChannels),
                        showLowerSep: true,
                        showUpperSep: false,
                        delegate: self,
                        questionText: nil)
        whiteList.showDisclosureIndicator(show: true)
        whiteList.valueLabel.textColor = .lightGray
        
        wifiNetworkScanView.setUp(key: "WiFi Network Scan".localized(),
                                  value: "",
                                  showLowerSep: true,
                                  showUpperSep: false,
                                  delegate: self,
                                  questionText: nil)
        wifiNetworkScanView.showDisclosureIndicator(show: true)
        
        bandwidth.setUp(key: "Bandwidth".localized(),
                        value: vm.bwString,
                        showLowerSep: true,
                        showUpperSep: false,
                        delegate: self,
                        questionText: nil)
        
        bandWidthUse.setUp(key: "Bandwidth in Use".localized(),
                           value: "\(vm.abw)",
                           showLowerSep: true,
                           showUpperSep: false,
                           hostViewController: nil,
                           questionText: nil)
        bandWidthUse.valueLabel.textColor = .lightGray
        
        transmitPower.setUp(key: "Transmit Power".localized(),
                            value: "\(vm.transmitPwr)",
                            showLowerSep: true,
                            showUpperSep: false,
                            delegate: self,
                            questionText: nil)
    }
    
    private func setPickers() {
        channelPickerController = PickerController(values: vm.channelOptions, picker: channelPicker, delegate: self)
        channelPickerController.setPickerToStringValue(value: vm.selectedAccessChannel)
        
        bandwidthPickerController = PickerController(values: vm.bandwidthOptions, picker: bandwidthPicker, delegate: self)
        
        var powerValues = [Int]()
        for i in 0...100 {
            powerValues.append(i)
        }
        
        powerPickerController = PickerController(values: powerValues,
                                                 picker: powerPicker,
                                                 delegate: self)
        powerPickerController.setPickerToIntValue(value: vm.transmitPwr)
        
        wlanOperationalPickerController = PickerController(values: VmeshConfig.WanOperationalOption.options(wdsSupport: vm.hasWdsSupport),
                                                           picker: wlanOperationalPicker,
                                                           delegate: self)
        wlanOperationalPickerController.setPickerToStringValue(value: vm.selectedWLanOperationalOption.rawValue)
    }
    
    private func setSwitchItems() {
        wlanMmeshEnabledSwitch.setOn(!vm.locked, animated: false)
        excludeDfsSwitch.setOn(vm.dfsIsOn, animated: false)
        wLanEnabledWiredRowSwitch.setOn(vm.wLanEnabledWired, animated: false)
    }

    private func setRadios() {
        upperBandSwitch.isOn = vm.isUpperBand
    }

    
    /// We hide an show rows based on the selection in the
    /// WLAN Operation / WLAN Enabled / Beacon Enabled switches
    private func filterRowsForState() {
        if vm.hideAllButWLanEnabled {
            hideAllConfigViews(hidden: true)
            setUpRowsForMixedWiredSupport()
            setUpRowsForWLANEnabled()
            return
        }
        
        meshNameField.isHidden = HubDataModel.shared.isMN
        enableBeaconView.isHidden = !vm.showVmeshBeacon
        channelField.isHidden = !vm.showChannelSelection
        channelInUse.isHidden = !vm.showChannelActual
        excludeDfsView.isHidden = !vm.showExcludeDfs
        whiteList.isHidden = !vm.showAcsWhitelistOption
        wifiNetworkScanView.isHidden = !vm.showChannelScanOption
        bandwidth.isHidden = !vm.showBandwidthSelection
        bandWidthUse.isHidden = !vm.showBandwidthActual
        radioView.isHidden = !vm.showRadioSelect
        transmitPower.isHidden = false
        
        if channelField.isHidden {
            self.reselectButton.isHidden = true
            self.channelFieldTrailingConstraint.constant = 5.0
            channelInUse.isHidden = true
            
            channelFieldHeightConstraint.constant = 0.0
        }
        else {
            self.reselectButton.isHidden = true
            self.channelFieldTrailingConstraint.constant = 5.0
            if vm.isCurrentChannelAuto {
                if let hasWifiRadioBgndScan = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioBkgndScan {
                    if hasWifiRadioBgndScan {
                        self.channelFieldTrailingConstraint.constant = 70.0
                        self.reselectButton.isHidden = false
                        channelFieldHeightConstraint.constant = 44.0
                    }
                }
            }
        }
        
        setUpRowsForMixedWiredSupport()
        setUpRowsForWLANEnabled()
        setKeyValueRows()
        UIView.animate(withDuration: 0.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideAllConfigViews(hidden: Bool) {
        for v in allConfigViews {
            v.isHidden = hidden
        }
    }
    
    private func setUpRowsForMixedWiredSupport() {
        if vm.supportsVeeaHubMixedWiredWirelessDeployments {
            vLanMeshRowView.isHidden = true
            //wLanEnabledWiredRowView.isHidden = false
            wlanOperationSelectionRow.isHidden = false
        }
        else {
            vLanMeshRowView.isHidden = false
            //wLanEnabledWiredRowView.isHidden = true
            wlanOperationSelectionRow.isHidden = true
        }
    }
    
    private func setUpRowsForWLANEnabled() {
        if vm.supportForHideAndShowWLANEnabled {
            wLanEnabledWiredRowView.isHidden = false
        }
        else {
            wLanEnabledWiredRowView.isHidden = true
        }
    }
}

extension VmeshConfigurationViewController: PickerControllerDelegate {
    func didSelect(value: String, picker: UIPickerView) {
        
        // AUTO SELECT / MANUAL CHANNEL SELECTION
        if picker === channelPicker {
            selectedChannelVal = value
            self.reselectButton.isHidden = true
            self.channelFieldTrailingConstraint.constant = 5.0
            if value == vm.automaticSelectionOptionString {
                if let hasWifiRadioBgndScan = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioBkgndScan {
                    if hasWifiRadioBgndScan {
                        self.channelFieldTrailingConstraint.constant = 70.0
                        self.reselectButton.isHidden = false
                    }
                }
                showAPChangedWarning()
            }
            else if Int(value) != vm.channel {
                showAPChangedWarning()
            }
            
            channelField.value = value
            vm.updateChannelChanges(selectionText: channelField.value)
            openChannelPicker(open: false, animated: true)
            
            // Reload table view if we are moving from auto to manual selection or vice versa
            if value == vm.automaticSelectionOptionString && !vm.isCurrentChannelAuto {
                vm.currentlySelectedChannelValue = value
            }
            else if vm.isCurrentChannelAuto && value != vm.automaticSelectionOptionString {
                vm.currentlySelectedChannelValue = value
            }
            else {
                vm.currentlySelectedChannelValue = value
            }
            filterRowsForState()
            
        }
        else if picker === bandwidthPicker {
            vm.bwString = value
            openBandwidthPicker(open: false, animated: true)
        }
        else if picker === powerPicker {
            transmitPower.value = value
            if let v = Int(value) { vm.transmitPwr = v }
            openPowerPicker(open: false, animated: true)
        }
        else if picker === wlanOperationalPicker {
            wlanOperationSelectionRow.value = value
            
            if let v = VmeshConfig.WanOperationalOption.init(rawValue: value) {
                vm.selectedWLanOperationalOption = v
            }
            self.reselectButton.isHidden = true
            self.channelFieldTrailingConstraint.constant = 5.0
            if value.lowercased() == "Disabled".lowercased() {
                self.reselectButton.isHidden = true
            }
            else {
                if vm.isCurrentChannelAuto {
                    if let hasWifiRadioBgndScan = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioBkgndScan {
                        if hasWifiRadioBgndScan {
                            self.channelFieldTrailingConstraint.constant = 70.0
                            self.reselectButton.isHidden = false
                        }
                    }
                }
            }
            openWlanOperationPicker(open: false, animated: true)
            filterRowsForState()
        }
        
        setKeyValueRows()
        updateApplyDisplayState()
    }
    
    private func showAPChangedWarning() {
        showInfoWarning(message: "Changing Access Channel may cause your device to disconnect from the Hub.".localized())
    }
    
    private func updateApplyDisplayState() {
        let updated = vm.hasVmeshConfigChanged()
        
        applyButtonIsHidden = !updated
    }
}

extension VmeshConfigurationViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        self.vm = VmeshConfigViewModel()
        self.updateUIAfterScan()
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}

extension VmeshConfigurationViewController: TitledTextFieldDelegate, SecureEntryTextFieldDelegate {
    // Password call back
    func valueChanged(sender: SecureEntryTextField) {
        vm.psk = passwordField.text ?? ""
        updateApplyDisplayState()
    }
    
    // Other field call backs
    func textDidChange(sender: TitledTextField) {
        vm.swarmName = meshNameField.text ?? ""
        vm.ssid = ssidField.text ?? ""
        updateApplyDisplayState()
    }
}
