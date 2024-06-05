//
//  APConfigSelectionViewController.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 12/03/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

public enum SelectedAP {
    case AP1
    case AP2
}

public enum SelectedOperation {
    case Start
    case Disabled
}

class APConfigSelectionViewController: UIViewController, HubInteractionFlowControllerProtocol {
    var flowController: HubInteractionFlowController?

    private var numberOfCallsInProgress = 0
    private var sendError: APIError?
    public var dashboard: DashViewController?
    
    private enum SelectedConfig {
        case wifiAps
        case radio
    }
    
    private let sb = UIStoryboard(name: "WifiApManagement", bundle: nil)
    
    public var nodeCapabilitiesConfig: NodeCapabilities?

    @IBOutlet weak private var segmentedControl: VeeaSegmentedControl!
    @IBOutlet weak private var container: UIView!
    private var viewInContainer: UIViewController?
    
    private var freq: SelectedAP = .AP1
    public var meshConfig: AccessPointsConfig?
    public var nodeConfig: AccessPointsConfig?
    public var radioConfig: NodeConfig?
    public var isMN: Bool = false
    public var selectedConnection: HubConnectionDefinition?
    
    var operationSelected:SelectedOperation = .Start

    @IBAction func selectionChanged(_ sender: Any) {
        setHeader()
        setView()
    }
    
    @IBAction func applyTapped(_ sender: Any) {
        // This is a little around the houses but in this instance APConfigSelectionViewController
        // owns the apply button. Tell the front most view controller to apply
        if currentSelection == .radio { radioViewController.applyConfig() }
        else { wifiApViewController.applyConfig() }
    }
    
    private lazy var wifiApViewController: APConfigurationViewController = {
        let vc = sb.instantiateViewController(withIdentifier: "APConfigurationViewController") as! APConfigurationViewController
        vc.configure(freq: freq, hub: selectedConnection!, tabBarVc: self)
        vc.vm?.selectedOperation = operationSelected
        return vc
    }()
    
    private lazy var radioViewController: APRadioConfigTableViewController = {
        let vc = sb.instantiateViewController(withIdentifier: "APRadioConfigTableViewController") as! APRadioConfigTableViewController
        
        vc.vm.selectedFreq = freq
        vc.vm.config = radioConfig
        vc.connection = selectedConnection
        vc.tabController = self
        
        return vc
    }()
    
    public func configure(selectedFreq: SelectedAP,
                          meshConfig mC: AccessPointsConfig,
                          nodeCongig nC: AccessPointsConfig,
                          radioConfig rC: NodeConfig,
                          nodeCapabilityConfih ncc:NodeCapabilities,
                          connection: HubConnectionDefinition) {
        freq = selectedFreq
        nodeConfig = nC
        meshConfig = mC
        radioConfig = rC
        nodeCapabilitiesConfig = ncc
        selectedConnection = connection
        
        isMN = radioConfig?.node_type == "MN" ? true : false
    }
    
    private func setView() {
        if let vc = viewInContainer {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        
        if currentSelection == .radio {
            radioViewController.willMove(toParent: self)
            addChild(radioViewController)
            radioViewController.view.frame = container.bounds
            container.addSubview(radioViewController.view)
            radioViewController.didMove(toParent: self)
            radioViewController.recordScreenAppear()
            radioViewController.refreshScreenWhenOperationDisabled()

        }
        else {
            wifiApViewController.willMove(toParent: self)
            addChild(wifiApViewController)
            wifiApViewController.view.frame = container.bounds
            container.addSubview(wifiApViewController.view)
            wifiApViewController.didMove(toParent: self)
            wifiApViewController.vm?.selectedOperation = operationSelected
            wifiApViewController.recordScreenAppear()
            wifiApViewController.refreshScreenWhenOperationDisabled()

        }
    }
    
    private func setHeader() {
        let headerTitle = freq == .AP1 ? "Wi-Fi (2.4GHz)".localized() : "Wi-Fi (5GHz)".localized()
        title = headerTitle
    }
    
    private var currentSelection: SelectedConfig {
        return segmentedControl.selectedSegmentIndex == 0 ? .wifiAps : .radio
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyButtonIsHidden = true
        operationSelected = returningOperationValueOfHub()

        setHeader()
        setView()
    }
    func returningOperationValueOfHub()->SelectedOperation {
           guard let nodeConfig = HubDataModel.shared.baseDataModel?.nodeConfig else {
               return .Start
           }
            if freq == .AP1 {
                if nodeConfig.access1_local_control?.lowercased() == "locked" {
                   return .Disabled
               }
            }else{
                if nodeConfig.access2_local_control?.lowercased() == "locked" {
                   return .Disabled
               }
            }
            return .Start
    }
    func childVcDataModelWasUpdated() {
        if wifiApViewController.isDataModelUpdated() {
            applyButtonIsHidden = false
        }
        else if radioViewController.isDataModelUpdated() {
            applyButtonIsHidden = false
        }
        else {
            applyButtonIsHidden = true
        }
        operationSelected = .Start
        if freq == .AP1 {
            if radioViewController.vm.currentOperation == .Disabled {
                operationSelected = .Disabled
                wifiApViewController.vm?.selectedOperation = .Disabled
            }else{
                wifiApViewController.vm?.selectedOperation = .Start
            }
        }else{
            if radioViewController.vm.currentOperation == .Disabled {
                operationSelected = .Disabled
            }
        }
        
    }
}

// MARK: - Update handling
extension APConfigSelectionViewController {
    public func vcIsDoneWithUpdates(handler: @escaping (APIError?) -> Void) {
        guard let apModel = wifiApViewController.vm else {
            showErrorInfoMessage(message: "Error getting AP configuration model".localized())
            return
        }
        
        let sySettingsValid = apModel.enterpriseSecuritySettingsAreValid()
        if !sySettingsValid.0 {
            handler(APIError.Failed(message: sySettingsValid.1!))
            return
        }

        let apValid = apModel.ssidsAndPasswordsAreValid

        if  apValid.0 {
            let ssidOrPassChanged = apModel.hasSsidOrPasswordChanged

            if ssidOrPassChanged {
                showSsidOrPasswordChangeWarning { (procceed) in
                    if procceed {
                        self.sendUpdates(handler: handler)
                    }
                    else {
                        self.radioViewController.updateUpdateIndicatorState(state: .completeWithError)
                        self.wifiApViewController.updateUpdateIndicatorState(state: .completeWithError)
                    }
                }
            }
            else {
                sendUpdates(handler: handler)
            }
        }
        else {
            wifiApViewController.removeUpdateIndicator()

            if !apValid.0 {
                showAlert(with: "Hub Wi-Fi Error".localized(), message: apValid.1 ?? "Unknown Error in Hub Wi-Fi configuration".localized())
            }
            else if !apValid.0 {
                showAlert(with: "Network Wi-Fi Error".localized(), message: apValid.1 ?? "Unknown Error in Network Wi-Fi configuration".localized())
            }
        }
    }
    
    private func showSsidOrPasswordChangeWarning(procceed: @escaping (Bool) -> Void) {
        let message = "Changing this setting will cause a brief interruption to your network. If you are connected to your VeeaHub's Wi-Fi, you will be disconnected until the change is applied.".localized()
                
        let alertVc = UIAlertController(title: "This action will disrupt connectivity".localized(), message: message, preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { (alert) in
            procceed(false)
        }))
        alertVc.addAction(UIAlertAction(title: "Apply".localized(), style: .destructive, handler: { (alert) in
            procceed(true)
        }))

        present(alertVc, animated: true, completion: nil)
    }
}

// MARK: - Sending
extension APConfigSelectionViewController {
    
    private func sendUpdates(handler: @escaping (APIError?) -> Void) {
        let radioUpdated = radioViewController.isDataModelUpdated()
        let apUpdated = wifiApViewController.vm?.isDataModelUpdated ?? false

        if !radioUpdated && !apUpdated {
            handler(nil)
            navigationController?.popViewController(animated: true)
            return
        }

        numberOfCallsInProgress = 0
        sendError = nil

        // Check radio
        if radioUpdated {
            if radioViewController.vm.config != nil {
                self.send(config: radioViewController.vm.config!, handler: handler)
            }
        }

        if let model = wifiApViewController.vm {
            if apUpdated {
                if let config = model.nodeAccessPointConfig {
                    if model.nodeApChanged {
                        self.send(config: config, handler: handler)
                    }
                }
                
                if let config = wifiApViewController.vm?.meshAccessPointConfig {
                    if model.meshApChanged {
                        self.send(config: config, handler: handler)
                    }
                }
            }
        }
    }
    
    private func send(config: ApiRequestConfigProtocol,
                      handler: @escaping (APIError?) -> Void) {
        guard let ies = selectedConnection else {
            return
        }
        
        numberOfCallsInProgress += 1
        
        ApiFactory.api.setConfig(connection: ies, config: config) { [weak self] (result, error) in
            self?.numberOfCallsInProgress -= 1
            
            // If the change warning has been shown, then a ssid or psk has been changed
            if self?.numberOfCallsInProgress == 0 {
                if (self?.sendError) != nil {
                    self?.dashboard?.navigationController?.popViewController(animated: true)
                }
                else {
                    HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
                }
            }
            
            handler(self?.sendError)
        }
    }
}

extension APConfigSelectionViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        if success {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
    
    
}
