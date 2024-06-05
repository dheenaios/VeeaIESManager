//
//  UserTypeViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

// TODO: This is currently not in use as the target dictates the route. This may change, so do not delete just yet

class UserTypeViewController: OnboardingBaseViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var homeOption: ImageOptionView!
    @IBOutlet weak var businessOption: ImageOptionView!
    
    private var vm = UserTypeViewModel()
    
    var loginflowDelegate: LoginFlowCoordinatorDelegate?
    
    static func new() -> UserTypeViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomeUserLogin.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: "UserTypeViewController") as! UserTypeViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        homeOption.observerTaps { self.homeTapped() }
        businessOption.observerTaps { self.businessTapped() }
    }
    
    private func homeTapped() {
        /*
        //-------
        // TEMP - TO ALLOW ME TO JUMP TO A SPECICIC VC
        let nc = HomeUserEnrollmentNavigationController.new()
        nc.modalPresentationStyle = .overFullScreen
        nc.logoutClosure = { print("Logout tapped")}

        self.present(nc, animated: true) {}

        return
        //
        //------
         
        */

        AnalyticsEventHelper.recordUserLoginStart()
        
        VeeaRealmsManager.selectedRealm = vm.homeUserRealm().name
        AuthorisationManager.shared.reset()
        
        AuthorisationManager.shared.delegate = self
        AuthorisationManager.shared.discoverConfiguration()
    }
    
    private func businessTapped() {
        AnalyticsEventHelper.recordUserLoginStart()
        
        let realmVc = UIStoryboard(name: "MultiTenancy", bundle: nil).instantiateViewController(withIdentifier: "SelectRealmViewController") as! SelectRealmViewController
        realmVc.loginflowDelegate = loginflowDelegate
        navigationController?.pushViewController(realmVc, animated: true)
    }
    
    override func setTheme() {
        super.setTheme()
        infoLabel.textColor = cm.text2.colorForAppearance
        infoLabel.font = FontManager.bodyText
        
        homeOption.imageBackgroundColor = cm.themeTint.colorForAppearance
        homeOption.imageView.image = UIImage(named: "house")
        
        businessOption.imageBackgroundColor = cm.buttonOrange1.colorForAppearance
        businessOption.imageView.image = UIImage(named: "building")
    }
}

extension UserTypeViewController: AuthorisationDelegate {
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
    
    func gotUserInfoResult(success: (Bool, String?, VHUser?)) {}
}
