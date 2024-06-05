//
//  LoadingUserDetailsViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 28/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking

class LoadingUserDetailsViewController: OnboardingBaseViewController {
    private lazy var noConnectivityWarningViewController: UIViewController = {
        let vc = NoConnectivityView.newNoConnectivityView()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()

    static func new() -> LoadingUserDetailsViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomeUserEnrollment.rawValue,
                              bundle: nil).instantiateViewController(withIdentifier: "LoadingUserDetailsViewController") as! LoadingUserDetailsViewController
        return vc
    }
    
    // Used to get the group details
    private lazy var groupsViewModel: GroupsViewModel = {
        GroupsViewModel()
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGroupData()
        hideBack = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideBack = false
    }
    
    private func loadGroupData() {


        // If logged in && internet is off line
        if UserSessionManager.shared.isUserLoggedIn && InternetConnectionMonitor.shared.connectivityStatus == .Disconnected {
            InternetConnectionMonitor.shared.delegate = self // Listen for going back online
            self.present(noConnectivityWarningViewController, animated: true)

            return
        }

        groupsViewModel.loadGroups {
            DispatchQueue.main.async {
                self.handleSuccessfulGroupGet()
            }
        } error: { [weak self] errMsg in
            DispatchQueue.main.async {
                self?.handleErrorGettingUserDetails()
            }
        }
    }
    
    private func handleSuccessfulGroupGet() {
        guard let groups = groupsViewModel.groups else {
            handleErrorGettingUserDetails()
            return
        }
        
        if groupsViewModel.numberOfGroups == 0 {
            push(group: nil)
        }
        else if groupsViewModel.numberOfGroups == 1 {
            push(group: groups.first)
        }
        
        else {
            // We should not be seeing multiple groups this for this type of account.
            // Leave for the moment as working with legacy accounts during dev
            push(group: groups.first)
        }
    }
    
    private func push(group: GroupModel?) {
        guard let group = group else {
            push(group: nil)
            return
        }
        
        if group.counts.devices == 0 {
            pushToWelcome(group: group)
            return
        }
        
        // If we have devices, then push to the dashboard
        pushToDashboard(group: group)
    }
    
    private func pushToWelcome(group: GroupModel?) {
        if let group = group {
            navController.newEnrollment.group = group
            navController.newEnrollment.meshName = group.name
        }

        navController.pushViewController(WelcomeScreenViewController.new(), animated: true)
    }

    private func pushToDashboard(group: GroupModel) {
        EnrollmentService.getOwnerConfig(groupId: group.id, success: { [weak self] (meshes) in
            guard let meshes = meshes else {
                self?.handleErrorGettingUserDetails()
                return
            }
            
            self?.navController.pushViewController(HomeDashboardViewController.new(meshes: meshes, for: group.id), animated: true)
        }) { [weak self] (err) in
            self?.handleErrorGettingUserDetails()
        }
        // Load mesh details
    }
    
    private func handleErrorGettingUserDetails() {
        showAlert(with: "Error", message: "Something went wrong. Please try logging in again") {
            self.navController.logout()
        }
    }
}

extension LoadingUserDetailsViewController: InternetConnectionStatusChangedDelegate {
    func connectivityStateChanged(state: InternetConnectionMonitor.InternetConnectivityStatus) {
        if state == .ConnectedToInternet {
            noConnectivityWarningViewController.dismiss(animated: true)
        }
    }
}
