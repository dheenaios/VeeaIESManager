//
//  HomeUserSessionNavigationController.swift
//  IESManager
//
//  Created by Richard Stockdale on 18/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class HomeUserSessionNavigationController: UINavigationController {

    var newEnrollment: HomeHubEnrollmentModel!
    
    var logoutClosure: (() -> Void)?
    
    static func new() -> HomeUserSessionNavigationController {
        let nc = UIStoryboard(name: StoryboardNames.HomeUserEnrollment.rawValue, bundle: nil)
            .instantiateInitialViewController() as! HomeUserSessionNavigationController
        
        nc.newEnrollment = HomeHubEnrollmentModel()
        return nc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        // Do any additional setup after loading the view.
    }
    
    func logout() {
        Task {
            let _ = await LogoutController.logout()
            await MainActor.run {
                self.dismiss(animated: true) {
                    if let handleLogout = self.logoutClosure {
                        handleLogout()
                    }
                }
            }
        }
    }
    
    /// Pops back the the correct view controller to start enrollment again
    func startFollowUpEnrollment() {
        for controller in viewControllers {
            if controller.isKind(of: WelcomeScreenViewController.self) {
                let group = newEnrollment.group
                let meshName = newEnrollment.meshName
                newEnrollment = HomeHubEnrollmentModel()
                newEnrollment.group = group
                newEnrollment.meshName = meshName
                
                popToViewController(controller, animated: true)
            }
        }
    }
}
