//
//  RouterConfigViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 27/04/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit


class RouterConfigViewController: BaseConfigViewController, HubInteractionFlowControllerProtocol, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .router_settings_screen

    var flowController: HubInteractionFlowController?
    private let vm = RouterViewModel()
    private let pickerExpandedHeight: CGFloat = 160

    // MARK: - IBOutlets

    // MARK: Wan Settings
    
    @IBOutlet weak var inlineHelpView: InlineHelpView!
    
        
    @IBOutlet var scrollView: UIScrollView!
    
    // MARK: WLan Settings

    @IBOutlet weak var accessControlSegmentedController: UISegmentedControl!
    @IBOutlet weak var macAddressStackView: UIStackView!
    
    // MARK: Lan Settings
    
    
    // MARK: - Methods
    
    private func updateChangeState() {
        applyButtonIsHidden = !configChanged()
    }
    
    override func applyConfig() {
        
        if sendingUpdate == true { return }
        
        if vm.acceptListChanged || vm.denyListChanged {
            let alert = UIAlertController(title: "Access Control Changed".localized(),
                                         message: "The access control lists have changed. You will need to reboot before these changes can take effect".localized(),
                                         preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Send Update".localized(), style: .default, handler: { (alert) in
                if self.configChanged() {
                    self.sendChanges()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        if configChanged() {
            sendChanges()
        }
    }
    
    private func configChanged() -> Bool {
        guard let rConfig = vm.routerConfig else {
                return false
        }
        
        if vm.acceptListChanged || vm.denyListChanged {
            return true
        }
        
        return false
    }
    
    fileprivate func sendChanges() {
        sendingUpdate = true
        updateUpdateIndicatorState(state: .uploading)
        
        vm.applyUpdate { [weak self] (message, error) in
            self?.sendingUpdate = false
            
            if error != nil {
                self?.updateUpdateIndicatorState(state: .completeWithError)
                self?.showErrorUpdatingAlert(error: error!)
                
                return
            }
            
            HubDataModel.shared.updateConfigInfoAfterDelay(observer: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Access Control".localized()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        applyButtonIsHidden = true
        
        inlineHelpView.setText(labelText: "This screen shows configurations relating to: Connecting to a router on the WAN and Access control for devices on wireless APs.".localized())
        inlineHelpView.observerTaps {
            self.pushToHelp()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    private func pushToHelp() {
        displayHelpFile(file: .router, push: true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){

        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset.bottom = keyboardFrame.size.height + 20
    }

    @objc func keyboardWillHide(notification:NSNotification){

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    override func done(_ sender: Any) {
        updateMacAddressDataModels()
        super.done(sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupWAN()
        setupWLAN()
    }
    
    @IBAction func accessControlSelectionChanged(_ sender: Any) {
        
        // Dont use the update method as by this point the selection
        var updatedStrings = [String]()
        for view in macAddressStackView.arrangedSubviews {
            if let macAddressView = view as? MacAddressEntryTextView {
                //print(macAddressView.macAddress)
                if macAddressView.macAddress.count == 17 {
                    updatedStrings.append(macAddressView.macAddress)
                }
            }
        }
        
        if accessControlSegmentedController.selectedSegmentIndex == 0 {
            vm.denyMacList = updatedStrings
        }
        else {
            vm.acceptMacList = updatedStrings
        }
        populateMacAddresses()
        
        updateChangeState()
    }
    
    @IBAction func addMacAddress(_ sender: Any) {
        insertNewMacAddress()
        updateChangeState()
    }
}

// MARK: - WAN

extension RouterConfigViewController {
    fileprivate func setupWAN() {
        guard let config = vm.routerConfig else {
            return
        }
    }
}

// MARK: - WLAN

extension RouterConfigViewController {
    fileprivate func setupWLAN() {
        populateMacAddresses()
    }
    
    private func populateMacAddresses() {
        macAddressStackView.removeAllArrangedSubviews()
        
        guard let macAddresses = accessControlSegmentedController.selectedSegmentIndex == 0 ? vm.acceptMacList : vm.denyMacList else {
            return
        }
        
        for macAddress in macAddresses {
            let macAddressView = MacAddressEntryTextView.init(frame: CGRect.zero)
            macAddressView.macAddress = macAddress
            macAddressView.delegate = self
            macAddressView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            macAddressView.backgroundColor = UIColor.red

            macAddressStackView.insertArrangedSubview(macAddressView, at: macAddressStackView.arrangedSubviews.count)
        }
    }
    
    private func insertNewMacAddress() {
        if accessControlSegmentedController.selectedSegmentIndex == 0 {
            // Accept list
            vm.acceptMacList?.append("")
            populateMacAddresses()
        }
        else {
            // Deny list
            vm.denyMacList?.append("")
            populateMacAddresses()
        }
    }
    
    fileprivate func updateMacAddressDataModels() {
        var updatedStrings = [String]()
        for view in macAddressStackView.arrangedSubviews {
            if let macAddressView = view as? MacAddressEntryTextView {
                //print(macAddressView.macAddress)
                if macAddressView.macAddress.count == 17 {
                    updatedStrings.append(macAddressView.macAddress)
                }
            }
        }
        
        if accessControlSegmentedController.selectedSegmentIndex == 0 {
            vm.acceptMacList = updatedStrings
        }
        else {
            vm.denyMacList = updatedStrings
        }
    }
}

// MARK: - LAN
extension RouterConfigViewController: MacAddressTextViewProtocol {
    func entryCompleted(completedView: MacAddressEntryTextView) {
        updateMacAddressDataModels()
    }
    
    func entryWasDeleted(deletedView: MacAddressEntryTextView) {
        macAddressStackView.removeArrangedSubview(deletedView, shouldRemoveFromSuperview: true)
        updateMacAddressDataModels()
    }
}

extension RouterConfigViewController: UITextFieldDelegate {    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension RouterConfigViewController: TitledTextFieldDelegate {
    func textDidChange(sender: TitledTextField) {
        updateChangeState()
    }
}

extension RouterConfigViewController: TitledPasswordFieldDelegate {
    func textDidChange(sender: TitledPasswordField) {
        updateChangeState()
    }
    
    
}

extension RouterConfigViewController: ExpandingPickerViewDelegate {
    func didSelectRow(row: Int, inComponent component: Int) {
        updateChangeState()
    }
}

extension RouterConfigViewController: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        updateUpdateIndicatorState(state: .completeWithSuccess)
    }
    
    func updateDidProgress(progress: Float, message: String?) {}
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    func removeArrangedSubview(_ view: UIView, shouldRemoveFromSuperview: Bool) {
        removeArrangedSubview(view)
        if shouldRemoveFromSuperview {
            view.removeFromSuperview()
        }
    }
}
