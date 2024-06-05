//
//  RemoteNotificationHandler.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 06/12/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit


/// Handles the incoming push notifications and any related UI actions
struct RemoteNotificationHandler {
    
    static private let TAG = "RemoteNotificationHandler"
    
    static func handleUnUserNotificationCentreNotification(userInfo: [AnyHashable : Any]) {
        //guard let aps = userInfo["aps"] as? [String: AnyObject] else { return }
        
        // Handle loud notification
        if let d = userInfo as? [String: AnyObject] {
            processVisibleNotification(payload: d)
        }
    }
    
    
    /// For handling notifications from app  did open or from didReceiveRemoteNotification.
    /// - Parameters:
    ///   - application: application
    ///   - dict: the payload dictionary
    ///   - completionHandler: completion handler
    static func handleNotification(application: UIApplication?,
                                   dict: [AnyHashable : Any],
                                   completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        
        guard let aps = dict["aps"] as? [String: AnyObject] else { return }
        
        if isSilentNotification(aps: aps,
                                completionHandler: completionHandler) {
                        
            return
        }
    
        // VHM-1331 - Decided to show the notification shade. As a result we use UNUserNotificationCenter delegate methods now.
        // So this **should** never be called
        if let application = application {
            if application.applicationState == .active {
                return
            }
        }
        
        // Handle loud notification
        if let d = dict as? [String: AnyObject] {
            processVisibleNotification(payload: d)
        }
        
        if let completionHandler = completionHandler {
            completionHandler(.newData)
        }
    }

    private static func processVisibleNotification(payload: [String: AnyObject]) {
        if let groupId = payload["groupId"] as? String,
           let meshId = payload["meshId"] as? String,
           let serial = payload["deviceSerial"] as? String {

            pushTo(group: groupId,
                   mesh: meshId,
                   serial: serial)
        }
    }
    
    /// Returns true and handles the notification if its a silent notification
    /// - Parameter aps: aps dictionary
    /// - Returns: Is this a silent notification
    private static func isSilentNotification(aps: [String : Any],
                                             completionHandler: ((UIBackgroundFetchResult) -> Void)?) -> Bool {
        if aps["content-available"] as? Int == 1 {
            
            //print("Silent notification from launch")
            if let completionHandler = completionHandler {
                completionHandler(.newData)
            }
        }
        
        return false
    }
}

// MARK: - Push to Mesh
extension RemoteNotificationHandler {
    private static func pushTo(group: String,
                               mesh: String,
                               serial: String) {
        if Target.currentTarget == .QA_HOME {
            handleHomePush(group: group,
                           mesh: mesh,
                           serial: serial)
        }
        else {
            handleEnterprisePush(group: group,
                                 mesh: mesh,
                                 serial: serial)
        }
    }
    
    private static func handleEnterprisePush(group: String,
                                      mesh: String,
                                      serial: String) {

        // VHM-1507 - To reduce the chance of error, then pop to the very start of the nav stack and start from there.
        // Also makes sure the correct tab in tab view is shown
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showLoginFlowCoordinator()


        var log = "Enterprise user push notification.\nPush to group: \(group)\nMesh Id: \(mesh)\nSerial Number: \(serial)\n"
        
        // [VHM-1259] Not using serial at the moment - 17 January 2022
        guard let vc = HubInteractionFlowController.currentConformantVc else {
            let logAppend = "Could not get current conformant VC. Storing for later use"
            log.append(logAppend)
            Logger.log(tag: TAG, message: log)
            
            // There is no flow supporting view controller.
            // The user is either logged out OR the app is opening from a closed state.
            // Store the dretails of the notification for when there is a flow supporting VC
            HubInteractionFlowController.storeIdsForLaterUse(groupId: group, meshId: mesh)
            
            return
        }
        
        if let flowController = vc.flowController {
            let logAppend = "Attepting to push notification via flow controller"
            log.append(logAppend)
            Logger.log(tag: TAG, message: log)
            
            flowController.attemptToDisplay(groupId: group, meshId: mesh)
            return
        }
        
        log.append("Could not get flow controller")
        
        // If there is no flow controller on the conformant object, store the info and
        // pop the navigation view controller to its root, which will be have a flow controller & will conform to HubInteractionFlowControllerProtocol
        if let containerVc = vc.navigationController?.viewControllers.first as? GroupContainerViewController {
            if let child = containerVc.children.first as? HubInteractionFlowControllerProtocol {
                log.append("Attempting to push notification via flow controller on container VC")
                Logger.log(tag: TAG, message: log)
                
                child.flowController?.attemptToDisplay(groupId: group, meshId: mesh)
                return
            }
        }
        
        if let rootVc = vc.navigationController?.viewControllers.first as? HubInteractionFlowControllerProtocol {
            log.append("Attempting to push notification via rootVc")
            Logger.log(tag: TAG, message: log)
            rootVc.flowController?.attemptToDisplay(groupId: group, meshId: mesh)
        }
    }
    
    private static func handleHomePush(group: String,
                                mesh: String,
                                serial: String) {
        var log = "Home user push notification.\nPush to group: \(group)\nMesh Id: \(mesh)\nSerial Number: \(serial)\n"
        
        // This just pushes to the dashboard
        let topVc = AppDelegate.getTopController()
        
        if let nav = topVc as? HomeUserSessionNavigationController {
            nav.popToRootViewController(animated: false)
        }
        
        log.append("Attempting to push notification via topViewController")
        Logger.log(tag: TAG, message: log)
    }
}
