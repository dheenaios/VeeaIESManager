//
//  SecurityConfigCoordinator.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

protocol SecurityConfigCoordinatorDelegate: AnyObject {
    func secChangesDidFinishWithChanges(model: AccessPointConfig)
}

class SecurityConfigCoordinator {
    private weak var delegate: SecurityConfigCoordinatorDelegate?
    var config: AccessPointConfig
    var isHubAp: Bool
    private var originalConfig: AccessPointConfig
    
    private var _acctIsEnabled = false
    
    var meshRadiusConfig: MeshRadiusConfig? {
        guard let meshRadiusServerConfig = HubDataModel
                .shared.optionalAppDetails?
                .meshRadiusServerConfig else { return nil }
        return meshRadiusServerConfig
    }
    
    var radiusServers: [RadiusServer] {
        guard let configs = meshRadiusConfig else {
            return [RadiusServer]()
        }
        
        return configs.radiusAuthServers
    }
    
    init(config: AccessPointConfig, delegate: SecurityConfigCoordinatorDelegate, isHubAp: Bool) {
        self.delegate = delegate
        self.config = config
        originalConfig = config
        self.isHubAp = isHubAp
    }
    
    var enhancedSecuritySupported: Bool {
        return config.enhancedSecuritySupported
    }
    
    var secureMode: AccessPointConfig.SecureMode {
        get { return config.secureMode ?? .preSharedPsk }
        set { config.secureMode = newValue }
    }
    
    var encryptMode: AccessPointConfig.EncryptMode {
        get { return config.wpaMode ?? .wpa2AndWpa3 }
        set { config.wpaMode = newValue }
    }
}

// MARK: - Radius Auth
extension SecurityConfigCoordinator {
    var radiusAuthPrimaryDescriptionText: String {
        let details = getAuthRadiusDetails(radiousid: config.radius1_auth_id)
        return "\("Primary".localized()): \(details)"
    }
    
    var radiusAuthSecondaryDescriptionText: String {
        let details = getAuthRadiusDetails(radiousid: config.radius2_auth_id)
        return "\("Secondary".localized()): \(details)"
    }
    
    private func getAuthRadiusDetails(radiousid: Int) -> String {
        guard let radiusServers = meshRadiusConfig else {
            return "No radius server info found".localized()
        }
        
        if radiousid == 0 { return "Not configured".localized() }
        
        let index = radiousid - 1
        let server = radiusServers.radiusAuthServers[index]
        
        guard !server.address.isEmpty,
              !server.secret.isEmpty else {
            return "Additional configuration needed".localized()
        }
        
        return "\(server.address) on \(server.port)"
    }
}

// MARK: - Radius Accounting
extension SecurityConfigCoordinator {
    
    var acctIsEnabled: Bool {
        get {
            if acctRadiusIsSet {
                return acctRadiusIsSet
            }
            
            return _acctIsEnabled
        }
        set {
            if !newValue {
                config.radius1_acct_id = 0
                config.radius2_acct_id = 0
            }
            
            _acctIsEnabled = newValue
        }
    }
    
    // Check if the primary or secondary acct radius server is set to a value
    private var acctRadiusIsSet: Bool {
        if config.radius1_acct_id != 0 || config.radius2_acct_id != 0 {
            return true
        }
        
        return false
    }
    
    var radiusAcctPrimaryDescriptionText: String {
        let details = getAcctRadiusDetails(radiousid: config.radius1_acct_id)
        return "\("Primary".localized()): \(details)"
    }

    var radiusAcctSecondaryDescriptionText: String {
        let details = getAcctRadiusDetails(radiousid: config.radius2_acct_id)
        return "\("Secondary".localized()): \(details)"
    }

    private func getAcctRadiusDetails(radiousid: Int) -> String {
        guard let radiusServers = meshRadiusConfig else {
            return "No radius server info found".localized()
        }

        if radiousid == 0 { return "Not configured".localized() }

        let index = radiousid - 1
        let server = radiusServers.radiusAcctServers[index]

        guard !server.address.isEmpty,
              !server.secret.isEmpty else {
            return "Additional configuration needed".localized()
        }

        return "\(server.address) \("on".localized()) \(server.port)"
    }
}

// MARK: -  View Communication
extension SecurityConfigCoordinator {
    func userTappedDone() {
        if config != originalConfig {
            delegate?.secChangesDidFinishWithChanges(model: config)
        }
    }
}
