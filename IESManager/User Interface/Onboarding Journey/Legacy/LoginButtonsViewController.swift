//
//  LoginButtonsViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 12/28/18.
//  Copyright © 2018 Veea. All rights reserved.
//

import UIKit

class LoginButtonsViewController: VUIViewController {
    
    var loginSignUpButton: VUIFlatButton!
    var legalTextContainer: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let maxButtonWidth = self.view.bounds.width * 0.85
        loginSignUpButton = VUIFlatButton(frame: CGRect.init(x: 0, y: 0, width: maxButtonWidth, height: 45), type: .standard, title: "Log in or Sign up".localized())
        loginSignUpButton.addTarget(self, action: #selector(LoginButtonsViewController.loginWithEmail), for: .touchUpInside)
        self.view.backgroundColor = UIColor(named: "Background Color Light")
        self.view.addSubview(loginSignUpButton)

        
        self.insertLegalText()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.realmManager.loadedRealms.isEmpty {
            appDelegate.realmManager.get { (success, error) in
                if !success {
                    Logger.log(tag: "LoginButtonsViewController", message: "Could not realms list: \(error ?? "Unknown reason")")
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let interItemSpacing = (self.view.bounds.height * 0.08)
        loginSignUpButton.centerInView(superView: self.view, mode: .horizontal)
        //To be removed when moving to native login
        let contentHeight = loginSignUpButton.frame.height + legalTextContainer.frame.height + interItemSpacing
        loginSignUpButton.frame.origin.y = (self.view.frame.height - (contentHeight))/2
        legalTextContainer.centerInView(superView: self.view, mode: .horizontal)
        legalTextContainer.frame.origin.y = loginSignUpButton.bottomEdge + interItemSpacing + 10
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO: - Needs clean up, use function compostion to get rid of repetition
    func insertLegalText() {
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
        legal3.addTarget(self, action: #selector(LoginButtonsViewController.openTerms), for: .touchUpInside)
        legal3.widthAnchor.constraint(equalToConstant: legal3.frame.width).isActive = true
        legal3.heightAnchor.constraint(equalToConstant: legal3.frame.height).isActive = true
        
        let legal4 = UILabel(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        legal4.textColor = UIColor.gray
        legal4.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        legal4.text = NSLocalizedString(" and ", comment: "Terms/conditions/privacy policy disclaimer")
        legal4.sizeToFit()
        
        let legal5 = VUIUnderLinedButton(text: NSLocalizedString("Privacy Policy", comment: "Terms/conditions/privacy policy disclaimer"))
        legal5.addTarget(self, action: #selector(LoginButtonsViewController.openPrivacyPolicy), for: .touchUpInside)
        legal5.widthAnchor.constraint(equalToConstant: legal5.frame.width).isActive = true
        legal5.heightAnchor.constraint(equalToConstant: legal5.frame.height).isActive = true
        
        legalTextContainer = UIStackView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35))
        let insets = (self.view.bounds.width * 0.15)/2
        legalTextContainer.layoutMargins = UIEdgeInsets(top: 0, left: insets, bottom: 0, right: insets)
        legalTextContainer.alignment = .center
        legalTextContainer.axis = .vertical
        legalTextContainer.spacing = 2
        legalTextContainer.addArrangedSubview(legal1)
        
        let innerContainer = UIStackView(arrangedSubviews: [legal2, legal3, legal4, legal5])
        innerContainer.axis = .horizontal
        innerContainer.distribution = .fillProportionally
        innerContainer.alignment = .center
        innerContainer.spacing = 2
        innerContainer.translatesAutoresizingMaskIntoConstraints = false
        legalTextContainer.addArrangedSubview(innerContainer)
        
        self.view.addSubview(legalTextContainer)
    }
    
    // MARK: - Legal Text
    @objc func openTerms() {
        self.openLink(with: "https://go.veea.com/tos/")
    }
    
    @objc func openPrivacyPolicy() {
        self.openLink(with: "https://go.veea.com/privacy/")
    }
    
    func openLink(with url: String) {
        let miniBrowser = VUIWebViewController(urlString: url)
        self.present(miniBrowser, animated: true, completion: nil)
    }
    
    // MARK: - Login with Email
    
    @objc func loginWithEmail() {
        
        //====================================================
        // Quick way to get to any screen. Just add below.
        // Dont forget to comment out
        
//        let vc = ConnectDeviceViewController()
//        self.show(vc, sender: nil)
//        
//        return
        
        //====================================================

        AnalyticsEventHelper.recordUserLoginStart()
        
        let vc = UIStoryboard(name: "MultiTenancy", bundle: nil).instantiateViewController(withIdentifier: "SelectRealmViewController") as! SelectRealmViewController
        if let loginVC = (parent as? LegacyLoginViewController) {
            vc.loginflowDelegate = loginVC.loginflowDelegate
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func skipEnrolement() {
        // Push the dashboard
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let dash = storyBoard.instantiateViewController(withIdentifier: "Dash") as? DashViewController else {
            return
        }
        
        self.navigationController?.pushViewController(dash, animated: true)
    }
}
