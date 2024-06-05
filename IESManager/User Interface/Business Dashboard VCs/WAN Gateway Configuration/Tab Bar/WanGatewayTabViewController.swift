//
//  WanGatewayTabViewController.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 24/03/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

protocol WanGatewayTabViewControllerDelegate: UIViewController {
    func viewControllersDataSetChanged(viewController: UIViewController)
    var selectedWan: Int { get set }
}

protocol WanAwareGatewayChildControllerDelegate {
    func wanDidChange(wan: Int)
    func childDidBecomeActive()
}

class WanGatewayTabViewController: UIViewController, HubInteractionFlowControllerProtocol {
    var flowController: HubInteractionFlowController?

    private enum SelectedConfig {
        case configuration
        case interfaces
        case reservedIps
        
        static func configForInt(i: Int) -> SelectedConfig {
            if i == 0 { return .configuration }
            else if i == 1 { return .interfaces }
            else if i == 2 { return .reservedIps }
            
            return .configuration
        }
    }
    
    private var currentWan = 0
    
    private let topConstraintUp: CGFloat = 44 // WAN selector not visible
    private let topConstraintDown: CGFloat = 104 // WAN selector visible
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var wanSelector: WanPickerView!
    
    lazy var gatewayConfigViewController: GatewayConfigViewController = {
        let vc = sb.instantiateViewController(withIdentifier: "GatewayConfigViewController") as! GatewayConfigViewController
        vc.updateDelegate = self
        
        return vc
    }()
    
    lazy var wanInterfaceTableViewController: WanInterfaceTableViewController = {
        let vc = sb.instantiateViewController(withIdentifier: "WanInterfaceTableViewController") as! WanInterfaceTableViewController
        vc.updateDelegate = self
        
        return vc
    }()
    
    lazy var wanStaticIpsViewController: WanStaticIpsViewController = {
        let vc = sb.instantiateViewController(withIdentifier: "WanStaticIpsViewController") as! WanStaticIpsViewController
        vc.updateDelegate = self
        
        return vc
    }()
    
    private let sb = UIStoryboard(name: "WanGatewayConfig", bundle: nil)
    
    @IBOutlet weak var segmentedController: VeeaSegmentedControl!
    @IBOutlet weak private var container: UIView!
    private var viewInContainer: UIViewController?
    
    private var currentSelection: SelectedConfig {
        return SelectedConfig.configForInt(i: segmentedController.selectedSegmentIndex)
    }
    
    private var selectedViewController: UIViewController {
        switch currentSelection {
        case .configuration:
            return gatewayConfigViewController
        case .interfaces:
            return wanInterfaceTableViewController
        case .reservedIps:
            return wanStaticIpsViewController
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        setView()
        if let cvc = viewInContainer as? WanAwareGatewayChildControllerDelegate {
            cvc.childDidBecomeActive()
        }
        
        topConstraint.constant = currentSelection == .configuration ? topConstraintUp : topConstraintDown
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setView() {
        if let vc = viewInContainer {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        
        switch currentSelection {
        case .configuration:
            gatewayConfigViewController.willMove(toParent: self)
            addChild(gatewayConfigViewController)
            gatewayConfigViewController.view.frame = container.bounds
            container.addSubview(gatewayConfigViewController.view)
            gatewayConfigViewController.didMove(toParent: self)
            viewInContainer = gatewayConfigViewController
            
            wanSelector.selectorIsEnabled = false
            return 
        case .interfaces:
            wanInterfaceTableViewController.willMove(toParent: self)
            addChild(wanInterfaceTableViewController)
            wanInterfaceTableViewController.view.frame = container.bounds
            container.addSubview(wanInterfaceTableViewController.view)
            wanInterfaceTableViewController.didMove(toParent: self)
            viewInContainer = wanInterfaceTableViewController
            break
        case .reservedIps:
            wanStaticIpsViewController.willMove(toParent: self)
            addChild(wanStaticIpsViewController)
            wanStaticIpsViewController.view.frame = container.bounds
            container.addSubview(wanStaticIpsViewController.view)
            wanStaticIpsViewController.didMove(toParent: self)
            viewInContainer = wanStaticIpsViewController
            break
        }
        
        wanSelector.selectorIsEnabled = true
    }
    
    @IBAction func applyTapped(_ sender: Any) {
        let dm = HubDataModel.shared
        
        if dm.snapShotInUse && dm.configurationSnapShotItem != nil {
            checkSendWhenSnapshotActive()
            
            return
        }
        
        validateStaticIpChanges { (valid) in
            if valid {
                self.updateGatewayInfo()
            }
        }
    }
    
    func checkSendWhenSnapshotActive() {
        let alert = UIAlertController(title: "Snapshot In Use",
                                      message: "You are using a snapshot. If you are connected to a VeeaHub the snapshot configuration will overwrite the VeeaHub configuration, but this will not be seen until the snapshot is deactivated.\nAre you sure you want to do this.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "Send Update", style: .destructive, handler: { (alert) in
            self.updateGatewayInfo()
        }))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WAN".localized()
        wanSelector.hostVc = self
        setView()
    }
    
    /// Displays the updating UI on the front most view controller
    ///
    /// - Parameter state: The state
    func updateUpdateIndicatorState(state: UpdatingConfigIndicatorView.InidcatorStates) {
        if let vc = selectedViewController as? GatewayConfigViewController {
            vc.updateUpdateIndicatorState(state: state)
        }
        if let vc = selectedViewController as? WanInterfaceTableViewController {
            vc.updateUpdateIndicatorState(state: state)
        }
        if let vc = selectedViewController as? WanStaticIpsViewController {
            vc.updateUpdateIndicatorState(state: state)
        }
    }
}

// MARK: - WAN Static IP Updating
extension WanGatewayTabViewController {
    private func validateStaticIpChanges(valid: (Bool) -> Void) {
        let needsUpdate = wanStaticIpsViewController.vm.needsUpdate
        
        if !needsUpdate {
            valid(true)
            return
        }
        
        if let message = wanStaticIpsViewController.vm.validationErrorMessage {
            showInfoAlert(title: "WAN Reserved IP Error".localized(), message: message)
            valid(false)
            return
        }
        
        valid(true)
    }
    
    private func applyStaticIpChanges() {
        guard let ies = wanStaticIpsViewController.vm.connectedHub,
              let config = wanStaticIpsViewController.vm.updatedConfig else {
                
                // The Reserved IP is not present
                updateUpdateIndicatorState(state: .completeWithSuccess)
                return
        }
        
        if !wanStaticIpsViewController.vm.needsUpdate {
            updateUpdateIndicatorState(state: .completeWithSuccess)
            return
        }
        
        ApiFactory.api.setConfig(connection: ies, config: config) { [weak self] (result, error) in
            if error != nil {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                self?.showErrorUpdatingAlert(error: error!)
                
                return
            }

            HubDataModel.shared.updateConfigInfo(observer: self)
        }
    }
}

// MARK: - Gateway Updating
extension WanGatewayTabViewController {
    
    /// Updates the gateway info then starts an update of the wan interface information
    private func updateGatewayInfo() {
        confirmBackHaulSettings()
    }
    
    private func confirmBackHaulSettings() {
        // Do we need to confirm the changes with the user?
        guard let message = gatewayConfigViewController.buildConfirmationMessage() else {
            self.applyGatewayChanges()
            return
        }
        
        let alert = UIAlertController(title: "Confirm Backhaul Settings".localized(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
            self.gatewayConfigViewController.resetLockChanges()
        }))
        alert.addAction(UIAlertAction(title: "Accept".localized(), style: .destructive, handler: { action in
            self.applyGatewayChanges()
        }))
        
        present(alert, animated: true)
    }
    
    private func applyGatewayChanges() {
        guard let ies = gatewayConfigViewController.connection else {
            return
        }
        
        updateUpdateIndicatorState(state: .uploading)

        if !gatewayConfigViewController.dataModelChanged {
            applyNodeConfigChanges()
            return
        }
        
        ApiFactory.api.setConfig(connection: ies, config: gatewayConfigViewController.vm.gatewayConfig!) {  [weak self] (result, error) in
            NSLog("got result: \(String(describing: result)), error: \(String(describing: error))") // TODO
            
            if error != nil {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                self?.showErrorUpdatingAlert(error: error!)
                
                return
            }
            
            self?.applyNodeConfigChanges()
        }
    }
    
    private func applyNodeConfigChanges() {
        guard let ies = gatewayConfigViewController.connection else {
            return
        }

        // Gateway config
        ApiFactory.api.setConfig(connection: ies,
                                 config: gatewayConfigViewController.vm.nodeConfig!) { [weak self]  (result, error) in
            NSLog("got result: \(String(describing: result)), error: \(String(describing: error))") // TODO
            
            if error != nil {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                self?.showErrorUpdatingAlert(error: error!)
                
                return
            }
            
            self?.updateWanInterfaceInfo()
        }
    }
}

// MARK: - Wan Interface Updating
extension WanGatewayTabViewController {
    
    /// Updates the wan interface info
    private func updateWanInterfaceInfo() {
        if wanInterfaceTableViewController.shouldUpdate() {
            sendWanInterfaceUpdate()
        }
        else {
            applyStaticIpChanges()
        }
    }
    
    private func sendWanInterfaceUpdate() {
        guard let ies = wanInterfaceTableViewController.connection,
              let config = wanInterfaceTableViewController.getNodeWanConfig() else {
                applyStaticIpChanges()
                
                return
        }
        
        ApiFactory.api.setConfig(connection: ies, config: config) { [weak self]  (result, error) in
            if error != nil {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                self?.showErrorUpdatingAlert(error: error!)
                
                return
            }
            
            self?.applyStaticIpChanges()
        }
    }
}

// MARK: - GatewayViewControllerUpdateDelegate
extension WanGatewayTabViewController: WanGatewayTabViewControllerDelegate {
    var selectedWan: Int {
        get { return currentWan }
        set {
            currentWan = newValue
            if let cvc = viewInContainer as? WanAwareGatewayChildControllerDelegate {
                cvc.wanDidChange(wan: currentWan)
            }
        }
    }
    
    func viewControllersDataSetChanged(viewController: UIViewController) {
        var changed = false
        if gatewayConfigViewController.dataModelChanged { changed = true }
        if wanInterfaceTableViewController.dataModelChanged { changed = true }
        if wanStaticIpsViewController.dataModelChanged { changed = true }
        
        applyButtonIsHidden = !changed
    }
}

extension WanGatewayTabViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}
