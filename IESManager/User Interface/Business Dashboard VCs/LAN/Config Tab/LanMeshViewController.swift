//
//  LanMeshViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 18/07/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit

/// TAB 1: Config Tab
class LanMeshViewController: BaseConfigViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .lan_settings_screen
    
    private var vm: LanMeshViewModel!
    private var updated = false
    
    @IBOutlet weak var contentStackView: UIStackView!


    // TODO: Can this be moved to the VM
    var wanMode: WanMode = .ROUTED

    private var delegate: LanConfigurationParentDelegate!

    private var isolationStateBeforeHubModeToggle = false
    
    @IBOutlet weak public private(set) var scrollView: UIScrollView!
    
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak var lanSelector: LanPickerView!
    
    @IBOutlet weak private var enabledLabel: UILabel!
    @IBOutlet weak private var reasonLabel: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    
    @IBOutlet weak var lanNameTextField: TitledTextField!
    @IBOutlet weak var subnetTextField: TitledTextField!
    
    // Access Points
    @IBOutlet public private(set) var ap1Labels: [UILabel]!
    @IBOutlet public private(set) var ap2Labels: [UILabel]!
    @IBOutlet public private(set) var ap1Switches: [UISwitch]!
    @IBOutlet public private(set) var ap2Switches: [UISwitch]!
    
    @IBOutlet weak private var ap1View: UIView!
    @IBOutlet weak var ap1ViewHeader: UIStackView!
    @IBOutlet weak private var ap2View: UIView!
    @IBOutlet weak var ap2ViewHeader: UIStackView!
    
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    
    // LAN Overlays
    @IBOutlet public private(set) var lanOverlayLabels: [UILabel]!
    @IBOutlet public private(set) var lanOverlaySwitches: [UISwitch]!
    
    // Client Isolation
    
    @IBOutlet weak var clientIsolationView: UIView!
    @IBOutlet weak var clientIsolationSwitch: UISwitch!

    static func new(delegate: LanConfigurationParentDelegate,
                    parentVm: LanConfigurationViewModel) -> LanMeshViewController {
        let sb = UIStoryboard(name: "LanConfiguration", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LanMeshViewController") as! LanMeshViewController
        vc.delegate = delegate
        vc.vm = LanMeshViewModel(parentViewModel: parentVm)
        vc.vm.delegate = vc

        return vc
    }
    
    // Other controls
    @IBAction func activeStateChanged(_ sender: UISwitch) {
        controlsEnabled(enabled: sender.isOn)
        enabledLabel.text = sender.isOn == true ? "Active".localized() : "Inactive".localized()
        vm.updateConfigUponChange()
    }
    
    @IBAction func clientIsolationChanged(_ sender: Any) {
        vm.updateConfigUponChange()
    }
    
    @IBOutlet weak var wanInterface: TitledTextField!
    @IBOutlet weak var wanInterfaceButton: UIButton!

    @IBOutlet weak var wanAndIpModeView: UIView!
    private var wanIpModeSelectorViewContainter: UIView?

    private var lanSelection: Int {
        return delegate.selectedLan
    }
    
    func showApply(show: Bool) {
        updated = show
        delegate.childUpdateStateChanged(updated: show)
    }
    
    private func controlsEnabled(enabled: Bool) {
        let views: [UIView] = [subnetTextField,
                               lanNameTextField]
        
        // Set interaction state
        for view in views { view.isUserInteractionEnabled = enabled }
        for apSwitch in ap1Switches { apSwitch.isEnabled = enabled }
        for apSwitch in ap2Switches { apSwitch.isEnabled = enabled }
        enableLanOverlaySwitches(enabled: enabled)
        
        // Set Alpha
        let alpha: CGFloat = enabled == true ? 1.0 : 0.3
        for view in views { view.alpha = alpha }
    }

    // MARK: - Setup and config
    override func viewDidLoad() {
        super.viewDidLoad()
        populate()
        lanSelector.hostVc = self
        
        inlineHelpView.setText(labelText: "Use this tab to configure your LANs and the ports and Access Points they are associated with.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }

        self.updateWanIpModeView()
        
        if HubDataModel.shared.isMN {
            contentStackView.isUserInteractionEnabled = false
            contentStackView.alpha = 0.3
        }
        
        scrollView.keyboardDismissMode = .onDrag
        wanInterface.setKeyboardType(type: .numberPad)
        subnetTextField.setKeyboardType(type: .decimalPad)
        subnetTextField.addSubnetEntryAccessory()
        clientIsolationAvailable()
        lanNameTextField.delegate = self
        subnetTextField.delegate = self
        wanInterface.delegate = self

        enableDisableIsolationViewForWanMode()
        enableSubnetFieldForWanMode()
    }

    private func updateWanInterfaceUi() {
        wanInterfaceButton.isHidden = vm.wanShouldBeHidden
        wanInterface.isHidden = vm.wanShouldBeHidden
        wanInterface.setErrorLabel(message: vm.wanEntryErrors)
    }

    private func pushToHelp() {
        displayHelpFile(file: .lan_configuration, push: true)
    }

    private func clientIsolationAvailable() {
        // If ClientIsolation is not avilable(false) then hide the view.
        clientIsolationView.isHidden = !vm.clientIsolationAvailable
    }
    
    private func populate() {
        setAndPopulateLanNumber(lanNumber: 0)
    }
    
    private func setOperationalWarnings(index: Int) {
        reasonLabel.text = ""
        
        let state = vm.getOperationalStateFor(lanNumber: index)
        
        switch state {
        case .CLEAR:
            reasonLabel.text = ""
        case .ORANGE(let comment):
            reasonLabel.text = comment
            reasonLabel.textColor = .orange
        case .RED(let comment):
            reasonLabel.text = comment
            reasonLabel.textColor = .red
        }
    }
    
    private func setAndPopulateLanNumber(lanNumber: Int) {
        enableLanPortsForHubConfig()
        populateView(lanNumber: lanNumber)
    }
    
    private func populateView(lanNumber: Int) {
        //guard let config = vm.lans[lanNumber] else { return }
        let config = vm.parentVm.meshLanConfig.lans[lanNumber]

        controlsEnabled(enabled: config.use && config.modify)
        setOperationalWarnings(index: lanNumber)
        
        enabledLabel.text = config.use == true ? "Active".localized() : "Inactive".localized()
        enabledSwitch.isOn = config.use
        lanNameTextField.text = config.name
        subnetTextField.text = vm.ipv4AddressFor(lanNumber: lanNumber)
        subnetTextField.readOnly = !vm.ipv4TextFieldUserEditableFor(lanNumber: lanNumber)
        
        wanMode = config.wanMode
        vm.setInitialIpManagmentMode(for: lanNumber)

        wanInterface.text = String(config.wan_id)
        
        setAPSwitches(config: config)
        setLanPortSwitchesForLan(config: config)
        
        if !config.modify {
            enabledSwitch.isEnabled = false
            controlsEnabled(enabled: false)
        }else{
            enabledSwitch.isEnabled = true
        }
        
        //print("\("Client isolation:".localized()) \(config.clientIsolationOn)")
        clientIsolationSwitch.isOn = config.clientIsolationOn

        updateWanInterfaceUi()
    }

    @IBAction func wanInterfaceTapped(_ sender: Any) {
        
        var options = [MenuViewController.MenuItemOption]()
        for wan in vm.wans {
            options.append(MenuViewController.MenuItemOption(title: wan))
        }
        
        
        let vc = MenuViewController.createMenuViewController(title: "WAN Interface".localized(),
                                                             subTitle: "Choose a WAN Interface\nfrom the list".localized(),
                                                             options: options,
                                                             originView: wanInterfaceButton) { index, str in
            self.wanInterface.text = "\(index)"
            self.vm.updateConfigUponChange()
            self.updateWanInterfaceUi()
        }
        self.present(vc, animated: true)
    }
    
    @IBAction func ethernetPortSelectionChanged(_ sender: UISwitch) {
        vm.updatePortSettings()
        vm.updateConfigUponChange()
    }
    
    @IBAction func ethernetVLanSelectionChanged(_ sender: UISwitch) {
        vm.updateVLanSettings()
        vm.updateConfigUponChange()
    }
    
    @IBAction func apSelectionChanged(_ sender: UISwitch) {
        vm.updateApSettings(sw: sender)
        vm.updateConfigUponChange()
    }

    // VHM 1458
    private func enableDisableIsolationViewForWanMode() {
        if wanMode == .BRIDGED {
            isolationStateBeforeHubModeToggle = clientIsolationSwitch.isOn
            clientIsolationView.isUserInteractionEnabled = false
            clientIsolationSwitch.alpha = 0.3
            clientIsolationSwitch.isOn = false
        }
        else {
            clientIsolationView.isUserInteractionEnabled = true
            clientIsolationSwitch.alpha = 1.0
            clientIsolationSwitch.isOn = isolationStateBeforeHubModeToggle
        }
    }

    // MAS-1534: The IP Subnet on the lan page should be greyed out for bridge mode
    private func enableSubnetFieldForWanMode() {
        subnetTextField.disableView(disabled: !vm.subnetAddressEnabled)
    }
}

// MARK: - AP selection management
extension LanMeshViewController {
    /// Takes the indexes of active ports or aps, compares them against the records on other lans and deduplicates entries
    /// - Parameters:
    ///   - portOrApSet: The Port or AP settings
    ///   - changedSelection: the selection that has been changed.
    func deDuplicateLanSets(portOrApSet: [Int], changedSelection: [Int]) -> [Int] {
        var filtered = [Int]()
        for  val in portOrApSet {
            if !changedSelection.contains(val) {
                filtered.append(val)
            }
        }
        
        return filtered
    }
}

// MARK: - Lan Overlays Set up
extension LanMeshViewController {
    
    private func setLanPortSwitchesForLan(config: MeshLan?) {
        turnOffAllLanOverlaySwitches()
        guard let portSet = config?.port_set else {
            return
        }
        
        for port in portSet {
            lanOverlaySwitches[port - 1].isOn = true
        }
    }
    
    private func enableLanPortsForHubConfig() {
        turnOffAllLanOverlaySwitches()
        enableLanOverlaySwitches(enabled: false)
        
        guard let allRoles = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.ethernetPortRoles else {
            return
        }
        
        let numberOfPorts = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.numberOfEthernetPortsAvailable ?? 0
        
        for (index, role) in allRoles.enumerated() {
            
            if index < numberOfPorts {
                // Enable only Lan ports
                if role.roles.contains(.LAN) {
                    lanOverlaySwitches[index].isEnabled = true
                }
            }
        }
    }
    
    private func enableLanOverlaySwitches(enabled: Bool) {
        for lanSwitch in lanOverlaySwitches {
            lanSwitch.isEnabled = enabled
        }
    }
    
    private func turnOffAllLanOverlaySwitches() {
        for lanSwitch in lanOverlaySwitches {
            lanSwitch.isOn = false
        }
    }
}

// MARK: - AP Set up
extension LanMeshViewController {
    private func setAPSwitches(config: MeshLan) {
        
        turnOffAllApSwitches()
        
        // Check the availability of the aps and hide accordingly
        if !(HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig!.isAP1Available)! {
            ap1View.isHidden = true
            ap1ViewHeader.isHidden = true
        }
        
        if !(HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig!.isAP2Available)! {
            ap2View.isHidden = true
            ap2ViewHeader.isHidden = true
        }
        
        let meshApConfig = HubDataModel.shared.baseDataModel?.meshAPConfig
        setPhysicalApSwitches(apConfig: meshApConfig?.aps2ghz, activeAps: config.ap_set_1, switches: ap1Switches)
        setPhysicalApSwitches(apConfig: meshApConfig?.aps5ghz, activeAps: config.ap_set_2, switches: ap2Switches)
        
        enusureOnlyCorrectNumberOfAPsAreShowing()
    }
    
    private func turnOffAllApSwitches() {
        for apSwitch in ap1Switches {
            apSwitch.isOn = false
        }
        
        for apSwitch in ap2Switches {
            apSwitch.isOn = false
        }
    }
    
    private func setPhysicalApSwitches(apConfig: [AccessPointConfig]?, activeAps: [Int], switches: [UISwitch]) {
        guard apConfig?.count == 6 && switches.count == 6 else {
            ap1View.isHidden = true
            ap2View.isHidden = true
            
            Logger.log(tag: "LanMeshViewController", message: "The number of access points was unexpected \(apConfig?.count ?? 0)")
            
            return
        }
        
        guard let apConfig = apConfig else {
            ap1View.isHidden = true
            ap2View.isHidden = true
            return
        }
        
        for (index, accessPoint) in apConfig.enumerated() {
            
            switches[index].isHidden = accessPoint.system_only
            
            if activeAps.contains(index + 1) { // + 1 as the active ap numbers 1 based, the array is 0 based
                switches[index].isOn = true
            }
        }
    }
    
    private func enusureOnlyCorrectNumberOfAPsAreShowing() {
        let meshApConfig = HubDataModel.shared.baseDataModel?.meshAPConfig
        let nodeApConfig = HubDataModel.shared.baseDataModel?.nodeAPConfig
        
        guard let meshAp1 = meshApConfig?.allAP1s,
              let nodeAp1 = nodeApConfig?.allAP1s,
              let meshAp2 = meshApConfig?.allAP2s,
              let nodeAp2 = nodeApConfig?.allAP2s else {
            return
        }

        enusureOnly4APsAreShowing(meshAps: meshAp1, nodeAps: nodeAp1, switches: ap1Switches)
        enusureOnly4APsAreShowing(meshAps: meshAp2, nodeAps: nodeAp2, switches: ap2Switches)
        
        setNumberOfApsAP1()
        setNumberOfApsAP2()
        setNumberOfLanOverlays()
    }
    
    private func setNumberOfApsAP1() {
        let numberOfAps = vm.numberOfAps
        var visibleAps = 0
        for sw in ap1Switches {
            if (!sw.isHidden) {
                if visibleAps < numberOfAps {
                    sw.isHidden = false
                    if visibleAps < ap1Labels.count {
                        ap1Labels[visibleAps].isHidden = false
                    }
                }
                else {
                    sw.isHidden = true
                    if visibleAps < ap1Labels.count {
                        ap1Labels[visibleAps].isHidden = true
                    }
                }
                visibleAps = visibleAps + 1
            }
        }
    }
    
    private func setNumberOfApsAP2() {
        let numberOfAps = vm.numberOfAps
        var visibleAps = 0
        for sw in ap2Switches {
            if (!sw.isHidden) {
                if visibleAps < numberOfAps {
                    sw.isHidden = false
                    if visibleAps < ap2Labels.count {
                        ap2Labels[visibleAps].isHidden = false
                    }
                }
                else {
                    sw.isHidden = true
                    if visibleAps < ap2Labels.count {
                        ap2Labels[visibleAps].isHidden = true
                    }
                }
                visibleAps = visibleAps + 1
            }
        }
    }
    
    private func setNumberOfLanOverlays() {
        let lanOverlays = vm.physicalPortsAvailable
        
        for (index, sw) in lanOverlaySwitches.enumerated() {
            let lb = lanOverlayLabels[index]
            
            sw.isHidden = index < lanOverlays ? false : true
            lb.isHidden = index < lanOverlays ? false : true
        }
    }
    
    private func enusureOnly4APsAreShowing(meshAps: [AccessPointConfig],
                                           nodeAps: [AccessPointConfig],
                                           switches: [UISwitch]) {
        var hidden = 0
        
        for (index, meshModel) in meshAps.enumerated() {
            let sw = switches[index]
            let nodeModel = nodeAps[index]
            
            var isHidden = false
            if (meshModel.system_only && meshModel.use) || (nodeModel.system_only && nodeModel.use) {
                isHidden = true
                hidden += 1
            }
            
            sw.isHidden = isHidden
        }
        
        // We only have 4 APs visible
        if hidden < 2 {
            // From Nick J
            // If you have 1 system AP, then you would show ap_1_2, 1_3, 1_4, 1_5 (but not 1_6).
            // But if AP1-1 and 1-2 are both system_only then I would show 1_3, 1_4, 1_5 and 1_6.
            
            if !ap1Switches[1].isHidden {
                ap1Switches[5].isHidden = true
            }
        }
    }
}

extension LanMeshViewController: TitledTextFieldDelegate {
    func textDidChange(sender: TitledTextField) {
        vm.updateConfigUponChange()
    }
}

extension LanMeshViewController: LanConfigurationChildViewControllerProtocol {
    func shouldShowRestartWarning() -> Bool {
        hasUpdated
    }
    
    func returnErrorMessage() -> String? {
        return vm.wanEntryErrors
    }
    
    func entriesAreValid() -> Bool {
        if vm.wanEntryErrors != nil {
            self.updateWanInterfaceUi()
            return true
        }
        self.updateWanInterfaceUi()
        return true
    }
    
    func sendUpdate(completion: @escaping BaseConfigViewModel.CompletionDelegate) {
        if HubDataModel.shared.isMN {
            cancel(self)
            return
        }

        vm.updateConfigUponChange()
        if !vm.subnetsAreValid() {
            delegate.removeUpdatingUI()
            return
        }
        
        self.vm.updateSetting(completion: completion)
    }
    
    var hasUpdated: Bool {
        return updated
    }
    
    func childDidUpdateSelectedLan(lan: Int) {
        delegate.selectedLan = lan
        
        vm.updateConfigUponChange()
        vm.lastSelectedLan = lanSelection
        setAndPopulateLanNumber(lanNumber: lanSelection)
    }
    
    func childDidBecomeActive() {
        let lan = delegate.selectedLan
        
        let sLan = LanPickerView.Lans.lanFromInt(lan: lan)
        lanSelector.selectedLan = sLan
    }
}

// MARK: - Wan and IP Modes
extension LanMeshViewController {
    private func updateWanIpModeView() {
        let controller = wanIpController

        if let wanIpModeSelectorViewContainter {
            wanIpModeSelectorViewContainter.removeFromSuperview()
        }

        let wanIpModeSelectorView = WanIpModeSelectorView(wanModeText: controller.selectedWanMode.displayName,
                                                          ipModeText: controller.selectedIpMode.displayText, ipModeSelectHidden: controller.ipManagementHidden,
                                                          wanModeTapped: { self.wanModeTapped() },
                                                          ipModeTapped: { self.ipModeTapped() })

        self.wanIpModeSelectorViewContainter = SwiftUIUIView<WanIpModeSelectorView>(view: wanIpModeSelectorView,
                                                                                    requireSelfSizing: true).make()
        self.wanIpModeSelectorViewContainter!.addAndPinToEdgesOf(outerView: self.wanAndIpModeView)
    }

    private func wanModeTapped() {
        guard let wanIpModeSelectorViewContainter else { return }
        let controller = wanIpController
        let picker = MenuViewController.createMenuViewController(title: "WAN MODE".localized(),
                                                                 subTitle: "Choose a WAN MODE".localized(),
                                                                 options: controller.availableWanModesOptions,
                                                                 originView: wanIpModeSelectorViewContainter,
                                                                 offsetFromHorizontalCentreOfView: -80) { index, str in
            self.wanMode = controller.availableWanModes[index]
            self.vm.updateConfigUponChange()
            self.vm.setInitialIpManagmentMode(for: self.vm.lastSelectedLan)
            self.enableDisableIsolationViewForWanMode()
            self.enableSubnetFieldForWanMode()
            self.hideWanInterfaceIfNeeded()
            self.updateWanIpModeView()
        }

        present(picker, animated: true)

    }

    private func ipModeTapped() {
        guard let wanIpModeSelectorViewContainter else { return }
        let controller = wanIpController
        let picker = MenuViewController.createMenuViewController(title: "IP MODE".localized(),
                                                                 subTitle: "Choose a IP MODE".localized(),
                                                                 options: controller.availableIpModesOptions,
                                                                 originView: wanIpModeSelectorViewContainter,
                                                                 offsetFromHorizontalCentreOfView: 80) { index, str in
            let selected = controller.availableIpModes[index]
            self.vm.selectedIpManagementMode = selected
            self.updateWanIpModeView()
        }

        present(picker, animated: true)
    }

    private var wanIpController: WanIpModeController {
        let controller = WanIpModeController(supportsBackpack: vm.parentVm.supportsBackpack,
                                             supportsIpMode: vm.parentVm.supportsIpMode,
                                             selectedWanMode: wanMode,
                                             selectedIpMode: vm.selectedIpManagementMode)

        return controller
    }

    private func hideWanInterfaceIfNeeded() {
        let hidden = vm.currentlySelectedLanConfig?.wanMode == .ISOLATED
        wanInterfaceButton.isHidden = hidden
        wanInterface.isHidden = hidden
    }
}
