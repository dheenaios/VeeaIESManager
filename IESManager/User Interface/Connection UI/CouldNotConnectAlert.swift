//
//  CouldNotConnectAlert.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 20/10/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

class CouldNotConnectAlert {
    
    private let title = "Could not connect to VeeaHub".localized()
    private let message = "We are unable to connect to your VeeaHub.".localized()
    
    private let retryOption = "Retry".localized()
    private let supportOption = "Contact customer support".localized()
    private let removeOption = "Remove VeeaHub from account".localized()
    private let cancelOption = "Cancel".localized()
    
    private var alert: UIAlertController?
    private var hostViewController: UIViewController
    
    private let connectionInfo: ConnectionInfo
    private var node: VHMeshNode
    private var mesh: VHMesh
    
    init(hostViewController: UIViewController, connectionInfo: ConnectionInfo) {
        self.hostViewController = hostViewController
        self.connectionInfo = connectionInfo
        self.node = connectionInfo.selectedMeshNode
        self.mesh = connectionInfo.selectedMesh
    }
    
    func showAlert(retryHandler: @escaping(ConnectionInfo) -> Void) {
        alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
        
        alert!.addAction(UIAlertAction(title: retryOption,
                                       style: .default,
                                       handler: { (alert) in
                                        retryHandler(self.connectionInfo)
                                       }))
        
        alert!.addAction(UIAlertAction(title: supportOption,
                                       style: .default,
                                       handler: { [weak self] (alert) in
                                        self?.support()
                                       }))
        
        let removeAction = UIAlertAction(title: removeOption, style: .destructive) { (action) in
            let canRemove = HubRemover.isUnEnrollementPossible(meshNode: self.node, mesh: self.mesh).0
            
            if !canRemove {
                let message = HubRemover.isUnEnrollementPossible(meshNode: self.node, mesh: self.mesh).1!
                self.showRemoveFailedDialog(message: message)
                
                return
            }
            
            self.remove()
        }
        
        alert?.addAction(removeAction)
        alert?.addAction(UIAlertAction.init(title: cancelOption, style: .cancel, handler: nil))
        hostViewController.present(alert!, animated: true, completion: nil)
    }
    
    private func support() {
        self.hostViewController.present(VUIWebViewController(urlString: "https://veea.zendesk.com/hc/en-us/requests/new"), animated: true, completion: nil)
    }
    
    private func remove() {
        
        let r = HubRemover.canHubBeRemoved(connectionInfo: connectionInfo)
        if !r.0 {
           
            self.hostViewController.showInfoAlert(title: "Cannot remove VeeaHub".localized(), message: r.1 ?? "Please disconnect from the hub, reconnect and try to remove again".localized())

            return
        }        
        
        let alert = UIAlertController.init(title: "Remove VeeaHub".localized(),
                                           message: "Are you sure you want to remove this VeeaHub?".localized(),
                                           preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "REMOVE".localized(), style: .destructive, handler: { [weak self] (action) in
            self?.removeCall()
        }))
        
        hostViewController.present(alert, animated: true, completion: nil)
    }
    
    private func removeCall() {
        HubRemover.remove(node: node) { (success, errorMessage) in
            if success {
                self.hostViewController.navigationController?.popToRootViewController(animated: true)
                
                return
            }
            
            self.hostViewController.showInfoAlert(title: "Unenrollment Failed".localized(), message: errorMessage ?? "Unknown error.".localized())
        }
    }
    
    private func showRemoveFailedDialog(message: String) {
        // Delay display of the following alert to allow the last alert to clear away
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.hostViewController.showInfoAlert(title: "Could not remove hub".localized(), message: message)
        }
    }
}
