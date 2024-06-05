//
//  EmailVerificationViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 29/06/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit
import WebKit

protocol EmailVerificationViewControllerDelegate {
    func doneAndVerfied()
    func pageDismissed()
}

class EmailVerificationViewController: UIViewController {

    private var completionDelegate: EmailVerificationViewControllerDelegate?
    
    @IBOutlet weak var webView: WKWebView!
    var url: URL?
    
    func load(pageUrl: URL, delegate: EmailVerificationViewControllerDelegate?) {
        url = pageUrl
        completionDelegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        loadInitial()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        completionDelegate?.pageDismissed()
    }
    
    private func loadInitial() {
        guard let url = url else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension EmailVerificationViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    guard let page = html as? String else {
                                        return
                                    }
                                    
                                    if page.contains("Your email address has been verified.") {
                                        self.dismiss(animated: true) {
                                            self.completionDelegate?.doneAndVerfied()
                                        }
                                    }
        })
    }
}
