//
//  ViewControllerExtensions.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 24/05/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation
import UIKit
import SharedBackendNetworking

extension UIViewController {
    

    /// Gets the apply button (if there is one)
    public var probableApplyButton: UIBarButtonItem? {
        if let items = navigationController?.navigationBar.topItem?.rightBarButtonItems {
            for item in items {
                if item.title == "Apply".localized() { return item }
            }
        }
        
        return nil
    }
    
    var applyButtonIsHidden: Bool {
        get {
            guard let b = probableApplyButton else { return true }
            return !b.isEnabled
        }
        set {
            guard let b = probableApplyButton else { return }
            
            if newValue {
                b.isEnabled = false
                b.tintColor = .clear
            }
            else {
                b.isEnabled = true
                b.tintColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
            }
        }
    }
    
    public func showInfoMessage(message: String, tapObserver: (() -> Void)? = nil) {
        showInfoShade(message: message, color: view.tintColor, duration: 3.5, atTop: false, tapped: tapObserver)
    }
    
    public func showSuccessWarning(message: String, tapObserver: (() -> Void)? = nil) {
        showInfoShade(message: message, color: .stateHealthy, duration: 3.0, atTop: false, tapped: tapObserver)
    }

    
    public func showInfoWarning(message: String, tapObserver: (() -> Void)? = nil) {
        showInfoShade(message: message, color: .orange, duration: 5.0, atTop: false, tapped: tapObserver)
    }
    
    public func showInfoWarningAtTop(message: String, tapObserver: (() -> Void)? = nil) {
        showInfoShade(message: message, color: .orange, duration: 5.0, atTop: true, tapped: tapObserver)
    }
    
    public func showErrorInfoMessage(message: String, tapObserver: (() -> Void)? = nil) {
        showInfoShade(message: message, color: .red, duration: 3.5, atTop: false, tapped: tapObserver)
    }
    
    private func showInfoShade(message: String,
                               color: UIColor,
                               duration: TimeInterval,
                               atTop: Bool,
                               tapped: (() -> Void)? = nil) {
        
        let tabBarHeight = getTabBarHeight()
        
        let height: CGFloat = 100.0
        let vcframe = UIWindow.sceneWindow?.frame
        
        var labelY = (vcframe!.size.height - tabBarHeight) - height
        
        if atTop {
            let window = UIWindow.sceneWindow
            let topPadding = window?.safeAreaInsets.top
            
            labelY = topPadding ?? 32
        }

        let frame = CGRect(x: 0, y: labelY, width: vcframe!.size.width, height: height)
        let shade = InfoShadeView.init(frame: frame,
                                       backgroundColor: color,
                                       text: message)
        
        if let t = tapped {
            shade.addTapObserver(tapped: t)
        }
        
        shade.alpha = 0.0
        
        UIWindow.sceneWindow?.addSubview(shade)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction) {
            shade.alpha = 1.0
        } completion: { complete in
            self.remove(view: shade, afterDelay: duration)
        }
    }
    
    private func remove(view: UIView, afterDelay duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction) {
                view.alpha = 0.0
            } completion: { complete in
                view.removeFromSuperview()
            }
        }
    }
    
    public func getTabBarHeight() -> CGFloat {
        guard let tabBarController = UIApplication.getTopMostTabBarController() else {
            return 0.0
        }
                
        return tabBarController.tabBar.bounds.size.height
    }
    
    public func confirmSSID(shouldSend: @escaping (Bool) -> Void) {
        if HubApWifiConnectionManager.shared.isCurrentWifiNetworkAsExpected() == true {
            shouldSend(true)
        }
        else {
            guard let currentSsid = HubApWifiConnectionManager.currentSSID,
                let setSsid = HubApWifiConnectionManager.shared.currentlyConnectedHub?.ssid else {
                    shouldSend(true)
                    return
            }
            
            let alert = UIAlertController(title: "SSID may have changed".localized(),
                                          message: "\("You are currently connected to".localized()): \(currentSsid)\(", however you last selected".localized()) \(setSsid) in \("the VeeaHub Selector".localized())",
                preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Update connected VeeaHub".localized(), style: .destructive) { _ in
                shouldSend(true)
                
                let newIes = VeeaHubConnection();
                newIes.ssid = currentSsid
                HubApWifiConnectionManager.shared.currentlyConnectedHub = newIes
            })
            alert.addAction(UIAlertAction(title: "Cancel Update".localized(), style: .cancel) { _ in
                shouldSend(false)
            })
            
            self.present(alert, animated: true)
        }
    }
    
    func checkWifiNetworkIsAsExpected() {
        if HubApWifiConnectionManager.shared.isCurrentWifiNetworkAsExpected() == false {
            guard let connectedSsid = HubApWifiConnectionManager.currentSSID, let requestedSsid = HubApWifiConnectionManager.shared.currentlyConnectedHub?.ssid else {
                // The connection mananger will send a notification if we are not connected to a hotspot
                return
            }
            
            let message = "\("You last selected".localized()) \(requestedSsid) \("but now are connected to".localized()) \(connectedSsid)\n\n\("Please check you are connected to the correct Hub".localized())\("Please check you are connected to the correct Hub".localized())"
            let actions = UIAlertController(title: "Unexpected SSID".localized(), message: message, preferredStyle: .alert)
            
            actions.addAction(UIAlertAction(title: "VeeaHub Selector".localized(), style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            actions.addAction(UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil))
            
            present(actions, animated: true)
        }
    }
    
    func showNeedsRestartIfNeeded(restart: @escaping ()-> Void) {
        if let status = HubDataModel.shared.baseDataModel?.nodeStatusConfig {
            if status.reboot_required == true {
                
                let alert = UIAlertController(title: "Restart Required".localized(),
                                              message: "\("A restart is required for your settings to take effect.".localized())\n\(status.reboot_required_reason) \("changed".localized())", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Restart".localized(), style: .destructive, handler:{ alert in
                    self.showRestartPrompt(restart: restart)
                }))
                alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
                
                present(alert, animated: true)
                alert.view.tintColor = Utils.globalTint()
            }
        }
    }
    
    func showRestartPrompt(restart: @escaping ()-> Void) {
        guard HubDataModel.shared.connectedVeeaHub != nil else {
            //print("No VHM")
            return
        }
        
        let alert = UIAlertController(title: "Restart Hub".localized(), message: "Are you sure you want to restart this Hub?".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart".localized(), style: .destructive, handler: { alert in
            restart()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        alert.view.tintColor = Utils.globalTint()
    }
    
    /// Displays a restart warning.
    ///
    /// - Parameter restartResult: Returns true if the user wishes to go ahead
    func displayRestartRequiredWarning(customMessage: String?, restartResult: @escaping (Bool) -> Void) {
        var restartMessage = "You will need to restart your hub for these changes to take effect.".localized()
        
        if let customMessage = customMessage {
            restartMessage = customMessage
        }
        
        let actions = UIAlertController(title: "Restart Required".localized(), message: restartMessage, preferredStyle: .alert)
        
        actions.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (action) in
            restartResult(false)
        }))
        actions.addAction(UIAlertAction(title: "Continue".localized(), style: .destructive, handler: { (action) in
            restartResult(true)
        }))
        present(actions, animated: true)
    }
    
    func showInfoAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil)
        okAction.accessibility(config: AccessibilityConfigurations.alertOkButton)
        alert.addAction(okAction)

        self.present(alert, animated: true)
    }
    
    func showErrorUpdatingAlert(error: APIError) {
        showInfoAlert(title: "Error updating".localized(), message: "\("There was a problem updating the Hub config.".localized())\n\(error.errorDescription())")
    }
    
    func showTestersMenu() {
        if BackEndEnvironment.internalBuild {
            let storyBoard = UIStoryboard(name: "TestersMenu", bundle: nil)
            
            if let _ = UIApplication.topViewController() as? TesterMenuRootTableViewController {
                return
            }

            if Target.currentTarget.isHome {
                if let navController = storyBoard.instantiateInitialViewController() {
                    navController.modalPresentationStyle = .fullScreen
                    present(navController, animated: true, completion: nil)
                }
            }
            
            if let viewControllers = self.navigationController?.viewControllers {
                for vc in viewControllers {
                    if vc === self {
                        let vc = storyBoard.instantiateViewController(withIdentifier: "TesterMenuRootTableViewController")
                        navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                }
            }
            
            if let navController = storyBoard.instantiateInitialViewController() {
                navController.modalPresentationStyle = .fullScreen
                present(navController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Internet Connectivity
extension UIViewController {
    /// Shows the internet connection banner and returns a reference to it
    /// - Returns: Reference to the banner
    func showNoConnectionBanner() -> InternetConnectionBannerView {
        let height: CGFloat = 42.0
        let vcframe = UIApplication.shared.keyWindow?.frame
        let labelY = (vcframe!.size.height - (tabBarHeight + 40)) - height
        let frame = CGRect(x: 0, y: labelY, width: vcframe!.size.width, height: height)

        let banner = InternetConnectionBannerView(frame: frame)
        banner.alpha = 0.0

        self.view.addSubview(banner)

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction) {
            banner.alpha = 1.0
        }

        return banner
    }
    
    public func showErrorHandlingAlert(title:String, message: String, suggestions:[String]) {
        let viewAlert =  self.view.viewWithTag(501)as? ErrorHandlingAlert
        if viewAlert != nil {
            viewAlert?.removeFromSuperview()
        }
        var errorHandlingAlert : ErrorHandlingAlert?
        if errorHandlingAlert == nil {
            errorHandlingAlert = ErrorHandlingAlert.init(frame: self.view.frame)
        }
        errorHandlingAlert?.updateUI(title: title, message: message, suggestions: suggestions)
        errorHandlingAlert?.tag = 501
        errorHandlingAlert!.alpha = 0.0
        UIWindow.sceneWindow?.addSubview(errorHandlingAlert!)
        
        UIView.animate(withDuration: 0.3, animations: {
            errorHandlingAlert!.alpha = 1.0
        })
    }
}
