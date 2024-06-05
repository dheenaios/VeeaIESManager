//
//  BootstrapViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 12/04/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit


class BootstrapViewController: BaseConfigViewController, HubInteractionFlowControllerProtocol {
    var flowController: HubInteractionFlowController?
    
    var vm: BootstrapViewModel?
    
    typealias CompletionBlock = () -> Void
    var completion: CompletionBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = BootstrapViewModel(host: self)
    }
    
    public func listenForRecoveryTrigger(completionHandler completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    @IBAction func beginBootstrapTapped(_ sender: Any) {
        showWarningBootStrapWarning()
    }
    
    @IBAction func beginReinstallTapped(_ sender: Any) {
        showWarningReinstallWarning()
    }
        
    // MARK: - Show warning
    private func showWarningBootStrapWarning() {
        let alert = UIAlertController(title: "Begin Network reinstall".localized(),
                                      message: "Are you sure you want to begin reinstall?".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Begin".localized(), style: .destructive, handler: { alert in
            self.vm?.sendBootstrapTrigger()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { alert in
            HubDataModel.shared.baseDataModel?.nodeControlConfig?.resetAllTriggers()
        }))
        
        present(alert, animated: true, completion: nil)
        alert.view.tintColor = Utils.globalTint()
    }
    
    private func showWarningReinstallWarning() {
        let alert = UIAlertController(title: "Begin Local reinstall".localized(),
                                      message: "Are you sure you want to begin reinstall?".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Begin".localized(), style: .destructive, handler: { alert in
            self.vm?.sendReinstallTrigger()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { alert in
            HubDataModel.shared.baseDataModel?.nodeControlConfig?.resetAllTriggers()
        }))
        
        present(alert, animated: true, completion: nil)
        alert.view.tintColor = Utils.globalTint()
    }
}
