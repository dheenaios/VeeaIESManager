//
//  SecurityEditRadiusViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 02/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

class SecurityEditRadiusViewModel {
    
    private let maxPskChars = 31
    var model: RadiusServer?
    var radiusModelIndex: Int?
    var isAuthServer = true
    var isInUse = false // Is in use as primary or secondary radius
    var isCurrentlySelected = false // Is selected in the SecurityRadiusSelectionTableViewController
    
    var defaultPort: Int {
        return isAuthServer ? 1812 : 1813
    }
    
    func sendUpdate(vc: UIViewController) {
        guard var meshRadiusServerConfig = HubDataModel.shared.optionalAppDetails?.meshRadiusServerConfig,
              let index = radiusModelIndex,
              let model = model,
              let connection = HubDataModel.shared.connectedVeeaHub else { return }
        if isAuthServer {
            meshRadiusServerConfig.radiusAuthServers[index] = model
        }
        else {
            meshRadiusServerConfig.radiusAcctServers[index] = model
        }
        
        

        ApiFactory.api.setConfig(connection: connection, config: meshRadiusServerConfig) { (message, error) in
            if let error = error {
                vc.showErrorInfoMessage(message: message ?? error.localizedDescription)
                return
            }
            
            HubDataModel.shared.optionalAppDetails?.meshRadiusServerConfig = meshRadiusServerConfig
            
            vc.navigationController?.popViewController(animated: true)
        }
    }
    
    func validIp(ip: String?) -> Bool {
        guard let ip = ip else {
            return false
        }
        
        return AddressAndPortValidation.isIPValid(string: ip)
    }
    
    func validPort(port: String?) -> Bool {
        guard let port = port else { return false }
        if port.isEmpty { return false }
        
        guard let portInt = Int(port)  else { return false }
        return portInt > 0 &&  portInt < 65536
    }
    
    func validPass(pass: String?) -> Bool {
        guard let pass = pass else { return false }
        if pass.isEmpty { return false }
        
        if pass.count > maxPskChars {
            model?.secret = ""
            return false
        }
        else {
            model?.secret = pass
            return true
        }
    }
    
    
    /// Empty entries are allowed. Check if all are empty
    func validEmptySelection(ssid: String?,
                             port: String?,
                             secret: String?) -> Bool {
        guard let ssid = ssid,
              let port = port,
              let secret = secret else {
            return false
        }
        
        return ssid.isEmpty && port.isEmpty && secret.isEmpty
    }
}
