//
//  ChangePasswordViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 04/06/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit
import WebKit
import SharedBackendNetworking

class ChangePasswordViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    var warningShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Change password".localized()
        webView.navigationDelegate = self
        injectNoZoomCodeIntoPage()
        
        loadInitial()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        WebCacheCleaner.clean()

        tabBarController?.tabBar.isHidden = false
    }
    
    /// The change password screen zooms. Inject some java script to stop it zooming.
    private func injectNoZoomCodeIntoPage() {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd,
                                                forMainFrameOnly: true)
        
        webView.configuration.userContentController.addUserScript(script)
    }
    
    private func loadInitial() {
        let link = AuthorisationManager.shared.changePasswordUrl
        let request = URLRequest(url: link)
        webView.load(request)
    }
    
    private func checkForLoginScreen() {
        guard let emailAddress = UserSessionManager.shared.currentUser?.email else {
            return // Let the user enter that info
        }
        
        let script = """
        document.getElementById('username').value = '\(emailAddress)';
        document.getElementById("username").readOnly = true;
        document.getElementById('kc-info-wrapper').style.display='none';
        """
        webView.evaluateJavaScript(script, completionHandler: nil)
        
        showDialog()
    }
    
    private func showDialog() {
        if warningShown { return }
        
        let alert = UIAlertController(title: nil,
                                      message: "For security reasons, please log in again to change the password".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        warningShown = true
    }
    
    private func removeBackButtonAndLeftPanel() {
        let script = """
        document.getElementsByClassName('bs-sidebar col-sm-3')[0].style.display='none';
        document.getElementById('callback').style.visibility = "hidden";
        """
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
}

extension ChangePasswordViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        checkForLoginScreen()
        removeBackButtonAndLeftPanel()
    }
}
