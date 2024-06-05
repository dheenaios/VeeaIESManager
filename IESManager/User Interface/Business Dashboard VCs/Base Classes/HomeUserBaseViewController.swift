//
//  HomeUserBaseViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 04/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit
import SharedBackendNetworking

class HomeUserBaseViewController: UIViewController {
    
    let cm = InterfaceManager.shared.cm
    var internetConnectionBanner: InternetConnectionBannerView?
    
    lazy var workingAlert: UIAlertController = {
        let alert = UIAlertController(title: "Working...".localized(),
                                      message: "Please wait a moment".localized(),
                                      preferredStyle: .alert)
        return alert
    }()
    
    var hideBack: Bool {
        get {
            return navigationItem.hidesBackButton
        }
        set {
            self.navigationItem.setHidesBackButton(newValue, animated: false)
        }
    }
    
    var hideNavBar: Bool {
        get {
            return navigationController?.isNavigationBarHidden ?? true
        }
        set {
            hideNavBar(newValue, animated: false)
        }
    }
    
    func hideNavBar(_ hide: Bool, animated: Bool) {
        navigationController?.setNavigationBarHidden(hide, animated: animated)
    }
    
    func showWorkingAlert(show: Bool) {
        if !show {
            workingAlert.dismiss(animated: true, completion: nil)
            return
        }
        
        present(workingAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UpdateRequired.updateRequired {
            UpdateManager.shared.showUpdateRequiredPopUp()
        }
    }


    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    func setTheme() {
        updateNavBarWithDefaultColors()
    }
    
    var navController: HomeUserSessionNavigationController  {
        let nv = self.navigationController as! HomeUserSessionNavigationController
        
        return nv
    }
}
