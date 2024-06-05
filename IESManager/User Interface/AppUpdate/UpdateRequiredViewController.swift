//
//  UpdateRequiredViewController.swift
//  VeeaHub Manager
//
//  Created by Bajirao Bhosale on 23/06/21.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class UpdateRequiredViewController: UIViewController {

    var latestVersion : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Update Required".localized()
        self.createSubViews()
    }
    
    private func createSubViews() {
        
        self.view.backgroundColor = .white
        
        if AuthorisationManager.shared.isLoggedIn {
            let logoutBtn = UIBarButtonItem(title: "Log out".localized(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(logoutBtnPressed))
            logoutBtn.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.red], for: UIControl.State.normal)
            self.navigationItem.rightBarButtonItem = logoutBtn
            
        }
        
        let containerFrame = self.view.frame
        let logImgView = UIImageView(frame: CGRect(x: containerFrame.size.width/2 - 46, y: containerFrame.size.height/2 - 240 , width: 92, height: 92))
        logImgView.image = UIImage(named: "update")
        self.view.addSubview(logImgView)
        
        let appName = Target.targetDisplayName
        let title = "Update is required to continue using ".localized() + appName
        
        let msg1 = "version".localized()
        let msg1Alt = "New version of".localized()
        let msg2 = "is now available.\nUpdates bring new features and fixes. Please update the app to continue using ".localized()
        
        let msg = latestVersion != nil ? "\(appName) \(msg1) \(latestVersion!) \(msg2) \(appName)" : "\(msg1Alt) \(appName) \(msg2) \(appName)"
        
        let updateLbl = UILabel(frame: CGRect(x: 40, y: logImgView.frame.size.height + logImgView.frame.origin.y + 30, width: containerFrame.size.width - 80, height: 60))
        updateLbl.numberOfLines = 0
        updateLbl.font = FontManager.bold(size: 18)
        updateLbl.text = title
        updateLbl.textAlignment = .center
        self.view.addSubview(updateLbl)
        
        let updateInfoLbl = UILabel(frame: CGRect(x: 40, y: updateLbl.frame.size.height + updateLbl.frame.origin.y + 10, width: containerFrame.size.width - 80, height: 80))
        updateInfoLbl.font = FontManager.regular(size: 15)
        updateInfoLbl.text = msg
        updateInfoLbl.textAlignment = .center
        updateInfoLbl.numberOfLines = 0
        self.view.addSubview(updateInfoLbl)
        
        let btnRect = CGRect(x: 40, y: updateInfoLbl.frame.size.height + updateInfoLbl.frame.origin.y + 30, width: containerFrame.size.width - 80, height: 50)
        let updateNowBtn = VUIFlatButton(frame: btnRect, type: .green, title: "Update".localized())
        updateNowBtn.addTarget(self, action: #selector(UpdateRequiredViewController.openAppStore), for: .touchUpInside)
        self.view.addSubview(updateNowBtn)
    }

    @objc func openAppStore(){
        
//        self.dismiss(animated: true) {
//            UpdateManager.shared.isBeingPresented = false
//        }
        
        let url  = URL(string: BackEndEnvironment.appstoreUrl)
        
        if url != nil && UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    @objc func logoutBtnPressed() {
        if AuthorisationManager.shared.isLoggedIn {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            Task {
                let success = await UserSessionManager.shared.logoutUser(authFlowSessionManager: appDelegate)
                await MainActor.run { handleLogoutResult(success) }
            }
        }
    }

    private func handleLogoutResult(_ success: Bool) {
        UpdateManager.shared.isBeingPresented = false
        if success {
            self.dismiss(animated: true) {}
        }
        else {
            let alert = UIAlertController.init(title: "Failed!".localized(),
                                               message: "Failed to log out, Please check your network and try again.".localized(),
                                               preferredStyle: .alert)

            alert.addAction(UIAlertAction.init(title: "Ok".localized(), style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
    }
}
