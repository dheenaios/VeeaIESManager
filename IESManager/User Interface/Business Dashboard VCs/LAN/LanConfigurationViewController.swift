//
//  LanConfigurationViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 23/07/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

protocol LanConfigurationParentDelegate: AnyObject {
    var selectedLan: Int { get set }
    var viewModel: LanConfigurationViewModel { get }
    
    /// The child tells the parent that there has been a change in its state
    /// returns true if the user has made a change that can be sent to the hub
    func childUpdateStateChanged(updated: Bool)

    func removeUpdatingUI()
}

protocol LanConfigurationChildViewControllerProtocol: BaseConfigViewController {
    var hasUpdated: Bool { get }
    func childDidBecomeActive()
    func childDidUpdateSelectedLan(lan: Int)

    // Are the entries valid. This method should also handle telling the user
    func entriesAreValid() -> Bool
    
    /// Should a restart warning be shown before proceeding?
    func shouldShowRestartWarning() -> Bool
    
    // Tell the child to send its information
    func sendUpdate(completion: @escaping BaseConfigViewModel.CompletionDelegate)
    
    func returnErrorMessage() -> String?
}

class LanConfigurationViewController: BaseConfigViewController, HubInteractionFlowControllerProtocol {
    var flowController: HubInteractionFlowController?

    private enum SelectedConfig: Int {
        case configuration = 0
        case interface = 1
        case reservedIps = 2
        case staticIps = 3
    }

    private var vm: LanConfigurationViewModel!
    private var currentLan = 0
    @IBOutlet weak var segmentedControl: VeeaSegmentedControl!
    @IBOutlet weak var containerView: UIView!
    private var viewInContainer: LanConfigurationChildViewControllerProtocol?
    //private let sb = UIStoryboard(name: "LanConfiguration", bundle: nil)
    
    // MARK: - Child View Controllers

    // Config Tab
    private lazy var lanMeshViewController: LanConfigurationChildViewControllerProtocol = {
        LanMeshViewController.new(delegate: self, parentVm: vm)
    }()

    // LAN IP tab
    private lazy var dhcpViewController: LanConfigurationChildViewControllerProtocol = {
        DhcpViewController.new(delegate: self, parentVm: vm)
    }()

    // Reserved IPs tab
    private lazy var staticIpViewController: LanConfigurationChildViewControllerProtocol = {
        LanReservedIPsViewController.new(delegate: self, parentVm: vm)
    }()

    // Static IPs tab
    private lazy var lanStaticIpViewController: LanConfigurationChildViewControllerProtocol = {
        LanStaticIpViewController.new(delegate: self, parentVm: vm)
    }()
    
    // MARK: - Private Methods and Vars
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let vm = LanConfigurationViewModel() { self.vm = vm }
        else {
            self.navigationController?.popViewController(animated: true)
            showErrorInfoMessage(message: "Error: View could not be populated")
            return
        }

        // Reduce the font size if this is an iPhone SE Gen 1 or similar
        if self.view.frame.size.width < 321 {
            segmentedControl.smallPhoneConfiguration()
        }

        setView()
        applyButtonIsHidden = true
        deleteSegementsAsRequired()
        
        title = "LAN".localized()
    }
    
    private func deleteSegementsAsRequired() {
        let m = HubDataModel.shared
        if m.isMN {
            segmentedControl.removeSegment(at: 2, animated: false)
            segmentedControl.removeSegment(at: 1, animated: false)
        }

        let usesSomeIpModeTable = m.baseDataModel?.nodeCapabilitiesConfig?.usesSomeIpModeTable ?? false
        if !usesSomeIpModeTable {
            segmentedControl.removeLastSegment() // Static IPs
        }
    }
    
    private var currentSelection: SelectedConfig {
        return SelectedConfig(rawValue: segmentedControl.selectedSegmentIndex) ?? SelectedConfig.configuration
    }
    
    @IBAction func segmentedControllerChanged(_ sender: Any) {
        setView()
    }
    
    private func setView() {
        if let vc = viewInContainer {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        
        switch currentSelection {
        case .configuration:
            lanMeshViewController.willMove(toParent: self)
            addChild(lanMeshViewController)
            lanMeshViewController.view.frame = containerView.bounds
            containerView.addSubview(lanMeshViewController.view)
            lanMeshViewController.didMove(toParent: self)
            viewInContainer = lanMeshViewController

            if let analyticsVc = lanMeshViewController as? AnalyticsScreenViewEventProtocol {
                analyticsVc.recordScreenAppear()
            }

            break
        case .interface:
            dhcpViewController.willMove(toParent: self)
            addChild(dhcpViewController)
            dhcpViewController.view.frame = containerView.bounds
            containerView.addSubview(dhcpViewController.view)
            dhcpViewController.didMove(toParent: self)
            viewInContainer = dhcpViewController

            if let analyticsVc = dhcpViewController as? AnalyticsScreenViewEventProtocol {
                analyticsVc.recordScreenAppear()
            }

            break
        case .reservedIps:
            staticIpViewController.willMove(toParent: self)
            addChild(staticIpViewController)
            staticIpViewController.view.frame = containerView.bounds
            containerView.addSubview(staticIpViewController.view)
            staticIpViewController.didMove(toParent: self)
            viewInContainer = staticIpViewController

            if let analyticsVc = staticIpViewController as? AnalyticsScreenViewEventProtocol {
                analyticsVc.recordScreenAppear()
            }

            break
        case .staticIps:
            lanStaticIpViewController.willMove(toParent: self)
            addChild(lanStaticIpViewController)
            lanStaticIpViewController.view.frame = containerView.bounds
            containerView.addSubview(lanStaticIpViewController.view)
            lanStaticIpViewController.didMove(toParent: self)
            viewInContainer = lanStaticIpViewController
        }
        
        viewInContainer?.childDidBecomeActive()
    }
    
    private func checkUpdateState(updated:Bool) {
        
        applyButtonIsHidden = true
        if updated {
            applyButtonIsHidden = false
        }
    }

    private func checkUpdateState() {
        var vcs = [staticIpViewController, lanMeshViewController, dhcpViewController, lanStaticIpViewController]

        if !vm.supportsBackpack { vcs.removeLast() }

        if validationIssues() {
            applyButtonIsHidden = true
            return
        }
        
        for vc in vcs {
            if vc.hasUpdated {
                applyButtonIsHidden = false
                return
            }
        }
        
        applyButtonIsHidden = true
    }
    
    override func applyConfig() {
        if validationIssues() {
            return
        }
        if showRestartWarning() {
            displayRestartRequiredWarning(customMessage: "You will need to restart your Veea Hub for settings to take effect".localized()) { (success) in
                if success { self.send() }
            }
        }
        else { send() }
    }
    
    private func send() {
        var vcs = [staticIpViewController, lanMeshViewController, dhcpViewController, lanStaticIpViewController]

        if !vm.supportsBackpack {
            vcs.removeLast()
        }

        var itemsToUpdate = 0
        
        for vc in vcs {
            if vc.hasUpdated { itemsToUpdate += 1 }
        }
        
        if itemsToUpdate == 0 {
            navigationController?.popViewController(animated: true)
            return
        }

        if self.validationIssues() {
            return
        }
        
        if lanMeshViewController.returnErrorMessage() != nil {
            showAlert(with: "Validation Error".localized(), message: lanMeshViewController.returnErrorMessage() ?? "Config Page Error")
            return
        }
        
        if lanStaticIpViewController.returnErrorMessage() != nil {
            showAlert(with: "Validation Error".localized(), message: lanStaticIpViewController.returnErrorMessage() ?? "Static IP Error")
            return
        }
        
        
        
        self.applyButtonIsHidden = true
        var itemsUpdated = 0
        
        self.sendingUpdate = true
        self.updateUpdateIndicatorState(state: .uploading)

        if lanMeshViewController.hasUpdated {
            lanMeshViewController.sendUpdate { message, error in
                itemsUpdated += 1
                if itemsUpdated == itemsToUpdate {
                    self.completedUpdate(error: error)
                }
            }
        }
        
        if dhcpViewController.hasUpdated {
            dhcpViewController.sendUpdate { message, error in
                itemsUpdated += 1
                if itemsUpdated == itemsToUpdate {
                    self.completedUpdate(error: error)
                }
            }
        }
        
        if staticIpViewController.hasUpdated {
            staticIpViewController.sendUpdate { message, error in
                itemsUpdated += 1
                if itemsUpdated == itemsToUpdate {
                    self.completedUpdate(error: error)
                }
            }
        }

        if vm.supportsBackpack {
            if lanStaticIpViewController.hasUpdated {
                lanStaticIpViewController.sendUpdate { message, error in
                    itemsUpdated += 1
                    if itemsUpdated == itemsToUpdate {
                        self.completedUpdate(error: error)
                    }
                }
            }
        }
    }
    
    private func showRestartWarning() -> Bool {
        if lanMeshViewController.shouldShowRestartWarning() ||
            dhcpViewController.shouldShowRestartWarning() ||
            staticIpViewController.shouldShowRestartWarning() ||
            lanStaticIpViewController.shouldShowRestartWarning() {
            return true
        }
        
        return false
    }
    
    private func validationIssues() -> Bool {
        if (!dhcpViewController.entriesAreValid() ||
            !staticIpViewController.entriesAreValid() ||
            !lanStaticIpViewController.entriesAreValid()) ||
            (!lanMeshViewController.entriesAreValid()) {
            return true
        }
        
        return false
    }
    
    private func completedUpdate(error: APIError?) {
        sendingUpdate = false
        
        if error != nil {
            self.updateUpdateIndicatorState(state: .completeWithError)
            self.showErrorUpdatingAlert(error: error!)
            applyButtonIsHidden = false
            
            return
        }
        
        HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
    }
}

extension LanConfigurationViewController: LanConfigurationParentDelegate {
    func removeUpdatingUI() {
        removeUpdateIndicator()
    }

    var viewModel: LanConfigurationViewModel { vm }

    func childUpdateStateChanged(updated: Bool) {
        checkUpdateState(updated: updated)
    }
    
    var selectedLan: Int {
        get { return currentLan }
        set { currentLan = newValue }
    }
}

// MARK: - HubDataModelProgressDelegate
extension LanConfigurationViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        if !success {
            updateUpdateIndicatorState(state: .completeWithError)
            nonFatalConnectionIssue(message: message ?? "")
        }
        
        updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}
