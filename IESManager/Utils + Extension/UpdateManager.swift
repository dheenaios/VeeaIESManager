//
//  UpdateManager.swift
//  VeeaHub Manager
//
//  Created by Bajirao Bhosale on 21/06/21.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit
import Firebase
import SharedBackendNetworking

class UpdateManager {
    
    static let shared: UpdateManager = UpdateManager()
    
    var isBeingPresented : Bool = false
    var remoteConfig: RemoteConfig!
    
    private init() {
    }
    
    fileprivate func openAppStore() {
        isBeingPresented = false
        if let url = URL(string: BackEndEnvironment.appstoreUrl),  UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    fileprivate func showAPIUpdatePopup(latestVersion : String? = nil) {
        if UpdateRequired.updateRequiredShownThisSession { return }
        UpdateRequired.updateRequiredShownThisSession = true
        let updateRequiredScreen = UpdateRequiredViewController(nibName: nil, bundle:nil)
        let navController = UINavigationController(rootViewController: updateRequiredScreen)
        navController.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(navController, animated: true, completion: {})
    }
    
    func showNonMandatoryUpdatePopUp(latestVersion : String) {
        if isBeingPresented { return }
        isBeingPresented = true
        let appName = Target.targetDisplayName
        
        let s = "A new version of".localized()
        let e = "is available.\nWould you like to update to the version".localized()
        
        let msg = "\(s) \(appName) \(e) \(latestVersion)?"
        
        let updateAction = CustomAlertAction(title: "Update".localized(), style: UIAlertAction.Style.default) { [weak self] in
            self?.openAppStore()
        }
        
        let ignoreAction = CustomAlertAction(title: "Ignore".localized(), style: UIAlertAction.Style.default, callBack: {
            self.isBeingPresented = false
        })
        showAlert(with: "New version available".localized(), message: msg, actions: [updateAction, ignoreAction])
    }
    
    func showUpdateRequiredPopUp(latestVersion : String? = nil) {
        
        if isBeingPresented {
            return
        }
        
        isBeingPresented = true
        
        DispatchQueue.main.async {
            self.showAPIUpdatePopup(latestVersion: latestVersion)
        }
        
    }
    
    func syncRemoteConfiguration() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings

        remoteConfig.fetch { (status, error) in
            if status == .success {
                self.remoteConfig.activate() { (changed, error) in
                    guard let minVersion = self.remoteConfig.configValue(forKey:  "min_version_vhm").stringValue, let latestVersion = self.remoteConfig.configValue(forKey:  "latest_version_vhm").stringValue else {
                        return
                    }
                    
                    let currentAppVersion = VeeaKit.versions.application
                    
                    if currentAppVersion.isVersion(lessThan: minVersion) {
                        DispatchQueue.main.async {
                            self.showUpdateRequiredPopUp(latestVersion: latestVersion)
                        }
                        
                    } else if currentAppVersion.isVersion(greaterThanOrEqualTo: minVersion), currentAppVersion.isVersion(lessThan: latestVersion) {
                        DispatchQueue.main.async {
                            self.showNonMandatoryUpdatePopUp(latestVersion: latestVersion)
                        }
                    }
                }
            } else {
                //print("Config not fetched")
                //print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
}
