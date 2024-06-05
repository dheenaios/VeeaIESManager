//
//  LanStaticIpViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 15/03/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation
import UIKit

/// TAB 4: STATIC IPS
class LanStaticIpViewController: BaseConfigViewController, AnalyticsScreenViewEventProtocol {

    var screenName: AnalyticsEvents.ScreenNames = .lan_static_ip

    private let tag = "LanStaticIpViewController"
    private var vm: LanStaticIpViewModel!
    private let placeholderText = "###.###.###.###"

    @IBOutlet weak var lanSelector: LanPickerView!
    @IBOutlet weak var staticIpTextField: TitledTextField!
    @IBOutlet weak var gatewayIpTextField: TitledTextField!
    @IBOutlet weak var dns1TextField: TitledTextField!
    @IBOutlet weak var dns2TextField: TitledTextField!
    @IBOutlet weak var inlineHelpView: InlineHelpView!

    weak var delegate: LanConfigurationParentDelegate?

    static func new(delegate: LanConfigurationParentDelegate,
                    parentVm: LanConfigurationViewModel) -> LanStaticIpViewController {
        let sb = UIStoryboard(name: "LanConfiguration", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LanStaticIpViewController") as! LanStaticIpViewController
        vc.delegate = delegate
        vc.vm = LanStaticIpViewModel(parentViewModel: parentVm,
                                     selectedLan: delegate.selectedLan)

        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        lanSelector.hostVc = self
        inlineHelpView.setText(labelText: "Use this screen to configure a static IP for the LAN. This applies if the LAN is configured with a \"static\" IP mode.")
        inlineHelpView.observerTaps {
            // TODO:
        }

        // Hide until we have documentation
        inlineHelpView.hideLearnMore()

        setTextFieldsModes()
        populateConfig()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        vm.selectedLan = delegate?.selectedLan ?? 0
    }

    private func setTextFieldsModes() {
        staticIpTextField.setKeyboardType(type: .decimalPad)
        staticIpTextField.addSubnetEntryAccessory()
        staticIpTextField.placeholderText = placeholderText + "/##"
        gatewayIpTextField.setKeyboardType(type: .decimalPad)
        gatewayIpTextField.placeholderText = placeholderText
        dns1TextField.setKeyboardType(type: .decimalPad)
        dns1TextField.placeholderText = placeholderText
        dns2TextField.setKeyboardType(type: .decimalPad)
        dns2TextField.placeholderText = placeholderText

        staticIpTextField.delegate = self
        gatewayIpTextField.delegate = self
        dns1TextField.delegate = self
        dns2TextField.delegate = self
    }

    // Populate with details from the selected lan
    private func populateConfig() {
        if !vm.parentVm.supportsBackpack { return }
        guard let l = vm.selectedConfig else { return }

//        if vm.staticIpShouldReflectLanStatusIpSubnet {
//            staticIpTextField.text = vm.lanStatusSubnet
//        }
//        else {
//            staticIpTextField.text = l.ip4_address
//        }
        
        staticIpTextField.text = l.ip4_address

        let disabled = !vm.staticIpFieldShouldBeEditable
        staticIpTextField.disableView(disabled: disabled)
        gatewayIpTextField.disableView(disabled: disabled)
        dns1TextField.disableView(disabled: disabled)
        dns2TextField.disableView(disabled: disabled)

        gatewayIpTextField.text = l.ip4_gateway
        dns1TextField.text = l.ip4_dns_1
        dns2TextField.text = l.ip4_dns_2
    }
}

extension LanStaticIpViewController: LanConfigurationChildViewControllerProtocol {
    func childDidBecomeActive() {
        guard let lan = delegate?.selectedLan else { return }

        let sLan = LanPickerView.Lans.lanFromInt(lan: lan)
        lanSelector.selectedLan = sLan
    }
    func returnErrorMessage() -> String? {
        return vm.entriesHaveErrors()
    }

    func childDidUpdateSelectedLan(lan: Int) {
        saveToConfig()
        delegate?.selectedLan = lan
        vm.selectedLan = lan
        populateConfig()
    }

    var hasUpdated: Bool {
        return vm.isChanged
    }

    func entriesAreValid() -> Bool {
        guard let errorMessage = vm.entriesHaveErrors() else {
            return true
        }

        //showAlert(with: "Validation Error".localized(), message: "\("Some of your entries are invalid...".localized()) \n\(errorMessage)")

        return true
    }

    func shouldShowRestartWarning() -> Bool {
        return false
    }

    func sendUpdate(completion: @escaping BaseConfigViewModel.CompletionDelegate) {
        if entriesAreValid() {
            vm.applyUpdate(completion: completion)
        }
    }
}

extension LanStaticIpViewController: TitledTextFieldDelegate {
    func textDidChange(sender: TitledTextField) {
        let text = sender.text ?? ""
        if sender === staticIpTextField { // CIDR
            let text = sender.text ?? ""
            let valid = AddressAndPortValidation.simpleIpSubnetError(string: text) == nil
            sender.textField.textColor = valid ? .label : .red
            if !valid {
                saveToConfig(informParentOfChange: false)
                return
            }
        }
        else { // IPV4
            let valid = AddressAndPortValidation.isIPValid(string: text)
            sender.textField.textColor = valid ? .label : .red
        }

        saveToConfig()
    }

    private func saveToConfig(informParentOfChange: Bool = true) {
        guard var config = vm.selectedConfig else { return }

        config.ip4_address = staticIpTextField.text ?? ""
        config.ip4_gateway = gatewayIpTextField.text ?? ""
        config.ip4_dns_1 = dns1TextField.text ?? ""
        config.ip4_dns_2 = dns2TextField.text ?? ""

        vm.selectedConfig = config

        if informParentOfChange { updateChangeState() }
    }

    private func updateChangeState() {
        delegate?.childUpdateStateChanged(updated: vm.isChanged)
    }
}
