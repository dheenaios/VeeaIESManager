//
//  LoginFlowCoordinator.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/30/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

protocol LoginFlowCoordinatorDelegate {
    func loginComplete()
}

class LoginFlowCoordinator: UIViewController {
    
    var presentedVc: UIViewController?
    var activity: VUIActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.start()
    }
    
    func start() {
        let activity = VUIActivityView()
        activity.beginAnimating()
        
        // If the session has expired then there might be a wait to get set up
        Task {
            await UserSessionManager.shared.loadUser()
            await MainActor.run {
                let initalVC = self.getInitialViewController()
                initalVC.modalPresentationStyle = .overFullScreen
                self.presentedVc = initalVC
                self.present(initalVC, animated: false, completion: {
                    activity.endAnimating()
                })
            }
        }
    }
    
    func getInitialViewController() -> UIViewController {
        if UserSessionManager.shared.isUserLoggedIn {
            return getMainSelectionAndConfigurationInterface()
        }
        
        return getLogin()
    }
    
    func getLogin() -> UINavigationController {
        let loginVC = LoginViewController.new()
        loginVC.modalPresentationStyle = .overFullScreen
        loginVC.loginflowDelegate = self
        getRealms()
        
        return UINavigationController(rootViewController: loginVC)
    }
    
    func getMainSelectionAndConfigurationInterface() -> UIViewController {
        let _ = UserSessionManager.shared // Start this initialising

        if Target.currentTarget.isHome {
            let nc = HomeUserSessionNavigationController.new()
            nc.modalPresentationStyle = .overFullScreen
            nc.logoutClosure = {self.handleLogout()}
            
            return nc
        }
        
        let vc = MainTabViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.logoutClosure = {self.handleLogout()}
        
        return vc
    }
    
    private func handleLogout() {
        if presentedVc is UINavigationController {
            let nc = presentedVc as! UINavigationController
            let root = nc.viewControllers.first
            
            if root is LoginViewController {
                return
            }
        }
        
        let loginFlow = getLogin()
        loginFlow.modalPresentationStyle = .overFullScreen
        self.presentedVc = loginFlow
        self.present(loginFlow, animated: false, completion: nil)
    }
    
    private func getRealms() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.realmManager.get { (success, errorString) in
            if !success {
                Logger.log(tag: "LoginFlowCoordinator", message: "Could not realms list: \(errorString ?? "Unknown reason")")
            }
        }
    }
}

// MARK: - LoginFlowCoordinatorDelegate
extension LoginFlowCoordinator: LoginFlowCoordinatorDelegate {
    func loginComplete() {
        // Get user info from server
        activity = VUIActivityView()
        activity?.beginAnimating()
        
        AuthorisationManager.shared.delegate = self
        AuthorisationManager.shared.getUserInfo { (completed) in
            PushNotificationRequest.sendTokenToBackendIfNeeded()
        }
    }
}

extension LoginFlowCoordinator: AuthorisationDelegate {
    func configDiscoveryCompleted(success: (SuccessAndOptionalMessage)) {}
    
    func loginRequestResult(success: (SuccessAndOptionalMessage)) {}
    
    func gotUserInfoResult(success: (Bool, String?, VHUser?)) {
        if !success.0 || success.2 == nil {
            let message = success.1 ?? "Error getting user data.".localized()
            
            showAlert(with: "Oops!".localized(), message: message)
            flushUserData()

            AnalyticsEventHelper.recordLoginFail(reason: message)
            
            return
        }

        AuthorisationManager.shared.accessToken { (token) in
            guard token != nil else {
                showAlert(with: "Oops!".localized(), message: "No access token. Please try logging in again.".localized())
                return
            }

            UserSessionManager.shared.isUserLoggedIn = true
            AnalyticsEventHelper.recordLoginSuccess()
            self.activity?.endAnimating(callback: {
                if (UIApplication.topViewController() is SelectRealmViewController ||
                    UIApplication.topViewController() is NewRealmViewController) ||
                    UIApplication.topViewController() is LoginViewController {
                    
                    if let navController = UIApplication.topViewController()?.navigationController {
                        UIApplication.topViewController()?.present(self.getMainSelectionAndConfigurationInterface(), animated: true, completion: nil)
                        navController.popToRootViewController(animated: false)
                    }
                    else{
                        UIApplication.topViewController()?.present(self.getMainSelectionAndConfigurationInterface(), animated: true, completion: nil)
                    }
                }
                else {
                    let className = String(describing: UIApplication.topViewController().self)
                    if className.contains("SFAuthenticationViewController") {
                        UIApplication.topViewController()?.dismiss(animated: true, completion: {
                            UIApplication.topViewController()?.present(self.getMainSelectionAndConfigurationInterface(), animated: true, completion:nil)
                        })
                    }
                }
            })
        }
    }

    func flushUserData() {
        UserSessionManager.shared.flushUserFromDevice()

        // Get rid of the API token and the BTLE key
        ApiFactory.api.deleteCurrentAuthToken()
        VeeaHubDiscoveryManager.get.setBeaconEncryptKey(key: "")

        DispatchQueue.main.async {
            WebCacheCleaner.clean()
        }
    }
}
