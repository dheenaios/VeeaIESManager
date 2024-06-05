//
//  BootstrapViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class BootstrapViewModel: BaseConfigViewModel {
    
    private weak var host: BootstrapViewController?
    init(host: BootstrapViewController) {
        self.host = host
        
        super.init()
    }
    
    func sendBootstrapTrigger() {
        guard var config = HubDataModel.shared.baseDataModel?.nodeControlConfig else {
            host?.showInfoWarning(message: "No Node Control model".localized())
            return
        }
        
        config.setRecoveryTrigger()
        sendUpdate(config: config)
    }
    
    func sendReinstallTrigger() {
        guard var config = HubDataModel.shared.baseDataModel?.nodeControlConfig else {
            host?.showInfoWarning(message: "No Node Control model".localized())
            return
        }
        
        config.setReinstallTrigger()
        sendUpdate(config: config)
    }
    
    private func sendUpdate(config: NodeControlConfig) {
        guard let ies = connectedHub else {
            host?.showInfoWarning(message: "No Hub Connected".localized())
            return
        }
                
        host?.updateUpdateIndicatorState(state: .uploading)

        ApiFactory.api.setConfig(connection: ies, config: config) { [weak self]  (result, error) in
            if error != nil {
                self?.host?.updateUpdateIndicatorState(state: .completeWithError)
                self?.host?.showErrorUpdatingAlert(error: error!)

                return
            }

            self?.host?.updateUpdateIndicatorState(state: .completeWithSuccess)
            WiFi.disconnectFromAllNetworks()
            
            self?.host?.showInfoMessage(message: "Beginning recovery. VeeaHub will go offline.".localized())
            self?.host?.dismissCard()
            
            if let completion = self?.host?.completion {
                completion()
            }
        }
    }
}
