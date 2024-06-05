//
//  DashViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 02/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit


class DashViewModel {
    typealias RefreshCallBack = (_ errorMessage: String?) -> Void
    var refreshCallBack: RefreshCallBack?

    var sections: [DashSectionModel]
    let dm = DashModelUpdater()
    
    var updateErrorRetryCount = 0
    let updateRetryLimit = 2
    
    var gatewayAddress: String {
        return WiFi.getGatewayAddress()
    }
    
    /// The text for the message displayed when the user taps the title bar tex
    var connectionInfoDialogMessage: String {
        guard let dm = HubDataModel.shared.baseDataModel else {
            return "Not connected".localized()
        }
        
        var message = "This device IP: ".localized()
        
        // This device IP
        let thisIP = WiFi.getWiFiAddress()
        message.append(thisIP ?? "Not set".localized())
        
        let ssid = HubApWifiConnectionManager.currentSSID ?? "SSID not configured by this app".localized()
        message.append("\nCurrent SSID: ".localized())
        message.append(ssid)
        
        message.append("\nConnected Hub: ".localized())
        if let nodeName = dm.nodeInfoConfig?.node_name {
            message.append(nodeName)
        }
        else {
            message.append("Unknown".localized())
        }
        
        message.append("\nGateway IP: ".localized())
        message.append(gatewayAddress)
        
        if WiFi.shouldOverideGateway == true && WiFi.overrideIPAddress.isEmpty == false {
            message.append("\nGateway is overridden to: ".localized())
            message.append(WiFi.overrideIPAddress)
        }
        
        return message
    }
    
    
    init() {
        sections = dm.getUpdatedModels()
        //update()
    }
    
    public func refresh(completion: @escaping RefreshCallBack) {
        if HubDataModel.shared.connectedVeeaHub == nil {
            sections = dm.disabledModels()
            completion("Not connected to a VeeaHub".localized())
            return
        }
        
        // If the refresh callback is populated then a refresh is in progress
        if refreshCallBack != nil {
            return
        }
        
        refreshCallBack = completion
        HubDataModel.shared.updateConfigInfo(observer: self)
    }
    
    private func updateModels() {
        guard let cb = refreshCallBack else {
            return
        }
        
        sections = dm.getUpdatedModels()
        
        cb(nil)
        refreshCallBack = nil
    }
}

extension DashViewModel: HubDataModelProgressDelegate {
    func updateDidCompleteAfterScan(success: Bool, message: String?) {
        
    }
    
    func updateDidComplete(success: Bool, message: String?) {
        guard let cb = refreshCallBack else {
            return
        }
        
        if success {
            updateErrorRetryCount = 0
            updateModels()
        }
        else {
            sections = dm.disabledModels()
            
            if updateErrorRetryCount < updateRetryLimit && refreshCallBack != nil {
                updateErrorRetryCount += 1
                refresh(completion: refreshCallBack!)
            }
            else {
                cb(message)
                refreshCallBack = nil
            }
        }
    }
    
    func updateDidProgress(progress: Float, message: String?) {
        // Not used here
    }
}

// MARK: - Hub Operations
extension DashViewModel {
    func restart(completed: @escaping (String) -> Void) {
        PowerCommands.restart(hub: HubDataModel.shared.connectedVeeaHub) { success, message in
            if !success {
                showAlert(with: "Could not restart".localized(), message: message)
            }

            completed(message)
            HubApWifiConnectionManager.shared.currentlyConnectedHub = nil
            WiFi.disconnectFromAllNetworks()
        }
    }
}

// MARK: - IP Connection Override
extension DashViewModel {
    func setIpOverrideIfNeeded() -> Bool {
        if HubIpOverride.shouldOverrideHubIp {
            let fakeHub = VeeaHubConnection()
            HubDataModel.shared.connectedVeeaHub = fakeHub
            
            return true
        }
        
        return false
    }
}
// MARK: - Selection Handling
extension DashViewModel {
    func handleSelected(model: DashItemModel, dashVc: DashViewController) {
        let itemId = model.itemID
        
        // Items that open a new View Controller
        
        var vcToOpen: UIViewController?
        if itemId == DashboardItemKeys.nodeItem {
            let sb = UIStoryboard(name: "NodeConfig", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "NodeConfigViewController")
            
        }
        else if itemId == DashboardItemKeys.vMeshItem {
            let sb = UIStoryboard(name: "VmeshConfig", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "VmeshConfigViewController")
        }
        else if itemId == DashboardItemKeys.beaconItem {
            let sb = UIStoryboard(name: "BeaconConfig", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "BeaconConfigViewController")
        }
        else if itemId == DashboardItemKeys.gatewayItem {
            let sb = UIStoryboard(name: "WanGatewayConfig", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "WanGatewayTabViewController")
        }
        else if itemId == DashboardItemKeys.physicalAp1 || itemId == DashboardItemKeys.physicalAp2 {
            guard let hubDm = HubDataModel.shared.baseDataModel,
                let hub = HubDataModel.shared.connectedVeeaHub,
                let mC = hubDm.meshAPConfig,
                let nC = hubDm.nodeAPConfig,
                let ncc = hubDm.nodeCapabilitiesConfig,

                let rC = hubDm.nodeConfig else {
                    return
            }
            
            let sb = UIStoryboard(name: "WifiApManagement", bundle: nil)
            let nc = sb.instantiateViewController(withIdentifier: "radioAccessPointConfig") as! UINavigationController
            
            guard let vc = nc.viewControllers.first as? APConfigSelectionViewController else { return }
            let ap = itemId == DashboardItemKeys.physicalAp1 ? SelectedAP.AP1 : SelectedAP.AP2
            
            vc.configure(selectedFreq: ap,
                         meshConfig: mC,
                         nodeCongig: nC,
                         radioConfig: rC,
                         nodeCapabilityConfih: ncc,
                         connection: hub)
            
            vcToOpen = vc
        }
        else if itemId == DashboardItemKeys.wanNode {
            
        }
        else if itemId == DashboardItemKeys.routerItem {
            let sb = UIStoryboard(name: "RouterConfig", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "RouterConfigViewController")
        }
        else if itemId == DashboardItemKeys.firewallItem {
            let sb = UIStoryboard(name: "Firewall", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "FirewallConfigViewController")
        }
        else if itemId == DashboardItemKeys.cellularStatsItem {
            let sb = UIStoryboard(name: "CellularStats", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "CellularStatsViewController")
        }
        else if itemId == DashboardItemKeys.wifiStatsItem {
            let sb = UIStoryboard(name: "WifiStats", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "WifiStatsViewController")
        }
        else if itemId == DashboardItemKeys.iPItem {
            let sb = UIStoryboard(name: "IPConfig", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "IPConfigViewController")
        }
        else if itemId == DashboardItemKeys.physicalPorts {
            let sb = UIStoryboard(name: "PhysicalPortsStoryboard", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "PortConfigViewController")
        }
        else if itemId == DashboardItemKeys.vlan {
            let sb = UIStoryboard(name: "vLAN", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "VlanConfigurationViewController")
        }
        else if itemId == DashboardItemKeys.optionalServices {
            let sb = UIStoryboard(name: "Services", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "ServicesViewController")
        }
        else if DashboardItemKeys.lanConfig == itemId {
            let sb = UIStoryboard(name: "LanConfiguration", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "LanConfigurationViewController")
        }
        else if DashboardItemKeys.sdWan == itemId {
            let sb = UIStoryboard(name: "SdWanCellularStats", bundle: nil)
            vcToOpen = sb.instantiateViewController(withIdentifier: "SdWanCellularStatsViewController")
        }

        if let vc = vcToOpen {
            dashVc.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        // Handle power and analytics
        if DashboardItemKeys.powerItem == itemId {
            showPowerSheet(vc: dashVc)
            return
        }
        if DashboardItemKeys.mediaItem == itemId {
            showAnalyticsStatus(for: "media", dashVc: dashVc)
            return
        }
        else if DashboardItemKeys.retailItem == itemId {
            showAnalyticsStatus(for: "retail", dashVc: dashVc)
            return
        }
        
        
        //print("Error: Could not open \(itemId)")
    }
}

// MARK: - Power Management
extension DashViewModel {
    private func showPowerSheet(vc: DashViewController) {
        // If its iPad show the alert as an alert, not a sheet
        var style = UIAlertController.Style.actionSheet
        if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
            style = UIAlertController.Style.alert
        }
        
        let actions = UIAlertController(title: "Power options".localized(), message: nil, preferredStyle: style)
        actions.addAction(UIAlertAction(title: "Restart".localized(), style: .default, handler:{ alert in
            vc.showRestartPrompt {
                if let hub = HubDataModel.shared.connectedVeeaHub {
                    self.restart(hub: hub, vc: vc)
                }
            }
        }))
        actions.addAction(UIAlertAction(title: "Shutdown".localized(), style: .default, handler: { alert in
            self.showShutdownPrompt(vc: vc)
        }))
        actions.addAction(UIAlertAction.init(title: "Recover".localized(), style: .destructive, handler: { alert in
            self.showDestructiveOptions(dashVc: vc)
        }))
        
        actions.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        
        vc.present(actions, animated: true)
        actions.view.tintColor = Utils.globalTint()
    }
    
    private func showDestructiveOptions(dashVc: DashViewController) {
        var vcToOpen: UIViewController?
        let sb = UIStoryboard(name: "RecoveryOptions", bundle: nil)
        vcToOpen = sb.instantiateViewController(withIdentifier: "BootstrapViewController")
        if let vc = vcToOpen {
            dashVc.navigationController?.pushViewController(vc, animated: true)
            return
        }
    }
    
    private func showShutdownPrompt(vc: DashViewController) {
        guard let hub = HubDataModel.shared.connectedVeeaHub else {
            //print("No IES")
            return
        }
        
        let alert = UIAlertController(title: "Shut Down Hub".localized(),
                                      message: "Are you sure you want to shut this VeeaHub down?".localized(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Shutdown".localized(), style: .destructive, handler: { alert in
            self.shutDown(hub: hub, vc: vc)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        
        vc.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Utils.globalTint()
    }
    
    private func nilDataMembersAndRefresh() {
        HubDataModel.shared.nilAllDataMembers()
    }
    
    private func restart(hub: HubConnectionDefinition, vc: DashViewController) {
        PowerCommands.restart(hub: hub) { success, message in
            if !success {
                showAlert(with: "Could not restart".localized(), message: message)
                return
            }

            vc.showInfoMessage(message: "Disconnecting & restarting\nThis can take a few minutes".localized())
            self.disconnectAndPop(vc: vc)
        }
    }
    
    private func shutDown(hub: HubConnectionDefinition, vc: DashViewController) {
        PowerCommands.shutdown(hub: hub) { success, message in
            if !success {
                showAlert(with: "Could not shutdown".localized(), message: message)
                return
            }

            self.disconnectAndPop(vc: vc)
        }
    }

    private func disconnectAndPop(vc: DashViewController) {
        // Disconnect from wifi
        HubApWifiConnectionManager.shared.currentlyConnectedHub = nil
        WiFi.disconnectFromAllNetworks()

        self.nilDataMembersAndRefresh()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            vc.popToRootAnimated()
        }
    }
}

// MARK: - Analytics
extension DashViewModel {
    private  func showAnalyticsStatus(for name: String, dashVc: DashViewController) {
        let locked = (name == "media") ? HubDataModel.shared.baseDataModel?.analyticsConfig?.media_analytics_locked : HubDataModel.shared.baseDataModel?.analyticsConfig?.retail_analytics_locked
        let enabled = !locked!
        
        let enabledTitle = enabled ? "Enabled" : "Enable"
        let disabledTitle = enabled ? "Disable" : "Disabled"
        
        let statusTitle = enabled ? enabledTitle : disabledTitle
        let toggleTitle = enabled ? disabledTitle : enabledTitle
        
        let statusAction = UIAlertAction(title: statusTitle, style: .default)
        statusAction.isEnabled = false
        
        let toggleAction = UIAlertAction(title: toggleTitle, style: .default) { _ in
            NSLog("toggle: \(name) -> \(toggleTitle)")
            if name == "media" {
                HubDataModel.shared.baseDataModel?.analyticsConfig?.media_analytics_locked = !locked!
            } else {
                HubDataModel.shared.baseDataModel?.analyticsConfig?.retail_analytics_locked = !locked!
            }
            
            guard let ies = HubDataModel.shared.connectedVeeaHub,
                let analytics = HubDataModel.shared.baseDataModel?.analyticsConfig else {
                //print("No Hub")
                return
            }
            
            ApiFactory.api.setConfig(connection: ies, config: analytics) { (result, error) in
                NSLog("result=\(String(describing: result)), error=\(String(describing: error))") // TODO: handle error
            }
        }
        toggleAction.isEnabled = true
        
        let alert = UIAlertController(title: "\(name.capitalized) Analytics", message: nil, preferredStyle: .actionSheet)
        alert.addAction(statusAction)
        alert.addAction(toggleAction)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        
        dashVc.present(alert, animated: true, completion: nil)
        alert.view.tintColor = Utils.globalTint()
    }
}
