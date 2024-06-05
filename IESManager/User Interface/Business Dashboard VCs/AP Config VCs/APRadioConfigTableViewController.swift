//
//  APRadioConfigTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 24/06/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit


class APRadioConfigTableViewController: BaseConfigTableViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .wifi_settings_screen

    
    var vm = APRadioConfigTableViewModel()
    let viewModel = ApScanViewModel()
    
    var veeaHubConnection: HubConnectionDefinition? = {
        return HubDataModel.shared.connectedVeeaHub
    }()
    
    var isUILoaded = false
    var isOperationToBeShown = false
    var isReSelected = false
    var currentOperation:SelectedOperation =  .Start
    
    var selectedChannelVal = ""
    
    var nodeCapabilities =  HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig
    
    @IBOutlet private weak var operationChannelLabel: UILabel!

    @IBOutlet private weak var accessChannelLabel: UILabel!
    @IBOutlet weak var actualChannelLabel: UILabel!
    
    @IBOutlet private weak var accessBandwidthLabel: UILabel!
    
    @IBOutlet weak var bandwidthInUseCell: UITableViewCell!
    @IBOutlet private weak var operationChannelsCell: UITableViewCell!
    @IBOutlet private weak var accessChannelsCell: UITableViewCell!
    @IBOutlet private weak var accessBandwidthCell: UITableViewCell!
    @IBOutlet private weak var accessBandwidthSegmentedControl: UISegmentedControl!
    
    @IBOutlet private weak var operationChannelValue: UILabel!
    
    @IBOutlet private weak var accessChannelValue: UILabel!
    @IBOutlet private weak var channelWhiteListValue: UILabel!
    @IBOutlet private weak var actualBandwidthValue: UILabel!
    
    @IBOutlet private weak var accessModeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var excludeDfsSwitch: UISwitch!
    @IBOutlet weak var useLowerBandSwitch: UISwitch!
    
    @IBOutlet weak var wifi802_11axDisabledSwitch: UISwitch!
    
    @IBOutlet private weak var maxStations: TitledTextField!
    @IBOutlet private weak var maxInactivity: TitledTextField!
    
    @IBOutlet private weak var transmitPowerValue: UILabel!
    
    @IBOutlet weak var operationChannelPicker: UIPickerView!
    @IBOutlet weak var accessChannelPicker: UIPickerView!
    @IBOutlet weak var transmitPowerPicker: UIPickerView!
    
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    private var operationChannelPickerController: PickerController<String>!
    private var accessChannelPickerController: PickerController<String>!
    private var transmitPowerPickerController: PickerController<Int>!
    
    public var tabController: APConfigSelectionViewController?
    
    private let closedCellHeight: CGFloat = 47.5    
    private let disabledAlphaValue: CGFloat = 0.3
    
    var selectedRadio : SelectedAP = .AP1
    
    @IBOutlet weak var reselectButton: UIButton!
    private var accessBandWidthAsString: String {
        guard let c = vm.config else {
            return ""
        }
        
        let accessBandwidth = vm.selectedFreq == .AP1 ? c.access1_bandwidth : c.access2_bandwidth
        var bandwidthString = vm.bandwidth20
        
        if accessBandwidth == 40 {
            bandwidthString = vm.bandwidth40
        } else if accessBandwidth == 80 {
            bandwidthString = vm.bandwidth80
        }
        
        return bandwidthString
    }
    
    
    @IBAction func bandwidthSelectionChanged(_ sender: Any) {
        screenWasUpdated()
    }
    
    @IBAction func modeSelectionChanged(_ sender: Any) {
        screenWasUpdated()
    }
    
    @IBAction func excludeDfsChanged(_ sender: Any) {
        screenWasUpdated()
    }
    
    @IBAction func lowerModeChanged(_ sender: Any) {
        screenWasUpdated()
    }
    
    @IBAction func disableWifi802_11axChanged(_ sender: Any) {
        screenWasUpdated()
    }
    
    @IBAction func reselctButtonTapped(_ sender: Any) {
        if let hasWifiRadioAcs = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioAcs {
            viewModel.hasWifiRadioAcs = hasWifiRadioAcs
        }
        let is2Ghz = vm.selectedFreq == .AP1
        if is2Ghz {
            viewModel.scanTypeToShow = .ghz2
        }
        else {
            viewModel.scanTypeToShow = .ghz5
        }
        isReSelected.toggle()
        self.sendRecanRequest()
    }
    
    // MARK: - Life Cycle
    
    override func cancel(_ sender: Any) {
        tabController?.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .interactive
        isUILoaded = true
        maxStations.setKeyboardType(type: .numberPad)
        maxStations.delegate = self
        maxInactivity.setKeyboardType(type: .numberPad)
        currentOperation = vm.currentOperationSelected ?? .Start
        vm.currentOperation = currentOperation
        maxInactivity.delegate = self
        selectedRadio = vm.selectedFreq
        
        inlineHelpView.setText(labelText: "Use this tab to set radio configuration options for the APs.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .wifi_radios, push: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        operationChannelPickerController = nil
        operationChannelPickerController = nil
        populate()
        gettingUpdatedDataModels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        accessChannelPickerController = nil
        accessChannelPickerController = nil
        transmitPowerPickerController = nil
    }
    
    func gettingUpdatedDataModels() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            HubDataModel.shared.updateConfigInfoForScan(observer: self)
        }
    }

    // MARK: - Popualate
    
    private func populate() {
        guard let c = vm.config else {
            return
        }
        
        vm.selectedFreq == .AP1 ? populate2Ghz(c: c) : populate5Ghz(c: c)
        accessChannelPickerController = PickerController(values: vm.selectedApChannelOptions, picker: accessChannelPicker, delegate: self)
        accessChannelPickerController.setPickerToStringValue(value: vm.selectedAccessChannel)
        accessChannelValue.text = vm.selectedAccessChannel
        selectedChannelVal = accessChannelValue.text ?? ""
        self.reselectButton.setTitle("", for: .normal)
        self.reselectButton.isHidden = true
        if vm.selectedAccessChannel.lowercased() == "auto selection".lowercased() {
            if let hasWifiRadioBgndScan = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioBkgndScan {
                if hasWifiRadioBgndScan {
                    self.reselectButton.setTitle("Reselect", for: .normal)
                    self.reselectButton.isHidden = false
                }
            }
        }
        
        operationChannelPickerController = PickerController(values: vm.selectedApOperationOptions, picker: operationChannelPicker, delegate: self)
        operationChannelPickerController.setPickerToStringValue(value: vm.selectedOperationChannel)
        operationChannelValue.text = vm.selectedOperationChannel
        
        // For C05, E09, E10 on the 2.4GHz AP the only bandwidth supported is 20Mhz. No other option should be given
        // For the 5GHz AP, the C05, E09, E10 all support 20, 20/40, and 20/40/80
        
        let accessBandwidthOptions = vm.selectedFreq == .AP1 ? c.accessBandwidthOptionsOnly20 : c.accessBandwidthOptionsAll
        for (index, title) in accessBandwidthOptions.enumerated() {
            accessBandwidthSegmentedControl.setTitle(title, forSegmentAt: index)
        }
        
        setAccessModeSegmentedControlValues()
        
        var powerValues = [Int]()
        for i in 0...100 {
            powerValues.append(i)
        }
        
        transmitPowerPickerController = PickerController(values: powerValues, picker: transmitPowerPicker, delegate: self)
        
        actualChannelLabel.text = vm.selectedApChannelActual
        channelWhiteListValue.text = Utils.intArrayToString(arr: vm.whiteListedChannels)
        
        self.tableView.reloadData()
    }
    
    private func setAccessModeSegmentedControlValues() {
        guard let c = vm.config else { return }
        
        let options = vm.selectedFreq == .AP1 ? c.accessModeOptions2Ghz : c.accessModeOptions5Ghz
        
        for (index, title) in options.enumerated() {
            accessModeSegmentedControl.setTitle(title, forSegmentAt: index)
        }
    }
    
    func populateAfterScanReselect() {
        guard let c = vm.config else {
            return
        }
        accessChannelValue.text = selectedChannelVal
        if vm.selectedFreq == .AP1 {
            actualBandwidthValue.text = "\(c.access1_bandwidth_actual)"
            if let selectedChannel = c.access1_wifi_channels.firstIndex(of: c.access1_channel_actual) {
                accessChannelPicker.selectRow(selectedChannel, inComponent: 0, animated: false)
            }
        }
        else {
            actualBandwidthValue.text = "\(c.access2_bandwidth_actual)"
            if let selectedChannel = c.access1_wifi_channels.firstIndex(of: c.access2_channel_actual) {
                accessChannelPicker.selectRow(selectedChannel, inComponent: 0, animated: false)
            }
        }
        
    }
    
    private func populate2Ghz(c: NodeConfig) {
        accessBandwidthSegmentedControl.removeAllSegments()
        for (index, title) in c.accessBandwidthOptionsOnly20.enumerated() {
            accessBandwidthSegmentedControl.insertSegment(withTitle: title, at: index, animated: false)
            if title == accessBandWidthAsString {
                accessBandwidthSegmentedControl.selectedSegmentIndex = index
            }
        }
        actualBandwidthValue.text = "\(c.access1_bandwidth_actual)"

        let modeIndex = vm.segmentedControllerIndexFrom(accessMode: c.access1_mode)
        accessModeSegmentedControl.selectedSegmentIndex = modeIndex
        
        excludeDfsSwitch.isOn = c.access1_acs_exclude_dfs
        wifi802_11axDisabledSwitch.isOn = (c.access1_80211ax ?? false)
        maxStations.text = "\(c.access1_max_num_sta)"
        maxInactivity.text = "\(c.access1_max_inactivity)"
        transmitPowerValue.text = "\(c.access1_power_scale)"
        
        if let selectedChannel = c.access1_wifi_channels.firstIndex(of: c.access1_channel) {
            accessChannelPicker.selectRow(selectedChannel, inComponent: 0, animated: false)
        }
        
        if currentOperation == .Disabled {
            operationChannelPicker.selectRow(1, inComponent: 0, animated: false)
        }else{
            operationChannelPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    private func populate5Ghz(c: NodeConfig) {
        accessChannelValue.text = "\(c.access2_channel)"
        accessBandwidthSegmentedControl.removeAllSegments()
        for (index, title) in c.accessBandwidthOptionsAll.enumerated() {
            accessBandwidthSegmentedControl.insertSegment(withTitle: title, at: index, animated: false)
            if title == accessBandWidthAsString {
                accessBandwidthSegmentedControl.selectedSegmentIndex = index
            }
        }
        
        // Another caveat: For E09 -> 5Ghz AP -> Hide Bandwidth options ;D
        if (!HubDataModel.shared.hardwareVersion.canShowBandwidthOptions) {
            accessBandwidthCell.isHidden = true
            bandwidthInUseCell.isHidden = true
        }
        
        excludeDfsSwitch.isOn = c.access2_acs_exclude_dfs
        wifi802_11axDisabledSwitch.isOn = (c.access2_80211ax ?? false)
        actualBandwidthValue.text = "\(c.access2_bandwidth_actual)"
        maxStations.text = "\(c.access2_max_num_sta)"
        useLowerBandSwitch.isOn = c.access2_band_lower
        maxInactivity.text = "\(c.access2_max_inactivity)"
        transmitPowerValue.text = "\(c.access2_power_scale)"
        
        if let selectedChannel = c.access2_wifi_channels.firstIndex(of: c.access2_channel) {
            accessChannelPicker.selectRow(selectedChannel, inComponent: 0, animated: false)
        }
        
        if currentOperation == .Disabled {
            operationChannelPicker.selectRow(1, inComponent: 0, animated: false)
        }else{
            operationChannelPicker.selectRow(0, inComponent: 0, animated: false)
        }
        
        let modeIndex = vm.segmentedControllerIndexFrom(accessMode: c.access2_mode)
        accessModeSegmentedControl.selectedSegmentIndex = modeIndex
        
        setItemsToReadOnlyIfMeshRadio()
    }
    
    // Only called from 5Ghz
    private func setItemsToReadOnlyIfMeshRadio() {
        var enabled = true
        var alpha: CGFloat = 1.0
        
        if vm.isAp2MeshRadio {
            enabled = false
            alpha = disabledAlphaValue
            
        }
        
        accessChannelLabel.isEnabled = enabled
        accessChannelLabel.alpha = alpha
        accessChannelValue.isEnabled = enabled
        accessChannelValue.alpha = alpha
        accessChannelsCell.isUserInteractionEnabled = enabled
        accessBandwidthLabel.isEnabled = enabled
        accessBandwidthLabel.alpha = alpha
        accessBandwidthCell.isUserInteractionEnabled = enabled
    }
    
    // MARK: - Updating
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var animate = false
        var deselect = true
        if indexPath.row == APRadioConfigTableViewModel.RowID.operationChannel {
            if operationChannelPickerController.toggle() {
                deselect = false
            }
            animate = true
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.accessChannel {
            if accessChannelPickerController.toggle() {
                deselect = false
            }
            animate = true
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.actualBandwidth {
            
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.transmitPower {
            if transmitPowerPickerController.toggle() {
                deselect = false
            }
            animate = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.scrollToBottom()
            }
        }
        
        if animate {
            Utils.animatedRefresh(tableView: tableView)
        }
        
        if deselect {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 13, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
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
    
    // MARK: Update model
    
    override func applyConfig() {
        
        if hasInvalidMaxStations {
            if vm.selectedFreq == .AP1 {
                self.showInfoAlert(title: "Error", message: "[2.4GHz Wi-Fi] - Radio Settings - Max Stations : Error: \"Maximum Number of Stations\" should be between 1 and 225.".localized())
            }
            else {
                self.showInfoAlert(title: "Error", message: "[5GHz Wi-Fi] - Radio Settings - Max Stations : Error: \"Maximum Number of Stations\" should be between 1 and 225.".localized())
            }
            return
        }
        
        if hasInvalidMaxInActivity {
            if vm.selectedFreq == .AP1 {
                self.showInfoAlert(title: "Error", message: "[2.4GHz Wi-Fi] - Radio Settings - Access Maximum Inactivity : Error: \"Access Maximum Inactivity\" should be between 30 and 600".localized())
            }
            else {
                self.showInfoAlert(title: "Error", message: "[5GHz Wi-Fi] - Radio Settings - Access Maximum Inactivity : Error: \"Access Maximum Inactivity\" should be between 30 and 600".localized())
            }
            return
        }
        
        if hasChannelChanged || hasOperationChanged {
            let message = "If you are connected to your VeeaHub's Wi-Fi, you will be disconnected until the change is applied.".localized()
            let alertVc = UIAlertController(title: "This action will disrupt connectivity".localized(),
                                            message: message,
                                            preferredStyle: .alert)
            alertVc.addAction(UIAlertAction(title: "Cancel".localized(),
                                            style: .default,
                                            handler: nil))
            
            alertVc.addAction(UIAlertAction(title: "Continue".localized(),
                                            style: .destructive,
                                            handler: { (alert) in
                                                self.sendUpdate()
                                            }))
            self.present(alertVc,
                         animated: true,
                         completion: nil)
            return
        }
        
        sendUpdate()
    }
    
    private func sendUpdate() {
        sendingUpdate = true
        updateUpdateIndicatorState(state: .uploading)
        
        tabController?.vcIsDoneWithUpdates(handler: { (error) in
            if let error = error {
                self.updateUpdateIndicatorState(state: .completeWithError)
                self.showErrorUpdatingAlert(error: error)
                
                self.navigationController?.popViewController(animated: true)
                
                return
            }
            
            HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
        })
    }
    
    private var hasChannelChanged: Bool {
        guard let current = vm.currentChannel,
              let original = vm.initialAccessChannelSetting else {
            return false
        }

        return original != current
    }
    private var hasOperationChanged: Bool {
        guard let current = vm.currentOperation,
              let original = vm.currentOperationSelected else {
            return false
        }

        return original != current
    }
    
    private var hasInvalidMaxStations: Bool {
        if let c = HubDataModel.shared.baseDataModel?.nodeConfig {
            let maxStation = Int(maxStations.textField.text ?? "0")
            if maxStation == nil {
                return true
            }
            if maxStation ?? 0 < 0 || maxStation ?? 0 > 225 {
                return true
            }
            return false
        }
        return false
    }
    
    private var hasInvalidMaxInActivity: Bool {
        if let c = HubDataModel.shared.baseDataModel?.nodeConfig {
            let maxInActivity = Int(maxInactivity.textField.text ?? "0")
            if maxInActivity == nil {
                return true
            }
            if maxInActivity ?? 0 < 30 || maxInActivity ?? 0 > 600 {
                return true
            }
            return false
        }
        return false
    }
    
    /// Updates the data model if required and informs the tab bar controller, which will then make the required calls
    ///
    /// - Returns: bool
    public func isDataModelUpdated() -> Bool {
        if isUILoaded {
            // Update the data model
            if vm.selectedFreq == .AP1 { updateFor2Ghz() }
            else { updateFor5Ghz() }
            
            guard let original = HubDataModel.shared.baseDataModel?.nodeConfig else {
                return false
            }
            
            // Check the config
            if original != vm.config {
                return true
            }
            
            // Check to see if the white list channels have changed
            return vm.haveWhiteListChannelsChanged
            
        } else {
            return false
        }
    }
    
    func screenWasUpdated() {
        tabController?.childVcDataModelWasUpdated()
    }
    public func refreshScreenWhenOperationDisabled() {
        populate()
    }
    
    
    @discardableResult private func updateFor2Ghz() -> Bool {
        guard let c = vm.config else {
            return false
        }
        
        var update = false

        if let field = accessChannelValue {
            update = vm.hasAccessChannelChanged(selectionText: field.text)
        }
        else { // If the above field is nil, then the screen has not been shown, so there will be no changes
            return false
        }
        
        var bandwidth = 20
        
        let selectedIndex = accessBandwidthSegmentedControl.selectedSegmentIndex
        let selectedTitle = accessBandwidthSegmentedControl.titleForSegment(at: selectedIndex)
        if selectedTitle == vm.bandwidth40 {
            bandwidth = 40
        }
        else if selectedTitle == vm.bandwidth80 {
            bandwidth = 80
        }
        
        if bandwidth != c.access1_bandwidth {
            vm.config?.access1_bandwidth = bandwidth
            update = true
        }

        let newMode = vm.accessModeFromSegmentedControllerIndex(selectedIndex: accessModeSegmentedControl.selectedSegmentIndex)
        if newMode.lowercased() != vm.config?.access1_mode {
            vm.config?.access1_mode = newMode
            update = true
        }
        
        if c.access1_acs_exclude_dfs != excludeDfsSwitch.isOn {
            vm.config?.access1_acs_exclude_dfs = excludeDfsSwitch.isOn
            update = true
        }
        if c.access1_80211ax != wifi802_11axDisabledSwitch.isOn {
            vm.config?.access1_80211ax = wifi802_11axDisabledSwitch.isOn
            update = true
        }
        
        if let v = Int(maxStations.text!) {
            if v != c.access1_max_num_sta {
                vm.config?.access1_max_num_sta = v
                update = true
            }
        }
        
        if let v = Int(maxInactivity.text!) {
            if v != c.access1_max_inactivity {
                vm.config?.access1_max_inactivity = v
                update = true
            }
        }
        
        if let v = Int(transmitPowerValue.text!) {
            if v != c.access1_power_scale {
                vm.config?.access1_power_scale = v
                update = true
            }
        }
        
        if let updatedChannels = vm.updatedWhiteListChannels {
            vm.config?.access1_auto_select_channels = updatedChannels
            update = true
        }

        return update
    }
    
    @discardableResult private func updateFor5Ghz() -> Bool {
        guard let c = vm.config else {
            return false
        }
        
        var update = false
        
        update = vm.hasAccessChannelChanged(selectionText: accessChannelValue.text)
        
        let selectedIndex = accessBandwidthSegmentedControl.selectedSegmentIndex
        let selectedTitle = accessBandwidthSegmentedControl.titleForSegment(at: selectedIndex)
        
        var bandwidth = 20
        if selectedTitle == vm.bandwidth40 {
            bandwidth = 40
        }
        else if selectedTitle == vm.bandwidth80 {
            bandwidth = 80
        }
        
        if bandwidth != c.access2_bandwidth {
            vm.config?.access2_bandwidth = bandwidth
            update = true
        }
        
        let newMode = vm.accessModeFromSegmentedControllerIndex(selectedIndex: accessModeSegmentedControl.selectedSegmentIndex)
        if newMode.lowercased() != vm.config?.access2_mode {
            vm.config?.access2_mode = newMode
            update = true
        }
        
        if c.access2_acs_exclude_dfs != excludeDfsSwitch.isOn {
            vm.config?.access2_acs_exclude_dfs = excludeDfsSwitch.isOn
            update = true
        }
        if c.access2_80211ax != wifi802_11axDisabledSwitch.isOn {
            vm.config?.access2_80211ax = wifi802_11axDisabledSwitch.isOn
            update = true
        }
        
        if let v = Int(maxStations.text!) {
            if v != c.access2_max_num_sta {
                vm.config?.access2_max_num_sta = v
                update = true
            }
        }
        
        if let v = Int(maxInactivity.text!) {
            if v != c.access2_max_inactivity {
                vm.config?.access2_max_inactivity = v
                update = true
            }
        }
        
        if let v = Int(transmitPowerValue.text!) {
            if v != c.access2_power_scale {
                vm.config?.access2_power_scale = v
                update = true
            }
        }
        
        if let updatedChannels = vm.updatedWhiteListChannels {
            vm.config?.access2_auto_select_channels = updatedChannels
            update = true
        }
        
        if vm.config?.access2_band_lower != useLowerBandSwitch.isOn {
            vm.config?.access2_band_lower = useLowerBandSwitch.isOn
            update = true
        }
        
        return update
    }
    
    // MARK: - TableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == APRadioConfigTableViewModel.RowID.operationChannel{
            return vm.showOperation ? closedCellHeight : 0
        }
        
        if indexPath.row == APRadioConfigTableViewModel.RowID.operationChannelPicker {
            return operationChannelPickerController.isShowing ? 100 : 0
        }
        
        if currentOperation == .Disabled {
            return 0
        }
        
        
        if indexPath.row == APRadioConfigTableViewModel.RowID.accessChannel {
            return vm.showChannelConfigurationOption ? closedCellHeight : 0
        }
        if indexPath.row == APRadioConfigTableViewModel.RowID.accessChannelPicker {
            return accessChannelPickerController.isShowing ? 100 : 0
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.actualChannel {
            return vm.showActualChannel ? closedCellHeight : 0
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.excludeDfs {
            return vm.showDfsChannels ? closedCellHeight : 0
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.whiteList {
            return vm.showWhiteList ? closedCellHeight : 0
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.scan {
            return vm.showScanOption ? closedCellHeight : 0
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.accessMode{
            return 80
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.disable802_11ax {
            if vm.selectedFreq == .AP1 { return vm.access1Show802_11axOption ? closedCellHeight : 0 }
            return vm.access2Show802_11axOption ? closedCellHeight : 0
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.transmitPowerPicker {
            return transmitPowerPickerController.isShowing ? 100 : 0
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.useLowerBand {
            let hasMultiRadio = HubDataModel.shared
                .baseDataModel?
                .nodeCapabilitiesConfig?
                .ap2Charateristics?
                .multiRadio ?? false
            
            if vm.selectedFreq == .AP2 && hasMultiRadio {
                return closedCellHeight;
            }
            
            return 0
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.operationChannel {
            return showAccessChannelOption()
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.accessChannel {
            return showAccessChannelOption()
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.transmitPower {
            return showTransmitPowerOption()
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.accessBandwidth {
            return vm.showBandwidthOptions ? 80 : 0
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.maxStations {
            return 90
        }
        else if indexPath.row == APRadioConfigTableViewModel.RowID.maxInactivity {
            return 90
        }
        
        return closedCellHeight
    }
    
    private func showAccessChannelOption() -> CGFloat {
        var hasMesh = false
        
        if vm.selectedFreq == .AP1 {
            hasMesh = HubDataModel.shared
            .baseDataModel?
            .nodeCapabilitiesConfig?
            .ap1Charateristics?
            .meshRadio ?? false
        }
        else {
            hasMesh = HubDataModel.shared
            .baseDataModel?
            .nodeCapabilitiesConfig?
            .ap2Charateristics?
            .meshRadio ?? false
        }
        
        if hasMesh {
            return 0
        }
        
        return closedCellHeight
    }
    
    private func showTransmitPowerOption() -> CGFloat {
        return showAccessChannelOption()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MultiPickerViewController {
            if segue.identifier == vm.whiteListSegueId {
                setUpForWhiteListSelection(vc: vc)
            }
        }
        if let vc = segue.destination as? ApScanViewController {
            let is2Ghz = vm.selectedFreq == .AP1
            
            if is2Ghz {
                vc.viewModel.scanTypeToShow = .ghz2
            }
            else {
                vc.viewModel.scanTypeToShow = .ghz5
            }
            if let hasWifiRadioAcs = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioAcs {
                vc.viewModel.hasWifiRadioAcs = hasWifiRadioAcs
            }
            vc.viewModel.autoSelected = accessChannelValue.text == vm.automaticSelectionOptionString
        }
    }
  
    private func setUpForWhiteListSelection(vc: MultiPickerViewController) {
        // Create the picker items.
        let items = vm.whiteListOptions()
        vc.createMultiplePicker(named: "Channel Whitelist".localized(), withItems: items) { (pickerItems, changed) in
            var newValues = [Int]()
            for item in pickerItems {
                if item.itemIsTicked {
                    if let intVal = Int(item.itemTitle) {
                        newValues.append(intVal)
                    }
                }
            }
            
            self.vm.whiteListedChannels = newValues
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.screenWasUpdated()
            }
        }
    }
}

// MARK: - Picker View delegate
extension APRadioConfigTableViewController: PickerControllerDelegate {
    func didSelect(value: String, picker: UIPickerView) {
        var rowToDeselect = -1
        
        if picker == accessChannelPicker {
            selectedChannelVal = value
            if let c = vm.config {
                self.reselectButton.setTitle("", for: .normal)
                self.reselectButton.isHidden = true
                if vm.selectedFreq == .AP1 {
                    if value == vm.automaticSelectionOptionString {
                        if let hasWifiRadioBgndScan = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioBkgndScan {
                            if hasWifiRadioBgndScan {
                                self.reselectButton.setTitle("Reselect", for: .normal)
                                self.reselectButton.isHidden = false
                            }
                        }
                        showAPChangedWarning()
                    }
                    else if Int(value) != c.access1_channel {
                        showAPChangedWarning()
                    }
                }
                else {
                    if value == vm.automaticSelectionOptionString {
                        if let hasWifiRadioBgndScan = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.hasWifiRadioBkgndScan {
                            if hasWifiRadioBgndScan {
                                self.reselectButton.setTitle("Reselect", for: .normal)
                                self.reselectButton.isHidden = false
                            }
                        }
                        showAPChangedWarning()
                    }
                    else if Int(value) != c.access2_channel {
                        showAPChangedWarning()
                    }
                }
            }
            
            accessChannelValue.text = value
            rowToDeselect = APRadioConfigTableViewModel.RowID.accessChannel
            
            // Reload table view if we are moving from auto to manual selection or vice versa
            if value == vm.automaticSelectionOptionString && !vm.isCurrentChannelAuto {
                vm.currentChannel = value
                tableView.reloadData()
            }
            else if vm.isCurrentChannelAuto && value != vm.automaticSelectionOptionString {
                vm.currentChannel = value
                tableView.reloadData()
            }
            else {
                vm.currentChannel = value
            }
        }
        else if picker == operationChannelPicker {
            if value.lowercased() == "disabled" {
                currentOperation = .Disabled
                if vm.selectedFreq == .AP1{
                    vm.config?.access1_local_control = "locked"
                }else{
                    vm.config?.access2_local_control = "locked"
                }
            }else{
                currentOperation = .Start
                if vm.selectedFreq == .AP1{
                    vm.config?.access1_local_control = "start"
                }else{
                    vm.config?.access2_local_control = "start"
                }
            }
            vm.currentOperation = currentOperation
            operationChannelValue.text = value
            rowToDeselect = APRadioConfigTableViewModel.RowID.operationChannel
            tableView.reloadData()
        }
        else if picker == transmitPowerPicker {
            transmitPowerValue.text = value
            rowToDeselect = APRadioConfigTableViewModel.RowID.accessMode
        }
        
        tableView.deselectRow(at: IndexPath(row: rowToDeselect, section: 1), animated: true)
        Utils.animatedRefresh(tableView: tableView)
        
        screenWasUpdated()
    }
    
    private func showAPChangedWarning() {
        showInfoWarning(message: "Changing Access Channel may cause your device to disconnect from the Hub.".localized())
    }
}

extension APRadioConfigTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension APRadioConfigTableViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        vm = APRadioConfigTableViewModel()
        vm.selectedFreq = selectedRadio
        populate()
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        updateUpdateIndicatorState(state: .completeWithSuccess)
        tabController?.navigationController?.popViewController(animated: true)
    }
    
    
    func updateDidProgress(progress: Float, message: String?) {}
}

extension APRadioConfigTableViewController: TitledTextFieldDelegate {
    func textDidChange(sender: TitledTextField) {
        if sender == maxStations {
            let str =  maxStations.textField.text
            if str != "" {
                let maxStationsVal = Int(str ?? "0")
                if maxStationsVal ?? 0 < 1 ||  maxStationsVal ?? 0 > 225 {
                    maxStations.setErrorLabel(message: "\"Maximum Number of Stations\" should be between 1 and 225".localized())
                }
                else {
                    maxStations.setErrorLabel(message:"")
                    screenWasUpdated()
                }
            }
            else {
                maxStations.setErrorLabel(message: "\"Maximum Number of Stations\" should be between 1 and 225".localized())
            }
        }
        else if sender == maxInactivity {
            let str =  maxInactivity.textField.text
            if str != "" {
                let maxActivityVal = Int(str ?? "0")
                if maxActivityVal ?? 0 < 30 ||  maxActivityVal ?? 0 > 600 {
                    maxInactivity.setErrorLabel(message: "\"Access Maximum Inactivity\" should be between 30 and 600".localized())
                }
                else {
                    maxInactivity.setErrorLabel(message:"")
                }
            }
            else {
                maxInactivity.setErrorLabel(message: "\"Access Maximum Inactivity\" should be between 30 and 600".localized())
            }
        }
        screenWasUpdated()
    }
}
