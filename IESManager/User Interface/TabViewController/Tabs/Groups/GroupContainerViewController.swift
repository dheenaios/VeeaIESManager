//
//  GroupContainerViewController.swift
//  VeeaHub Manager
//
//  Created by Bajirao Bhosale on 24/05/21.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit
import SharedBackendNetworking


/// Show the groups if there is more than one. Shows the Meshes if there is only on group
class GroupContainerViewController: VUIViewController {
    
    let notificationRequest = PushNotificationRequest()
    var groupsViewModel = GroupsViewModel()
    private var userGroupsService = UserGroupService()

    private lazy var noConnectivityWarningViewController: UIViewController = {
        let vc = NoConnectivityView.newNoConnectivityView()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .white
        self.checkLoadingState()
        
        notificationRequest.requestNotificationPermissions(completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func logoutCurrentUser() {
        self.showSpinner(onView: self.view)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        Task {
            let success = await UserSessionManager.shared.logoutUser(authFlowSessionManager: appDelegate)
            await MainActor.run {
                if !success {
                    self.removeSpinner()
                    if !success {
                        let alert = UIAlertController.init(title: "Failed!".localized(),
                                                           message: "Failed to log out, Please check your network and try again.".localized(),
                                                           preferredStyle: .alert)

                        alert.addAction(UIAlertAction.init(title: "Ok".localized(), style: .cancel, handler: nil))

                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    self.dismiss(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if let fc = UIApplication.topViewController() as? LoginFlowCoordinator {
                            fc.start()
                        }
                    }
                }
            }
        }
    }

    func checkLoadingState() {
        Task {
            if !UserSessionManager.shared.isUserLoggedIn {
                await UserSessionManager.shared.loadUser()
            }
            
            await MainActor.run { self.updateUI() }
        }
    }
    
    private func updateUI() {
        if InternetConnectionMonitor.shared.connectivityStatus == .Disconnected {
            InternetConnectionMonitor.shared.delegate = self // Listen for going back online
            self.present(noConnectivityWarningViewController, animated: true)

            return
        }

        if groupsViewModel.groups == nil {
            groupsViewModel.loadGroups {
                self.displayMeshInfo()
            } error: { error in
                self.displayLogoutMessage()
            }
        }
        else {
            displayMeshInfo()
        }
    }

    private func displayMeshInfo() {
        let meshesViewController = MeshSelectionViewController.newVc(groupService: userGroupsService,
                                                                     groupDetails: getSelectedGroupDetails(),
                                                                     parentsNavigationItem: navigationItem)
        meshesViewController.flowController = HubInteractionFlowController()

        let delay = DispatchTime.now() + .milliseconds(300)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.add(meshesViewController)
        }
    }

    private func getSelectedGroupDetails() -> GroupDetailsModel  {
        let hasMultiGroups = groupsViewModel.groups!.count > 1
        guard let selectedGroup = GroupModel.selectedModel else {
            let firstGroup = groupsViewModel.groups![0]
            GroupModel.selectedModel = firstGroup
            let selectedGroupDetails = GroupDetailsModel(groupModel: firstGroup,
                                                         hasMultiGroups: hasMultiGroups)

            return selectedGroupDetails
        }

        return GroupDetailsModel(groupModel: selectedGroup,
                                 hasMultiGroups: hasMultiGroups)
    }

    private func displayLogoutMessage() {
        // show no groups / enrollment view
        let logoutAction = CustomAlertAction(title: "Log out".localized(), style: UIAlertAction.Style.default) {[weak self] in
            self?.logoutCurrentUser()
        }

        showAlert(with: "Error".localized(),
                  message: "To continue using app, please log out and log in again.".localized(),
                  actions: [logoutAction])
    }
}

extension GroupContainerViewController: InternetConnectionStatusChangedDelegate {
    func connectivityStateChanged(state: InternetConnectionMonitor.InternetConnectivityStatus) {
        if state == .ConnectedToInternet {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showLoginFlowCoordinator()
        }
    }
}

