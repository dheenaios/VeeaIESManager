//
//  HubRemover.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 20/10/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

class HubRemover {

    static func canHubBeRemoved(connectionInfo: ConnectionInfo?) -> (Bool, String?) {
        guard let connectionInfo = connectionInfo else {
            return(false, "No connection. Please check your internet connection.".localized())
        }

        // Check connected
        if InternetConnectionMonitor.shared.connectivityStatus == .Disconnected {
            return(false, "No connection. Please check your internet connection.".localized())
        }

        // Can it be removed
        let removeable = HubRemover.isUnEnrollementPossible(meshNode: connectionInfo.selectedMeshNode,
                                                            mesh: connectionInfo.selectedMesh)
        if !removeable.0 {
            return(false, removeable.1 ?? "Please try again later".localized())
        }

        return(true, nil)
    }

    static func remove(node: VHMeshNode, completion: @escaping (SuccessAndOptionalMessage) -> Void) {
        UnEnrollmentService.unEnroll(node: node) { (success, errorString, errorMeta) in
            if success {
                NotificationCenter.default.post(name: Notification.Name.updateMeshes, object: nil)
                
                completion((true, nil))
                return
            }
            
            let errorMessage = errorString ?? "Unknown error.".localized()
            completion((false, errorMessage))
        }
    }

    static func isUnEnrollementPossible(meshNode: VHMeshNode, mesh: VHMesh) -> (SuccessAndOptionalMessage) {
        if meshNode.isMEN ?? false {
            if mesh.devices?.count == 1 {
              /*
               if let packages = meshNode.packages {
                    for packageDetails in packages {
                        if packageDetails.type == "Premium" ||
                            packageDetails.type == "Freemium" {
                            return (false, "In order to remove this VeeaHub you must first unsubscribe this mesh from any subscriptions in ControlCenter".localized())
                        }
                    }
                }
               */
                return (true, nil)
            }
            else {
                return (false, "In order to remove this VeeaHub you must remove the other Veeahubs connected to it first".localized())
            }
        }
        
        return (true, nil)
    }
}
