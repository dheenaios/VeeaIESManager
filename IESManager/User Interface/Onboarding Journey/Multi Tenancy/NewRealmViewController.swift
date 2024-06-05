//
//  NewRealmViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 26/11/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class NewRealmViewController: UIViewController {
    
    let vm = NewRealmViewModel()
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addOrgButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var textFieldView: UIView!
    
    var loginflowDelegate: LoginFlowCoordinatorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Organization".localized()

        addOrgButton.layer.cornerRadius = 5.0
        addOrgButton.layer.masksToBounds = true
        addOrgButton.accessibility(config: AccessibilityConfig(label: "Add Organization", identifier: "add_org_button"))
        
        warningLabel.isHidden = true
        textField.backgroundColor = UIColor.init { (trait) -> UIColor in
            return trait.userInterfaceStyle == .dark ? .gray : .white
        }
        textFieldView.backgroundColor = textField.backgroundColor
    }
    
    @IBAction func addActionTapped(_ sender: Any) {
        validateEntry()
    }
    
    private func validateEntry() {
        warningLabel.isHidden = true
        if let error = vm.validateEntry(entry: textField.text) {
            warningLabel.text = error
            warningLabel.isHidden = false
            
            return
        }
        
        addRealmAndShowLogin(realmName: textField.text!)
    }
    
    private func addRealmAndShowLogin(realmName: String) {
        guard let realm = vm.addRealmFrom(entry: realmName) else {
            warningLabel.isHidden = false
            warningLabel.text = "Error getting realm details".localized()
            return
        }
        
        VeeaRealmsManager.selectedRealm = realm.name
        AuthorisationManager.shared.reset()
        AuthorisationManager.shared.delegate = self
        AuthorisationManager.shared.discoverConfiguration()
    }
}

extension NewRealmViewController: AuthorisationDelegate {
    func configDiscoveryCompleted(success: (SuccessAndOptionalMessage)) {
        if !success.0 {
            showErrorInfoMessage(message: success.1 ?? "No info".localized())
            return
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        AuthorisationManager.shared.requestLogin(hostViewController: self,
                                                 authFlowSessionManager: appDelegate)
    }
    
    func loginRequestResult(success: (SuccessAndOptionalMessage)) {
        if !success.0 {
            showErrorInfoMessage(message: success.1 ?? "\("Log in failed because".localized()) \(success.1 ?? "of an unknown issue".localized())")
            return
        }
        
        self.loginflowDelegate?.loginComplete()
    }
    
    func gotUserInfoResult(success: (Bool, String?, VHUser?)) {}
}
