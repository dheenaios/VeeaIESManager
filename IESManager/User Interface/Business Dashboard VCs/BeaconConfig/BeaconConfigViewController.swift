//
//  BeaconConfigurationViewController.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 23/03/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class BeaconConfigViewController: BaseConfigViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .bt_details_screen

    var flowController: HubInteractionFlowController?
    
    
    @IBOutlet weak var macAddressField: KeyValueView!
    @IBOutlet weak var subDomainField: KeyValueView!
    @IBOutlet weak var instIdField: KeyValueView!
    @IBOutlet weak var beaconKeyField: KeyValueView!
    @IBOutlet weak var enabledField: UIView!
    @IBOutlet weak var enabledSwitch: UISwitch!
    @IBOutlet weak var applyButton: UIBarButtonItem!
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
    private var newBeaconKey: String?
    let vm = BeaconConfigViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BT Beacon".localized()
        let hidden = TesterMenuDataModel.UIOptions.disableDestructiveOptions
        
        beaconKeyField.isHidden = hidden
        enabledField.isHidden = hidden
        
        if TesterMenuDataModel.UIOptions.disableDestructiveOptions {
            applyButton.isEnabled = false
            applyButton.tintColor = .clear
            doNotSend = true
        }
        
        macAddressField.setUp(key: "MAC Address".localized(),
                              value: self.vm.btMacAddress,
                              showLowerSep: true,
                              showUpperSep: false,
                              hostViewController: nil,
                              questionText: nil)
        
        subDomainField.setUp(key: "Sub-Domain".localized(),
                             value: self.vm.subDomain,
                             showLowerSep: true,
                             showUpperSep: false,
                             hostViewController: nil,
                             questionText: nil)
        
        instIdField.setUp(key: "Instance ID".localized(),
                          value: vm.instanceId,
                          showLowerSep: true,
                          showUpperSep: false,
                          hostViewController: nil,
                          questionText: nil)
        
        beaconKeyField.setUp(key: "Beacon Key".localized(), value: "",
                             showLowerSep: true,
                             showUpperSep: false,
                             hostViewController: self,
                             questionText: "Set new beacon key".localized())
        
        self.enabledSwitch.setOn( !self.vm.locked, animated: true)
        
        subDomainField.valueLabel.textColor = .lightGray
        instIdField.valueLabel.textColor = .lightGray
        beaconKeyField.valueLabel.textColor = .lightGray
        
        inlineHelpView.setText(labelText: "This screen is for information only. The Bluetooth beacon on a VeeaHub advertises a sub-domain and Instance ID.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .bt_beacon, push: true)
    }
    
    @IBAction func applyTapped(_ sender: Any) {
        let destructive = TesterMenuDataModel.UIOptions.disableDestructiveOptions
        if destructive {
            navigationController?.popViewController(animated: true)
            return
        }
        
        applyConfig()
    }
    
    override func applyConfig() {
        if sendingUpdate {
            return
        }
        
        sendingUpdate = true
        updateUpdateIndicatorState(state: .uploading)
        
        vm.subDomain = subDomainField.value
        vm.instanceId = instIdField.value
        vm.locked = !enabledSwitch.isOn
        
        if let newBeaconKey = newBeaconKey {
            vm.beaconDecryptKey = newBeaconKey
            vm.applyBeaconKeyUpdate()
        }
        
        vm.applyUpdate { (message, error) in
            if error != nil {
                self.sendingUpdate = false
                
                self.updateUpdateIndicatorState(state: .completeWithError)
                self.showErrorUpdatingAlert(error: error!)
                
                return
            }
            
            HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
        }
    }
}

extension BeaconConfigViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        self.updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}
