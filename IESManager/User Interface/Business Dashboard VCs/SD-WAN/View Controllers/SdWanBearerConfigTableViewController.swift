//
//  SdWanBearerConfigTableViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 06/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

class SdWanBearerConfigTableViewController: BaseConfigTableViewController, HubInteractionFlowControllerProtocol {
    var flowController: HubInteractionFlowController?
    
    let vm = SdWanBearerConfigViewModel()
    
    private let tag = "SdWanBearerConfigTableViewController"
    
    public var backhaulType: String?
        
    // INTERFACE CELLS
    @IBOutlet private weak var interfaceNameView: TitledTextField!
    
    // CONNECTION TEST CELLS
    
    @IBOutlet private weak var testMethodView: TitledTextField!
    @IBOutlet private weak var testRemoteView: IPValueView!
    @IBOutlet private weak var testTimeout: TitledTextField!
    @IBOutlet private weak var testInterval: TitledTextField!
    @IBOutlet private weak var disableTime: TitledTextField!
    @IBOutlet private weak var reenableTime: TitledTextField!
    
    // CONNECTION TEST RESULT CELLS
    @IBOutlet private weak var lastResultView: TitledTextField!
    @IBOutlet private weak var lastTestTimeView: TitledTextField!
    @IBOutlet private weak var lastSuccessfulTestView: TitledTextField!
    @IBOutlet private weak var lastUnsuccessfulTestView: TitledTextField!
    @IBOutlet private weak var lastStateChangeView: TitledTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .onDrag
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        navigationItem.rightBarButtonItem = doneButton
        
        title = "WAN"
        
        testMethodView.readOnly = true
        interfaceNameView.readOnly = true
        lastResultView.readOnly = true
        lastTestTimeView.readOnly = true
        lastSuccessfulTestView.readOnly = true
        lastUnsuccessfulTestView.readOnly = true
        lastStateChangeView.readOnly = true
        
        populateUI()
    }
    
    private func populateUI() {
        title = "WAN: \(backhaulType ?? "")"
                
        interfaceNameView.text = vm.backhaulConfig?.interface
        testMethodView.text = vm.backhaulConfig?.test.method
        testRemoteView.text = vm.backhaulConfig?.test.remote
        testTimeout.intText = vm.backhaulConfig?.test.timeout
        testTimeout.setKeyboardType(type: .numberPad)
        testInterval.intText = vm.backhaulConfig?.test.interval
        testInterval.setKeyboardType(type: .numberPad)
        disableTime.intText = vm.backhaulConfig?.disable_time_out
        disableTime.setKeyboardType(type: .numberPad)
        reenableTime.intText = vm.backhaulConfig?.reenable_timeout
        reenableTime.setKeyboardType(type: .numberPad)
        lastResultView.text = vm.backhaulConfig?.last_test_result == false ? "Fail".localized() : "Success".localized();
        
        guard let backhaul = vm.backhaulConfig else { return }
        
        lastTestTimeView.text = Date.stringFromEpoch(epoch: backhaul.last_test_time)
        lastSuccessfulTestView.text = Date.stringFromEpoch(epoch: backhaul.last_successful_test)
        lastUnsuccessfulTestView.text = Date.stringFromEpoch(epoch: backhaul.last_unsuccessful_test)
        lastStateChangeView.text = Date.stringFromEpoch(epoch: backhaul.last_state_change)
    }

    override func applyConfig() {
        
        if AddressAndPortValidation.isIPValid(string: testRemoteView.text!) == false {
            showInfoAlert(title: "Remote Test IP is not valid".localized(), message: "Please correct and try again".localized())
            
            return
        }
        
        vm.backhaulConfig?.test.method = testMethodView.text ?? (vm.backhaulConfig?.test.method)!
        vm.backhaulConfig?.test.remote = testRemoteView.text ?? (vm.backhaulConfig?.test.remote)!
        vm.backhaulConfig?.test.timeout = testTimeout.intText ?? (vm.backhaulConfig?.test.timeout)!
        vm.backhaulConfig?.test.interval = testInterval.intText ?? (vm.backhaulConfig?.test.interval)!
        vm.backhaulConfig?.disable_time_out = disableTime.intText ?? (vm.backhaulConfig?.disable_time_out)!
        vm.backhaulConfig?.reenable_timeout = reenableTime.intText ?? (vm.backhaulConfig?.reenable_timeout)!
        
        // Check to config against
        var comparisonConfig: SdWanBackhaulConfig?
        if backhaulType == GatewayConfigViewModel.BackhaulTypes.cellular {
            comparisonConfig = HubDataModel.shared.optionalAppDetails?.sdWanConfig?.cellularBackHaulConfig
        }
        else if backhaulType == GatewayConfigViewModel.BackhaulTypes.wifi {
            comparisonConfig = HubDataModel.shared.optionalAppDetails?.sdWanConfig?.wifiBackHaulConfig
        }
        else if backhaulType == GatewayConfigViewModel.BackhaulTypes.ethernet {
            comparisonConfig = HubDataModel.shared.optionalAppDetails?.sdWanConfig?.ethernetBackHaulConfig
        }
        
        if let comparisonConfig = comparisonConfig {
            if comparisonConfig != vm.backhaulConfig {
                sendUpdate()
            }
            else {
                dismissCard()
            }
        }
    }
    
    private func sendUpdate() {
        guard let ies = connection else {
            Logger.log(tag: tag, message: "No VHM")
            
            return
        }
        
        updateUpdateIndicatorState(state: .uploading)
        
        var unmodifiedSsWanConfig = HubDataModel.shared.optionalAppDetails?.sdWanConfig
        
        if backhaulType == GatewayConfigViewModel.BackhaulTypes.cellular {
            unmodifiedSsWanConfig?.cellularBackHaulConfig = vm.backhaulConfig
        }
        else if backhaulType == GatewayConfigViewModel.BackhaulTypes.wifi {
            unmodifiedSsWanConfig?.wifiBackHaulConfig = vm.backhaulConfig
        }
        else if backhaulType == GatewayConfigViewModel.BackhaulTypes.ethernet {
            unmodifiedSsWanConfig?.ethernetBackHaulConfig = vm.backhaulConfig
        }
        
        guard let config = unmodifiedSsWanConfig else {
            Logger.log(tag: tag, message: "Error: could not find the backhaul that has changed")
            
            return
        }
        
        ApiFactory.api.setConfig(connection: ies, config: config) { [weak self]  (result, error) in
            if error != nil {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                self?.showErrorUpdatingAlert(error: error!)
                
                return
            }
            
            HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
        }
    }
}

extension SdWanBearerConfigTableViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        self.updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}
