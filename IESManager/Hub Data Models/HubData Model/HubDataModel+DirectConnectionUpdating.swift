//
//  HubDataModel+DirectConnectionUpdating.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 08/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


// MARK: - Local / Direct connection handling

// This extension deals with updating when connecting locally
extension HubDataModel {
    
    func getDataModelFromLocalHub(connection: VeeaHubConnection) {
        var callCompleted = false
        let delay = DispatchTime.now() + .seconds(10)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            if callCompleted == false {
                self.reportModelUpdateError(message: "New config request timed out".localized())
            }
        }

        ApiFactory.api.getBaseDataModel(connection: connection) { (dataModel, error) in
            callCompleted = true

            if let dataModel = dataModel {
                self.baseDataModel = dataModel
                self.delegate?.updateDidProgress(progress: 0.5, message: "Getting App Information".localized())

                // Inject the ethernet tables if they're needed
                if let nodeCap = self.baseDataModel?.nodeCapabilitiesConfig {
                    var config = dataModel.installedAppsConfig!
                    
                    if let supported = dataModel.nodeAPConfig?.ap_1_1.enhancedSecuritySupported {
                        if supported {
                            config.addAppConfig(appName: "enhancedSecuritySupported", appId: "enhancedSecuritySupported")
                        }
                    }

                    if nodeCap.numberOfEthernetPortsAvailable > 0 && !nodeCap.ethernetPortRoles.isEmpty {
                        config.addAppConfig(app: .ports)
                    }

                    // Add Static and Lan ports if they are available
                    // Note ethports is not related to the above 2, but it was added at the same time
                    // After a time add these 2 back to the base model.
                    if nodeCap.hasCapabilityForKey(key: "ethports") {
                        if nodeCap.usesNodeLanDhcpTable {
                            config.addAppConfig(app: .lanAndStaticTables)
                        }
                        else {
                            config.addAppConfig(app: .legacyLanAndStaticTables)
                        }
                    }
                    if nodeCap.usesNodeLanStatusTable {
                        config.addAppConfig(app: .node_lan_status)
                    }

                    if nodeCap.wanStaticIps != nil {
                        config.addAppConfig(app: .wanStaticIps)
                    }
                    if nodeCap.hasMeshWdsTopologyTable {
                        config.addAppConfig(app: .MeshWdsTopologyConfig)
                    }
                    
                    self.requestOptionalApps(connection: connection, config: config)
                    return
                }

                self.requestOptionalApps(connection: connection, config: dataModel.installedAppsConfig)
            } else {
                self.reportModelUpdateError(message: "ERROR obtaining Hub data model")
            }
        }
    }
    
    fileprivate func requestOptionalApps(connection: VeeaHubConnection,
                                         config: InstalledAppsConfig?) {
        if snapShotInUse {
            updateDataModelsFromSnapshots()
            self.updateCompletedSucessfully(message: "Success")
            
            return
        }
        
        var callCompleted = false
        let delay = DispatchTime.now() + .seconds(10)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            if callCompleted == false {
                self.reportModelUpdateError(message: "New app config request timed out")
            }
        }
        
        guard let config = config else {
            updateCompletedSucessfully(message: "No App Data".localized())
            return
        }
        
        ApiFactory.api.getOptionAppsDataModel(connection: connection, installedAppManifest: config) { (dataModel, error) in
            callCompleted = true
            if let dataModel = dataModel {
                self.optionalAppDetails = dataModel
                self.updateCompletedSucessfully(message: "Success".localized())
            }
            else {
                //self.reportModelUpdateError(message: "No optional data model received")
                self.tryOptionalAppsCallWithoutLanTables(connection: connection,
                                                         config: config)
            }
        }
    }
    
    // TODO: Relates to the issue outlined above about the lanAndStaticTables
    // Remove when the issue is resolved
    private func tryOptionalAppsCallWithoutLanTables(connection: VeeaHubConnection,
                                                     config: InstalledAppsConfig) {
        Logger.log(tag: tag, message: "Initial call for optional apps did not work. Trying without lanAndStaticTables")
        
        var newConfig = config
        newConfig.removeAppConfig(appName: "lanAndStaticTables", appId: "lanAndStaticTables")
        
        ApiFactory.api.getOptionAppsDataModel(connection: connection,
                                              installedAppManifest: newConfig) { (dataModel, error) in
            if let dataModel = dataModel {
                self.optionalAppDetails = dataModel
                self.updateCompletedSucessfully(message: "Success".localized())
            }
            else {
                self.reportModelUpdateError(message: "No optional data model received".localized())
            }
        }
    }
}
