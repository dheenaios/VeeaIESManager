//
//  LoginViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 15/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class LoginViewController: OnboardingBaseViewController {

    let termsUrl = "https://go.veea.com/tos/"
    let privacyUrl = "https://go.veea.com/privacy/"
    
    var loginflowDelegate: LoginFlowCoordinatorDelegate?
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var smallLogo: UIImageView!
    @IBOutlet weak var headline1: UILabel!
    @IBOutlet weak var headline2: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var loginButton: CurvedButton!
    
    @IBOutlet weak var legalLabelContainerView: UIView!
    @IBOutlet weak var legalTopLine: UIStackView!
    @IBOutlet weak var legalBottomLine: UIStackView!
    
    let vm = UserTypeViewModel()
    
    static func new() -> LoginViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomeUserLogin.rawValue, bundle: nil).instantiateInitialViewController() as! LoginViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLegalTextView()
        hideNavBar = true

        loginButton.accessibility(config: AccessibilityConfigurations.loginOrSignUpButton)
        
        self.becomeFirstResponder()
        if BackEndEnvironment.internalBuild {
            showInfoAlert(title: "Internal Testing", message: "Shake the device for tester options")
        }
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            showTestersMenu()
        }
    }
    
    override func setTheme() {
        super.setTheme()
        
        smallLogo.image = smallLogo.image?.withRenderingMode(.alwaysTemplate)
        smallLogo.tintColor = cm.text3.colorForAppearance
        
        topView.backgroundColor = cm.loginSplashScreenBackground.colorForAppearance
        bottomView.backgroundColor = cm.background1.colorForAppearance
        
        headline1.textColor = cm.text1.colorForAppearance
        headline2.textColor = cm.text1.colorForAppearance
        
        loginButton.backgroundColor = cm.themeTint.colorForAppearance
        loginButton.setTitleColor(cm.textWhite.colorForAppearance, for: .normal)
        loginButton.titleLabel?.font = FontManager.bigButtonText
    }
    
    // Called after the user changes appearance mode. Update the appearance
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideBack = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideNavBar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavBar = false
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        AnalyticsEventHelper.recordUserLoginStart()

        Task {
            if await vm.isInMaintainanceMode() {
                return
            }

            if Target.currentTarget.isHomeBuild {
                runHomeOnboardingFlow()
                return
            }

            runEnterpriseOnboardingFlow()
        }
    }
    
    private func runHomeOnboardingFlow() {
        VeeaRealmsManager.selectedRealm = vm.homeUserRealm().name
        AuthorisationManager.shared.reset()
        
        AuthorisationManager.shared.delegate = self
        AuthorisationManager.shared.discoverConfiguration()        
    }
    
    private func runEnterpriseOnboardingFlow() {
        let realmVc = UIStoryboard(name: "MultiTenancy", bundle: nil).instantiateViewController(withIdentifier: "SelectRealmViewController") as! SelectRealmViewController
        realmVc.loginflowDelegate = loginflowDelegate
        navigationController?.pushViewController(realmVc, animated: true)
    }
    
    private func addLegalTextView() {
        // Insert legal text.
        let legal1 = UILabel(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        legal1.textColor = UIColor.gray
        legal1.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        legal1.text = NSLocalizedString("By using this application, you agree with", comment: "Terms/conditions/privacy policy disclaimer")
        legal1.sizeToFit()
        
        let legal2 = UILabel(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        legal2.text = NSLocalizedString("our", comment: "")
        legal2.textColor = UIColor.gray
        legal2.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        legal2.sizeToFit()
        
        let legal3 = VUIUnderLinedButton(text: NSLocalizedString("Terms of Use", comment: "Terms/conditions/privacy policy disclaimer"))
        legal3.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        legal3.widthAnchor.constraint(equalToConstant: legal3.frame.width).isActive = true
        legal3.heightAnchor.constraint(equalToConstant: legal3.frame.height).isActive = true
        
        let legal4 = UILabel(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        legal4.textColor = UIColor.gray
        legal4.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        legal4.text = NSLocalizedString(" and ", comment: "Terms/conditions/privacy policy disclaimer")
        legal4.sizeToFit()
        
        let legal5 = VUIUnderLinedButton(text: NSLocalizedString("Privacy Policy", comment: "Terms/conditions/privacy policy disclaimer"))
        legal5.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        legal5.widthAnchor.constraint(equalToConstant: legal5.frame.width).isActive = true
        legal5.heightAnchor.constraint(equalToConstant: legal5.frame.height).isActive = true
        
        legalTopLine.addArrangedSubview(legal1)
        legalBottomLine.addArrangedSubview(legal2)
        legalBottomLine.addArrangedSubview(legal3)
        legalBottomLine.addArrangedSubview(legal4)
        legalBottomLine.addArrangedSubview(legal5)
    }
    
    // MARK: - Legal Text
    @objc func openTerms() {
        self.openLink(with: termsUrl)
    }
    
    @objc func openPrivacyPolicy() {
        self.openLink(with: privacyUrl)
    }
    
    func openLink(with url: String) {
        let miniBrowser = VUIWebViewController(urlString: url)
        self.present(miniBrowser, animated: true, completion: nil)
    }
}

extension LoginViewController: AuthorisationDelegate {


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
            showErrorInfoMessage(message: success.1 ?? "\("Log in failed because".localized()) \(success.1 ?? "\("of an unknown issue".localized())")")
            return
        }
        
        self.loginflowDelegate?.loginComplete()
    }

    func gotUserInfoResult(success: (Bool, String?, VHUser?)) {

    }
}
