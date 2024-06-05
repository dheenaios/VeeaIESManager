//
//  BaseConfigViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 27/04/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit


class BaseConfigViewController: UIViewController {
    /// Set to true to bypass users apply tap
    var doNotSend = false
    
    var colorManager = InterfaceManager.shared.cm
    
    var veeaHubConnection: HubConnectionDefinition? = {
        return HubDataModel.shared.connectedVeeaHub
    }()
    
    lazy var updateIndicator: UpdatingConfigIndicatorView = {
        let indicator = UpdatingConfigIndicatorView(frame: view.bounds)
        indicator.alpha = 0.0
        indicator.isUserInteractionEnabled = false
        view.addSubview(indicator)
        
        return indicator
    }()
    
    var sendingUpdate: Bool = false
    
    var iesDataModel: HubDataModel = HubDataModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        self.becomeFirstResponder()
        logScreenName()
        
        setTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButtonHidden(false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    func setTheme() {
        // Update the navbar globally and locally
        updateNavBarWithDefaultColors()
        // To be implemented in the subclass
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            showTestersMenu()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        if doNotSend {
            cancel(sender)
            return
        }
        
        confirmSSID { [weak self]  (shouldSend) in
            if shouldSend {
                let dm = HubDataModel.shared
                
                if dm.snapShotInUse && dm.configurationSnapShotItem != nil {
                    self?.checkSendWhenSnapshotActive()
                    return
                }
                
                self?.applyConfig()
            }
        }
    }
    
    func checkSendWhenSnapshotActive() {
        let alert = UIAlertController(title: "Snapshot In Use",
                                      message: "You are using a snapshot. If you are connected to a VeeaHub the snapshot configuration will overwrite the VeeaHub configuration, but this will not be seen until the snapshot is deactivated.\nAre you sure you want to do this.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "Send Update", style: .destructive, handler: { (alert) in
            self.applyConfig()
        }))
        self.present(alert, animated: true)
    }
    
    func dismissCard() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func applyConfig() {
        fatalError("This method must be implemented by a subclass")
    }
    
    func nonFatalConnectionIssue(message: String) {
        // Show a dialog. Offer the chance to retry.
        // Ok.
        
        let controller = UIAlertController.init(title: "Error getting VeeaHub Configuration".localized(),
                                                message: "\("Update as successful, but there was an issue getting updated information from the hub".localized()): \(message). \r\("Tap refresh when you are returned to the Dashboard".localized()).",
                                                preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "OK".localized(), style: .default) { (alert) in
            self.dismiss(animated: true, completion: nil)
        }
        
        controller.addAction(ok)
        present(controller, animated: true, completion: nil)
    }
}

extension BaseConfigViewController {
    // MARK: - Show uploading view
    func updateUpdateIndicatorState(state: UpdatingConfigIndicatorView.InidcatorStates) {
        switch state {
        case .uploading:
            backButtonHidden(true)
        default:
            backButtonHidden(false)
        }
        
        updateIndicator.updateIndicator(state: state, host: self)
    }
    
    func removeUpdateIndicator() {
        backButtonHidden(false)
        updateIndicator.updateIndicator(state: .completeWithError, host: self)
    }
}

extension BaseConfigViewController: UpdatingConfigIndicatorViewDelegate {
    func indicatorViewTimedOutUserRequestTryAgain() {
        backButtonHidden(false)
        
        if veeaHubConnection?.connectionRoute == .CURRENT_GATEWAY && WiFiHelpers.getDeviceSSID() == nil{
            let alert = UIAlertController(title: "No Network Connection".localized(),
                                          message: "The update succeeded. However, the Wi-Fi connection has been reset due to the configuration change. Please reconnect to your VeeaHub.".localized(),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { alert in
                self.handleFail()
            }))
            
            return
        }
        
        let alert = UIAlertController(title: "Connection Issue".localized(),
                                      message: "The update was applied, but the VeeaHub became uncommunicative".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Try Again".localized(), style: .default, handler: { alert in
            self.getModel()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func getModel() {
        updateIndicator.updateIndicator(state: .uploading, host: self)
        updateIndicator.labelText = "Getting Veeahub Config".localized()
        
        // Get the update
        HubDataModel.shared.updateConfigInfo { [weak self] success, progress, message in
            if success && progress == 1.0 {
                self?.updateIndicator.updateIndicator(state: .completeWithSuccess, host: self)
            }
            else if !success {
                self?.updateIndicator.updateIndicator(state: .completeWithError, host: self)
                
                let alert = UIAlertController(title: "Error".localized(),
                                              message: "Could not get configuration. Please check your connection".localized(),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { alert in
                    self?.handleFail()
                }))
                
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func handleFail() {
        guard let vcs = navigationController?.viewControllers else { return }
        for vc in vcs {
            if vc.isKind(of: MeshDetailViewController.self) {
                navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
}
