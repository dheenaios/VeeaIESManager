//
//  DhcpViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 30/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

/// TAB 2: LAN IP
class DhcpViewController: BaseConfigViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .lan_settings_screen
    var flowController: HubInteractionFlowController?
    private let placeholderText = "###.###.###.###"
    private var vm: DhcpDnsViewModel!
    private let tag = "DhcpDnsViewController"

    static func new(delegate: LanConfigurationParentDelegate,
                    parentVm: LanConfigurationViewModel) -> DhcpViewController {
        let sb = UIStoryboard(name: "LanConfiguration", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "DhcpViewController") as! DhcpViewController
        vc.delegate = delegate
        vc.vm = DhcpDnsViewModel(parentViewModel: parentVm)

        return vc
    }
    
    private var updated = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var verticalStack: UIStackView!

    @IBOutlet weak var leaseTimeTextField: TitledTextField!
    @IBOutlet weak var dns1TextField: TitledTextField!
    @IBOutlet weak var dns2TextField: TitledTextField!
    @IBOutlet weak var startIpTextField: TitledTextField!
    @IBOutlet weak var endIpTextField: TitledTextField!
    @IBOutlet weak var numberOfIps: KeyValueView!
    @IBOutlet weak var subnetMask: KeyValueView!
    @IBOutlet weak var bottomError: UILabel!
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var lanSelector: LanPickerView!
    
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    weak var delegate: LanConfigurationParentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        lanSelector.hostVc = self
        scrollView.keyboardDismissMode = .onDrag
        
        inlineHelpView.setText(labelText: "Use this screen to configure a DHCP server for each LAN that has been configured on the LAN configuration tab.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
        
        numberOfIps.setUp(key: "#IPs".localized(),
                          value: "",
                          showLowerSep: false, showUpperSep: true,
                          hostViewController: self,
                          questionText: "")
        subnetMask.setUp(key: "Subnet Mask".localized(), value: "",
                         showLowerSep: true,
                         showUpperSep: true,
                         hostViewController: self,
                         questionText: "")
        numberOfIps.isUserInteractionEnabled = false
        numberOfIps.button.isUserInteractionEnabled = false
        subnetMask.isUserInteractionEnabled = false
        
        leaseTimeTextField.delegate = self
        dns1TextField.delegate = self
        dns2TextField.delegate = self
        startIpTextField.delegate = self
        endIpTextField.delegate = self
        
        leaseTimeTextField.setKeyboardType(type: .numberPad)
        dns1TextField.setKeyboardType(type: .decimalPad)
        dns1TextField.placeholderText = placeholderText
        dns2TextField.setKeyboardType(type: .decimalPad)
        dns2TextField.placeholderText = placeholderText
        startIpTextField.setKeyboardType(type: .decimalPad)
        startIpTextField.placeholderText = placeholderText
        endIpTextField.setKeyboardType(type: .decimalPad)
        endIpTextField.placeholderText = placeholderText
        
        bottomError.text = ""
        
        populateConfig()
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .lan_dhcp, push: true)
    }
    
    var selectedLan: NodeLanConfigModel {
        return vm.nodeLanConfigModels[lanSelection]
    }
    
    var selectedMeshLan: MeshLan {
        get {
            return vm.meshLans[lanSelection]
        }
    }
    
    private var lanSelection: Int {
        return delegate?.selectedLan ?? 0
    }
    
    private func saveToConfig() {
        let configModel = vm.nodeLanConfigModels[lanSelection]
        
        let leaseTime = Int(leaseTimeTextField.text ?? "0") ?? 0
        configModel.lease_time = leaseTime
        configModel.dns_1 = dns1TextField.text ?? ""
        configModel.dns_2 = dns2TextField.text ?? ""
        
        let defaultsTuple = getDefultRangeDetails()
        if startIpTextField.text == defaultsTuple.0 &&
            endIpTextField.text == defaultsTuple.1 {
            configModel.start_ip = ""
            configModel.end_ip = ""
        }
        else {
            configModel.start_ip = startIpTextField.text ?? ""
            configModel.end_ip = endIpTextField.text ?? ""
        }
        
        updateChangeState()
    }
    
    private func updateChangeState() {
        for lan in vm.nodeLanConfigModels {
            do {
                let differences = try JsonDiffer.diffJson(original: lan.originalJson, target: lan.getUpdateJSON())
                if !differences.isEmpty {
                    updated = true
                    delegate?.childUpdateStateChanged(updated: true)
                    return
                }
            }
            catch {
                Logger.log(tag: "DhcpViewController",
                           message: "Json Differ has thrown: \(error.localizedDescription)")
            }
        }
        
        updated = false
        delegate?.childUpdateStateChanged(updated: false)
    }
    
    /// Get the start and end ips and number of hosts
    /// - Returns: A tuple containing: starting IP, ending IP, number of hosts
    func getDefultRangeDetails() -> (String, String, Int) {
        let meshModel = vm.meshLans[delegate?.selectedLan ?? 0]        
        let subnet = meshModel.ip4_subnet
        let subnetModel = SubnetModel.subnet(fromIpAndPrefix: subnet)
        
        let s = subnetModel?.startHostAddress ?? ""
        let e = subnetModel?.endHostAddress ?? ""
        let h = subnetModel?.numberOfHosts ?? 0
        
        return (s, e, h)
    }
    
    private func populateConfig() {
        leaseTimeTextField.text = "\(selectedLan.lease_time)"
        dns1TextField.text = selectedLan.dns_1
        dns2TextField.text = selectedLan.dns_2
        startIpTextField.text = selectedLan.start_ip
        endIpTextField.text = selectedLan.end_ip
        subnetMask.value = selectedMeshLan.ip4_subnet
        
        validateStartIP(str: startIpTextField.text ?? "")
        validateEndIP(str: endIpTextField.text ?? "")
        
        calculateIpRange()
        insertDefaultIpValuesIfNeeded()
        validateAgainstStaticIPSettings()

        if vm.viewEnabled(selectedLan: lanSelection) {
            enableSettings(enable: selectedMeshLan.dhcp)
        }
        else {
            enableSettings(enable: false)
        }

    }

    private func enableSettings(enable: Bool) {
        let views = verticalStack.arrangedSubviews
        for view in views {
            view.disableView(disabled: !enable)
        }
    }
    
    private func calculateIpRange() {
        let range = getDefultRangeDetails()
        guard let start = startIpTextField.text, let end = endIpTextField.text else {
            numberOfIps.value =  "-/\(range.2)"
            return
        }
        
        if !AddressAndPortValidation.isIPValid(string: start) ||
            !AddressAndPortValidation.isIPValid(string: end) {
            //numberOfIps.value = "?"
            numberOfIps.value = IPAddressCalculations.calculateIpRangeDescription(addr1: start, addr2: end) + "/\(range.2)"
            return
        }
        
        numberOfIps.value = IPAddressCalculations.calculateIpRangeDescription(addr1: start, addr2: end) + "/\(range.2)"
    }
    
    private func insertDefaultIpValuesIfNeeded() {
        if ((selectedLan.start_ip.isEmpty) &&
                selectedLan.end_ip.isEmpty) {
            insertDefaultIpValues()
        }
    }
    
    private func insertDefaultIpValues() {
        let rangeDetails = getDefultRangeDetails()
        startIpTextField.placeholderText = rangeDetails.0
        endIpTextField.placeholderText = rangeDetails.1
        numberOfIps.value = "\(rangeDetails.2)"
        calculateIpRange()
        startIpTextField.textField.textColor = .lightGray
        endIpTextField.textField.textColor = .lightGray
    }
    
    private func validateAgainstStaticIPSettings() {
        bottomError.text = ""
        
        if !IPConflictionHelper.areStaticIpSettingsForLan(lan: lanSelection) {
            return
        }
        
        if !AddressAndPortValidation.isIPValid(string: startIpTextField.text!) ||
            !AddressAndPortValidation.isIPValid(string: startIpTextField.text!){
            return
        }
        
        guard let lans = HubDataModel.shared.optionalAppDetails?.nodeLanStaticIpConfig?.lans else {
            return
        }
        
        let lan = lans[lanSelection]
        
        for item in lan {
            let ip = item.ip
            
            if ip.isEmpty {
                return
            }
            
            if !IPAddressCalculations.isIP(ip: ip, between: startIpTextField.text!, and: endIpTextField.text! ) {
                var name = item.host
                if !name.isEmpty {
                    name = "\"\(name)\""
                }
                
                bottomError.text = "\("Error: Reserved IP".localized()) \(name) \("set to".localized()) \(ip) \("is outside this range.\nGo to the reserved IP page to change.".localized())"
                
                return
            }
        }
    }
    
    
    func validateStartAndEndIP() -> String {
        if !(startIpTextField.text?.isEmpty ?? false) && !(endIpTextField.text?.isEmpty ?? false) {
            let startInt = IPAddressCalculations.ipToInt(addrString:startIpTextField.text ?? "")
            let endInt = IPAddressCalculations.ipToInt(addrString: endIpTextField.text ?? "")
            
            if startInt == nil || endInt == nil {
                return "IPs are incorrectly formatted".localized()
            }
            if startInt == endInt {
                return "Start and ending IPs are the same".localized()
            }
            
            if startInt != nil && endInt != nil {
                if startInt! > endInt! {
                    return "Start IP > End IP".localized()
                }
            }
            
            // Mask
            let subnet = selectedMeshLan.ip4_subnet
            let parts = subnet.split(separator: "/")
            if parts.count == 2 {
                let mask = Int(parts.last!) ?? -1
                if !AddressAndSubnetValidation.areBothIpsOnSameSubnet(ipA: startIpTextField.text ?? "",
                                                                      ipB: endIpTextField.text ?? "",
                                                                      mask: mask) {
                    return "Start/End IPs that are not within its subnet".localized()
                }
            }
        }
        return ""
    }
    
    func  validateStartIP(str:String) {
        startIpTextField.textField.textColor = UIColor.black
        if !AddressAndPortValidation.isIPValid(string: str) && !(str.isEmpty ) {
            startIpTextField.textField.textColor = UIColor.red
            startIpTextField.setErrorLabel(message: "starting IP is not a valid IP address".localized())
        }
        else {
            let msg = validateStartAndEndIP()
            if msg != "" {
                startIpTextField.setErrorLabel(message: msg)
                startIpTextField.textField.textColor = UIColor.red
            }
            else{
                startIpTextField.setErrorLabel(message: "")
            }
        }
    }
    
    func validateEndIP(str:String) {
        endIpTextField.textField.textColor = UIColor.black
        if !AddressAndPortValidation.isIPValid(string: str) && !(str.isEmpty ) {
            endIpTextField.textField.textColor = UIColor.red
            endIpTextField.setErrorLabel(message: "end IP is not a valid IP address".localized())
        }
        else {
            let msg = validateStartAndEndIP()
            if msg != "" {
                endIpTextField.setErrorLabel(message: msg)
                endIpTextField.textField.textColor = UIColor.red
            }
            else{
                endIpTextField.setErrorLabel(message: "")
            }
        }
    }
}

extension DhcpViewController: TitledTextFieldDelegate {
    
    
    func textDidChange(sender: TitledTextField) {
        if sender == dns1TextField ||
            sender == dns2TextField ||
            sender == startIpTextField ||
            sender == endIpTextField {
            sender.textField.textColor = UIColor.black
            
            //            if !AddressAndPortValidation.isIPValid(string: sender.text ?? "") {
            //                sender.textField.textColor = UIColor.red
            //            }
            //            else if sender == startIpTextField {
            //                let ds = getDefultRangeDetails().0
            //                if startIpTextField.textField.text == ds {
            //                    startIpTextField.textField.textColor = .lightGray
            //                    startIpTextField.setErrorLabel(message: "")
            //                }
            //            }
            //            else if sender == endIpTextField {
            //                let de = getDefultRangeDetails().1
            //                if endIpTextField.textField.text == de {
            //                    endIpTextField.textField.textColor = .lightGray
            //                    endIpTextField.setErrorLabel(message: "")
            //                }
            //            }
            
            if sender == dns1TextField {
                if !AddressAndPortValidation.isIPValid(string: dns1TextField.text ?? "") && !(dns1TextField.text?.isEmpty ?? false) {
                    dns1TextField.textField.textColor = UIColor.red
                    dns1TextField.setErrorLabel(message: "dns1 is not a valid IP address".localized())
                }
                else {
                    dns1TextField.setErrorLabel(message: "")
                }
            }
            
            if sender == dns2TextField {
                if !AddressAndPortValidation.isIPValid(string: dns2TextField.text ?? "") && !(dns2TextField.text?.isEmpty ?? false) {
                    dns2TextField.textField.textColor = UIColor.red
                    dns2TextField.setErrorLabel(message: "dns2 is not a valid IP address".localized())
                }
                else {
                    dns2TextField.setErrorLabel(message: "")
                }
            }
            
            if sender == startIpTextField {
                validateStartIP(str:startIpTextField.text ?? "")
            }
            else if sender == endIpTextField {
                validateEndIP(str: endIpTextField.text ?? "")
            }
        }
        
        calculateIpRange()
        saveToConfig()
        validateAgainstStaticIPSettings()
    }
}

extension DhcpViewController: LanConfigurationChildViewControllerProtocol {
    func returnErrorMessage() -> String? {
        return ""
    }
    
    func shouldShowRestartWarning() -> Bool {
        hasUpdated
    }
    
    func sendUpdate(completion: @escaping BaseConfigViewModel.CompletionDelegate) {        
        vm.applyUpdate(completion: completion)
    }
    
    var hasUpdated: Bool {
        return updated
    }
    
    func childDidUpdateSelectedLan(lan: Int) {
        saveToConfig()
        delegate?.selectedLan = lan
        populateConfig()
    }
    
    func childDidBecomeActive() {
        guard let lan = delegate?.selectedLan else { return }
        
        let sLan = LanPickerView.Lans.lanFromInt(lan: lan)
        lanSelector.selectedLan = sLan
        enableSettings(enable: vm.viewEnabled(selectedLan: lanSelection))
    }

    // Called from the parent view controller
    func entriesAreValid() -> Bool {
        guard let errorMessage = vm.entriesHaveErrors(selectedMeshLan: selectedMeshLan) else {
            return true
        }

        showAlert(with: "Validation Error".localized(), message: "\("Some of your entries are invalid...".localized()) \n\(errorMessage)")

        return false
    }
}
