//
//  DefaultWifiViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 05/02/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

protocol DefaultWifiViewControllerDelegate: AnyObject {
    func didSelectSsidName(name: String, password: String,ssid_2_4:String,password_2_4: String,ssid_5:String,password_5: String,optedBothBool:Bool)
    func userDidSkip()
    func userDidSetDefaultWifiPassword(name: String, password: String,ssid_2_4:String,password_2_4: String,ssid_5:String,password_5: String,optedBothBool:Bool)
}

class DefaultWifiViewController: VUIViewController, AnalyticsScreenViewEventProtocol {
    var screenName: AnalyticsEvents.ScreenNames = .enterprise_onboarding_screen

    @IBOutlet weak var switchContainer: UIView!
    let model = DefaultWifiViewModel()
    
    weak var delegate: DefaultWifiViewControllerDelegate?
    weak var delegateForEnrollmentData: DefaultWifiViewControllerDelegate?

    @IBOutlet private weak var continueButtonHolder: UIView!
    private var continueButton: VUIFlatButton!
    @IBOutlet private weak var skipButton: UIButton!

    @IBOutlet weak var titleLabel_2GHZ: UILabel!
    @IBOutlet weak var titleLabel_5GHZ: UILabel!
    
    @IBOutlet weak var ssidNameField: CurvedTextEntryField!
    @IBOutlet weak var passwordField: CurvedTextEntryField!
    @IBOutlet weak var passwordConfirmField: CurvedTextEntryField!
    
    @IBOutlet weak var nameValidationErrorLabel: UILabel!
    @IBOutlet weak var passwordValidationErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordValidationErrorLabel: UILabel!
    
    @IBOutlet weak var ssidNameField_5GHZ: CurvedTextEntryField!
    @IBOutlet weak var passwordField_5GHZ: CurvedTextEntryField!
    @IBOutlet weak var passwordConfirmField_5GHZ: CurvedTextEntryField!
    
    @IBOutlet weak var nameValidationErrorLabel_5GHZ: UILabel!
    @IBOutlet weak var passwordValidationErrorLabel_5GHZ: UILabel!
    @IBOutlet weak var confirmPasswordValidationErrorLabel_5GHZ: UILabel!
    
    @IBOutlet weak var stackView_5GHZ: UIStackView!
    @IBOutlet weak var networkToggleSwitch: UISwitch!
    
    private var optedForBothNetworksBool = true
    private var allErrorLabels: [UILabel] {
        return [nameValidationErrorLabel,
                passwordValidationErrorLabel,
                confirmPasswordValidationErrorLabel,
                nameValidationErrorLabel_5GHZ,
                passwordValidationErrorLabel_5GHZ,
                confirmPasswordValidationErrorLabel_5GHZ
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpContinueButton()
        setUpTextFields()
        networkToggleChangedFor5GHZ(networkToggleSwitch)
        skipButton.accessibility(config: AccessibilityConfigurations.buttonSkipSettingWifiPassword)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordScreenAppear()
    }
    
    @IBAction func networkToggleChangedFor5GHZ(_ sender: UISwitch) {
       
        if sender.isOn {
            stackView_5GHZ.isHidden = true
            titleLabel_5GHZ.isHidden = true
            titleLabel_2GHZ.text = "2.4 / 5 GHz Networks"
            optedForBothNetworksBool = true
        }
        else {
            stackView_5GHZ.isHidden = false
            titleLabel_5GHZ.isHidden = false
            titleLabel_2GHZ.text = "2.4 GHz Network"
            optedForBothNetworksBool = false
        }
    }

    private func setUpContinueButton() {
        continueButtonHolder.backgroundColor = UIColor.clear

        continueButton = VUIFlatButton(frame: CGRect.zero,
                                       type: .green,
                                       title: "Continue".localized())

        continueButton.addAndPinToEdgesOf(outerView: continueButtonHolder)
        continueButton.addTarget(self, action: #selector(DefaultWifiViewController.continueTapped), for: .touchUpInside)
    }

    @objc private func continueTapped() {

        let result = model.validateFields(ssid: ssidNameField,
                                          password: passwordField,
                                          confirm: passwordConfirmField,
                                          ssid_5: ssidNameField_5GHZ,
                                          password_5: passwordField_5GHZ,
                                          confirm_5: passwordConfirmField_5GHZ,optedForBoth: self.optedForBothNetworksBool)

        if !result.0 {
            let controller = UIAlertController(title: "Error".localized(),
                                               message: result.1,
                                               preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: nil))
            present(controller, animated: true, completion: nil)

            return
        }
        if self.optedForBothNetworksBool {
            
            delegate?.didSelectSsidName(name: ssidNameField.textField.text ?? "", password: passwordField.textField.text ?? "", ssid_2_4: "", password_2_4: "", ssid_5: "", password_5: "",optedBothBool:self.optedForBothNetworksBool)
            
        }
        else {
            delegate?.didSelectSsidName(name: "", password: "", ssid_2_4: ssidNameField.textField.text ?? "", password_2_4: passwordField.textField.text ?? "", ssid_5: ssidNameField_5GHZ.textField.text ?? "", password_5: passwordField_5GHZ.textField.text ?? "",optedBothBool:self.optedForBothNetworksBool)
        }

    }

    private func setUpTextFields() {
        skipButton.titleLabel?.font = FontManager.medium(size: 18.0)
        
        if let enrollmentFlowCord = delegateForEnrollmentData as? EnrollmentFlowCoordinator {
            let hubType = enrollmentFlowCord.enrollmentData.hardwareModel
            if hubType == .vhc05 {
                switchContainer.isHidden = true
                titleLabel_2GHZ.text = "2.4 GHz Network"
            }
            else {
                switchContainer.isHidden = false
                titleLabel_2GHZ.text = "2.4 / 5 GHz Networks"
            }
        }
        
        ssidNameField.setValues(title: model.ssidFieldTitle1, placeHolder: model.ssidFieldPlaceHolder1, keyboardType: .emailAddress, tag: 1, validatorType: SsidNameValidator(),isSecured: false)
        ssidNameField.textField.delegate = self
        ssidNameField.textField.addTarget(self, action: #selector(editingChanged(sender:)), for: .editingChanged)
        
        passwordField.setValues(title: model.passwordFieldTitle1, placeHolder: model.ssidFieldPlaceHolder1, keyboardType: .default, tag: 2, validatorType: SsidPasswordNameValidator(),isSecured: true)
        passwordField.textField.delegate = self
        passwordField.textField.addTarget(self, action: #selector(editingChanged(sender:)), for: .editingChanged)
        
        passwordConfirmField.setValues(title: model.confirmPasswordFieldTitle1, placeHolder: model.confirmPasswordFieldTitle1, keyboardType: .default, tag: 3, validatorType: SsidPasswordNameValidator(),isSecured: true)
        passwordConfirmField.textField.delegate = self
        passwordConfirmField.textField.addTarget(self, action: #selector(editingChanged(sender:)), for: .editingChanged)
        
        ssidNameField_5GHZ.setValues(title: model.ssidFieldTitle1, placeHolder: model.ssidFieldPlaceHolder1, keyboardType: .emailAddress, tag: 4, validatorType: SsidNameValidator(),isSecured: false)
        ssidNameField_5GHZ.textField.delegate = self
        ssidNameField_5GHZ.textField.addTarget(self, action: #selector(editingChanged(sender:)), for: .editingChanged)
        
        passwordField_5GHZ.setValues(title: model.passwordFieldTitle1, placeHolder: model.ssidFieldPlaceHolder1, keyboardType: .default, tag: 5, validatorType: SsidPasswordNameValidator(),isSecured: true)
        passwordField_5GHZ.textField.delegate = self
        passwordField_5GHZ.textField.addTarget(self, action: #selector(editingChanged(sender:)), for: .editingChanged)
        
        passwordConfirmField_5GHZ.setValues(title: model.confirmPasswordFieldTitle1, placeHolder: model.ssidFieldPlaceHolder1, keyboardType: .default, tag: 6, validatorType: SsidPasswordNameValidator(),isSecured: true)
        passwordConfirmField_5GHZ.textField.delegate = self
        passwordConfirmField_5GHZ.textField.addTarget(self, action: #selector(editingChanged(sender:)), for: .editingChanged)

   }
    
    @IBAction private func skipTapped(_ sender: Any) {
        // Show a dialog to confirm the selection
        let alert = UIAlertController.init(title: nil,
                                           message: "If you choose to skip setting up WiFi, the default WiFi network will not be configured. Would you like to proceed?".localized(),
                                           preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel))
        
        alert.addAction(UIAlertAction.init(title: "Yes".localized(), style: .default, handler: { (action) in
            self.delegate?.userDidSkip()
        }))
        
        present(alert, animated: true, completion: nil)
       
    }
    
    @IBAction func setDefaultWifiCredentialsTapped(_ sender: Any) {
        let password = PasswordGenerator().newPassword()
        delegate?.userDidSetDefaultWifiPassword(name: "", password: password, ssid_2_4: "", password_2_4: "", ssid_5: "", password_5: "",optedBothBool:false)
    }
    
    @objc func editingChanged(sender: UITextField) {
        validateWhileTextChange(sender: sender)
    }
    
    func validateWhileTextChange(sender:UITextField) {
        
        var validatorOfCurrentField : StringValidator?
        var validationResult : SuccessAndOptionalMessage?
        var textFieldstr = ""
        if sender.tag == 1 || sender.tag == 4 { //SSID FIELDS OF 2.4 and 5 GHZ
            validatorOfCurrentField = SsidNameValidator()
            guard let str = sender.text else {
                return
            }
            textFieldstr = str
            validationResult = validatorOfCurrentField?.validate(str: textFieldstr)
        }
        else if sender.tag == 2 || sender.tag == 5 { //PASS FIELDS OF 2.4 and 5 GHZ
            validatorOfCurrentField = SsidPasswordNameValidator()
            guard let str = sender.text else {
                return
            }
            textFieldstr = str
            validationResult = validatorOfCurrentField?.validate(str: textFieldstr)
        }
        else{
            validatorOfCurrentField = SsidConfirmPasswordNameValidator()
            guard let str = sender.text else {
                return
            }
            textFieldstr = str
            if sender.tag == 3 {
                if textFieldstr != passwordField.textField.text {
                    validationResult = (false, "Please check that passwords match.".localized())
                }
                else {
                    validationResult = (true, nil)
                }
            }
            else if sender.tag == 6 {
                if textFieldstr != passwordField_5GHZ.textField.text {
                    validationResult = (false, "Please check that passwords match.".localized())
                }
                else {
                    validationResult = (true, nil)
                }
            }
            
        }
    
        guard let success = validationResult?.0 else { return  }
        if !success {
            guard let message = validationResult?.1 else {
                return
            }
            for label in allErrorLabels {
                label.isHidden = true
                if label.tag == sender.tag {
                    label.isHidden = false
                    label.text = message
                }
            }
        }
        else {
            for label in allErrorLabels {
                label.isHidden = true
            }
        }
    }
}

extension DefaultWifiViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

