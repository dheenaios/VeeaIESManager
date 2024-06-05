//
//  MainTabViewController.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/4/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class MainTabViewController: UITabBarController {
    
    var logoutClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.vTabBarTint
        
        AuthorisationManager.shared.refreshAuthTokenIfNeeded { (completed) in
        } // Called to make any update checks required

        
        let groupsNavController = UINavigationController(rootViewController: GroupContainerViewController())
        let groupIcon = UIImage(named: "iconMesh")?.withRenderingMode(.alwaysTemplate)
        let groupIconSelected = UIImage(named: "iconMeshSelected")?.withRenderingMode(.alwaysTemplate)
        let manageTab = UITabBarItem(title: "Manage".localized(),
                                     image: groupIcon,
                                     selectedImage: groupIconSelected)
        manageTab.accessibility(config: AccessibilityConfigurations.manageTab)
        groupsNavController.tabBarItem = manageTab
        
        let homeVC = UINavigationController(rootViewController: GuidesViewController())
        let homeIcon = UIImage(named: "iconGuides")?.withRenderingMode(.alwaysTemplate)
        let homeIconSelected = UIImage(named: "iconGuidesSelected")?.withRenderingMode(.alwaysTemplate)
        let guideTab = UITabBarItem(title: "Guides".localized(),
                                    image: homeIcon,
                                    selectedImage: homeIconSelected)
        guideTab.accessibility(config: AccessibilityConfigurations.guidesTab)
        homeVC.tabBarItem = guideTab
        
        let settingsVC = UINavigationController(rootViewController: MyAccountTableViewController.new())
        settingsVC.title = "My Account".localized()
        let settingsIcon = UIImage(named: "iconProfile")?.withRenderingMode(.alwaysTemplate)
        let settingsIconSelected = UIImage(named: "iconProfileSelected")?.withRenderingMode(.alwaysTemplate)
        let myAccountTab = UITabBarItem(title: "My Account".localized(),
                                        image: settingsIcon,
                                        selectedImage: settingsIconSelected)
        myAccountTab.accessibility(config: AccessibilityConfigurations.myAccountTab)
        settingsVC.tabBarItem = myAccountTab
        
        self.viewControllers = [groupsNavController, homeVC, settingsVC]
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabViewController.logoutAction), name: NSNotification.Name.logoutNotification, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // TODO: - Release unused tabs from cache
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            showTestersMenu()
        }
    }
    
    func setEnableTabs(enabled: Bool) {
        guard let items = self.tabBar.items else {
            return
        }
        
        for item in items {
            item.isEnabled = enabled
        }
    }
}

// MARK: - UITabBarDelegate
extension MainTabViewController {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let selectedItem = item.value(forKey: "view") as? UIView
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: UIView.KeyframeAnimationOptions.calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                selectedItem?.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2, animations: {
                selectedItem?.transform = CGAffineTransform.identity
            })
        }) { (_) in
            
        }
    }
}

// MARK: - Logout user
extension MainTabViewController {
    @objc func logoutAction() {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                if let handleLogout = self.logoutClosure {
                    handleLogout()
                }
            }
        }
    }
}

