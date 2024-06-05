//
//  LoginViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 12/26/18.
//  Copyright © 2018 Veea. All rights reserved.
//

import UIKit
import WebKit
import SharedBackendNetworking

class LegacyLoginViewController: UIViewController {
    
    var loginflowDelegate: LoginFlowCoordinatorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(named: "loginBackground")
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationItem.titleView = VeeaNavbarLogoView()
        
        let loginPageVC = LoginPageViewController()
        loginPageVC.view.frame.size.height = self.view.bounds.height * 0.7
        self.addChild(loginPageVC)
        self.view.addSubview(loginPageVC.view)
        loginPageVC.didMove(toParent: self)
        
        let loginButtonsVC = LoginButtonsViewController()
        self.addChild(loginButtonsVC)
        loginButtonsVC.view.frame.size.height = self.view.bounds.height * 0.3
        loginButtonsVC.view.frame.origin.y = self.view.bounds.height - loginButtonsVC.view.frame.height
        self.view.addSubview(loginButtonsVC.view)
        loginButtonsVC.didMove(toParent: self)
        
        self.becomeFirstResponder()
        
        if BackEndEnvironment.internalBuild {
            showInfoAlert(title: "Internal Testing", message: "Shake the device for tester options")
        }
        
        clearCaches()
    }
    
    private func clearCaches() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeOfflineWebApplicationCache,
                                             WKWebsiteDataTypeCookies,
                                             WKWebsiteDataTypeSessionStorage,
                                             WKWebsiteDataTypeLocalStorage,
                                             WKWebsiteDataTypeWebSQLDatabases,
                                             WKWebsiteDataTypeIndexedDBDatabases,
                                             WKWebsiteDataTypeServiceWorkerRegistrations,
                                             WKWebsiteDataTypeFetchCache])

        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>,
                                                modifiedSince: date) {}
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    func resetNavBarToDefault() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        self.navigationController?.navigationBar.standardAppearance = navBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetNavBarToDefault()
        transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.enableLargeTitles(enable: false)
            self.setLargeTitleMode(mode: .never)
        }, completion: { _ in
            
        })
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            showTestersMenu()
        }
    }
}
