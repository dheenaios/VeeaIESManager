//
//  GroupMeshFlowController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 06/12/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit

protocol HubInteractionFlowControllerProtocol: UIViewController {
    var flowController: HubInteractionFlowController? { get set }
    
    func handleNotificationWithDetails(groupId: String, meshId: String)
}

extension HubInteractionFlowControllerProtocol {
    func handleNotificationWithDetails(groupId: String, meshId: String) {
        //print("handleNotificationWithDetails called but not implemented")
    }
}

class HubInteractionFlowController {
    
    private let TAG = "HubInteractionFlowController"
    
    weak var currentViewController: HubInteractionFlowControllerProtocol? {
        get {
            return _currentViewController
        }
        set {
            if currentViewController === newValue {
                return
            }
            
            _currentViewController = newValue
            
            // If we have something to go to, go there.
            if let group = HubInteractionFlowController.groupIdPendingSelection,
               let mesh = HubInteractionFlowController.meshIdPendingSelection {
                attemptToDisplay(groupId: group,
                                 meshId: mesh)
                
                return
            }
            
            if let group = notificationGroupIdInProgress,
               let mesh = notificationMeshIdIpProgress {
                _currentViewController?.handleNotificationWithDetails(groupId: group, meshId: mesh)
            }
        }
    }
    
    private weak var _currentViewController: HubInteractionFlowControllerProtocol?
    
    private static var groupIdPendingSelection: String?
    private static var meshIdPendingSelection: String?
    
    public private(set) var notificationGroupIdInProgress: String?
    public private(set) var notificationMeshIdIpProgress: String?
    
    func clearNotification() {
        notificationGroupIdInProgress = nil
        notificationMeshIdIpProgress = nil
    }
    
    static func storeIdsForLaterUse(groupId: String, meshId: String) {
        groupIdPendingSelection = groupId
        meshIdPendingSelection = meshId
    }
    
    func attemptToDisplay(groupId: String, meshId: String) {
        
        var log = "Push notification.\nPush to group: \(groupId)\nMesh Id: \(meshId)...\n"
        
        // Nil the static methods as they're not locally in play and we dont want repeat calls.
        HubInteractionFlowController.groupIdPendingSelection = nil
        HubInteractionFlowController.meshIdPendingSelection = nil
        
        // Set the instance items in flow
        notificationGroupIdInProgress = groupId
        notificationMeshIdIpProgress = meshId
        
        guard let currentVc = _currentViewController else {
            log.append("No view controller attached")
            Logger.log(tag: TAG, message: log)
            return
        }
        
        // 1. Pop to the root view controller. This will be the groups
        if let containerVc = currentVc.navigationController?.viewControllers.first as? GroupContainerViewController {
            if let child = containerVc.children.first as? MeshSelectionViewController {
                _currentViewController = child
            }
        }

        // Pop to the first view controller
        guard let navController = currentViewController?.navigationController else {
            log.append("Current view controller has no navigation controller")
            Logger.log(tag: TAG, message: log)
            
            return
        }

        navController.popToRootViewController(animated: false)
        log.append("Popping to root view controller.\n")
        
        
        // 2. Tell the view controller to push to the selected group
        // // If there is only one group, then we will push directly to MeshesViewController which will check for push upon load.
        // Otherwise...
        
        // If we only have one group, the first will be MeshSelectionViewController
        if let vc = _currentViewController as? MeshSelectionViewController {
            log.append("MeshSelectionViewController will try to handle notification.")
            Logger.log(tag: TAG, message: log)
            vc.handleNotificationWithDetails(groupId: groupId, meshId: meshId)
            return
        }
        
    }
}

extension HubInteractionFlowController {
    
    
    /// Digs down through the view heirachies to find the top most VC conforming to HubInteractionFlowControllerProtocol.
    /// Returns nil of nothing is found. If this is the case, then we are probably logged out.
    /// Will also manipulate the main tab view to show the conforming VC
    /// - Returns: The conforming VC if it exists
    static var currentConformantVc: HubInteractionFlowControllerProtocol? {
        guard let topController = AppDelegate.getTopController() else { return nil }
        
        // If we are logged in then we should see the tab bar controller as the top most VC
        if let vc = topController as? MainTabViewController {
            if let vcs = vc.viewControllers {
                
                // Dig down to get the view controller conforming to the flow protocol
                for tabVc in vcs {
                    if let nc = tabVc as? UINavigationController {
                        guard let displayedVc = nc.viewControllers.last else { return nil }
                        
                        let cvc = childConformingToFlowControllerProtocol(parent: displayedVc)
                        if cvc != nil {
                            setTabBarToManagement(tbc: vc)
                        }
                        
                        return cvc
                    }
                }
            }
        }
        
        return nil
    }
    
    private static func childConformingToFlowControllerProtocol(parent: UIViewController) -> HubInteractionFlowControllerProtocol? {
        
        if let container = parent as? GroupContainerViewController {
            for childVc in container.children {
                if let conformingVc = childVc as? HubInteractionFlowControllerProtocol {
                    return conformingVc
                }
            }
        }
        else if let conformantVc = parent as? HubInteractionFlowControllerProtocol {
            return conformantVc
        }
        
        return nil
    }
    
    private static func setTabBarToManagement(tbc: MainTabViewController) {
        tbc.selectedIndex = 0
    }
}
