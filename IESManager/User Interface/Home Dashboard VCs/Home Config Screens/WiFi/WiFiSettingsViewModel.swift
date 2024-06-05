//
//  WiFiSettingsViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 11/04/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

class WiFiSettingsViewModel: HomeUserBaseViewModel {
    let mesh: VHMesh
    private let meshDetailViewModel: MeshDetailViewModel
    var aps = HomeWifiAps()
    
    init(mesh: VHMesh, meshDetailViewModel: MeshDetailViewModel) {
        self.mesh = mesh
        self.meshDetailViewModel = meshDetailViewModel
    }
    
    var men: NodeTableCellModel? {
        return meshDetailViewModel.men
    }
    
    func getConnectionInfoForModel(_ model: NodeTableCellModel) -> ConnectionInfo {
        let connectionInfo = ConnectionInfo.init(selectedMesh: meshDetailViewModel.mesh,
                                                 selectedMeshNode: model.device,
                                                 veeaHub: model.veeaHub,
                                                 isAvailableForConnection: model.isAvailableOnMas.data)
        
        return connectionInfo
    }
    
    var wifiName: String {
        aps.primaryAp.ssid
    }
    
    var pwd: String {
        aps.primaryAp.pass
    }

    var guestWifiName: String {
        aps.guestAp.ssid
    }

    var guestPwd: String {
        aps.guestAp.pass
    }

    var showGoToAdvancedSettings: Bool {
        if !primaryApIsPreSharedKey {
            return true
        }
        else if !aps2GhzAnd5GhzDetailsSame {
            return true
        }

        return false
    }

    func updateApModel() {
        self.aps = HomeWifiAps() // New aps model with the updated models
        self.informObserversOfChange(type: .dataModelUpdated)
    }

    var primaryApIsPreSharedKey: Bool {
        aps.primaryAp.secureMode == .preSharedPsk
    }

    var aps2GhzAnd5GhzDetailsSame: Bool {
        aps.is2GhzAnd5GhzDetailsSame
    }

    func resetToDefaultValues() {
        // Reset the security mode
        aps.primaryAp.secureMode = .preSharedPsk
        aps.primaryAp5Ghz.secureMode = .preSharedPsk
        aps.guestAp.secureMode = .preSharedPsk
        aps.guestAp5Ghz.secureMode = .preSharedPsk

        // Update he appropriate place in the config.
        let primaryApIndex = aps.primaryApIndex
        let guestApIndex = aps.guestApIndex

        let primaryAp5GhzIndex = aps.primaryAp5GhzIndex
        let guestAp5GhzIndex = aps.guestAp5GhzIndex
        
        guard var config = HubDataModel.shared.baseDataModel!.meshAPConfig else {
            informObserversOfChange(type: .sendingDataFailed("No Data model"))
            return
        }

        // 2.4 Ghz
        switch primaryApIndex {
        case 0:
            config.ap_1_1 = aps.primaryAp
            break
        case 1:
            config.ap_1_2 = aps.primaryAp
            break
        case 2:
            config.ap_1_3 = aps.primaryAp
            break
        case 3:
            config.ap_1_4 = aps.primaryAp
            break
        case 4:
            config.ap_1_5 = aps.primaryAp
            break
        case 5:
            config.ap_1_6 = aps.primaryAp
            break
        default:
            break
        }

        switch guestApIndex {
        case 0:
            config.ap_1_1 = aps.guestAp
            break
        case 1:
            config.ap_1_2 = aps.guestAp
            break
        case 2:
            config.ap_1_3 = aps.guestAp
            break
        case 3:
            config.ap_1_4 = aps.guestAp
            break
        case 4:
            config.ap_1_5 = aps.guestAp
            break
        case 5:
            config.ap_1_6 = aps.guestAp
            break
        default:
            break
        }

        // 5Ghz
        switch primaryAp5GhzIndex {
        case 0:
            config.ap_2_1 = aps.primaryAp5Ghz
            break
        case 1:
            config.ap_2_2 = aps.primaryAp5Ghz
            break
        case 2:
            config.ap_2_3 = aps.primaryAp5Ghz
            break
        case 3:
            config.ap_2_4 = aps.primaryAp5Ghz
            break
        case 4:
            config.ap_2_5 = aps.primaryAp5Ghz
            break
        case 5:
            config.ap_2_6 = aps.primaryAp5Ghz
            break
        default:
            break
        }

        switch guestAp5GhzIndex {
        case 0:
            config.ap_2_1 = aps.guestAp5Ghz
            break
        case 1:
            config.ap_2_2 = aps.guestAp5Ghz
            break
        case 2:
            config.ap_2_3 = aps.guestAp5Ghz
            break
        case 3:
            config.ap_2_4 = aps.guestAp5Ghz
            break
        case 4:
            config.ap_2_5 = aps.guestAp5Ghz
            break
        case 5:
            config.ap_2_6 = aps.guestAp5Ghz
            break
        default:
            break
        }

        sendConfig(config: config)
    }

    func sendGuestNetworkEnableUpdate(enabled: Bool,
                                      completion: @escaping(Bool) -> Void) {

        aps.guestAp.enabled = enabled
        aps.guestAp5Ghz.enabled = enabled

        // Apply the changes to the config
        let guestApIndex = aps.guestApIndex
        let guestAp5GhzIndex = aps.guestAp5GhzIndex

        guard var config = HubDataModel.shared.baseDataModel!.meshAPConfig else {
            completion(false)
            return
        }

        switch guestApIndex {
        case 0:
            config.ap_1_1 = aps.guestAp
            break
        case 1:
            config.ap_1_2 = aps.guestAp
            break
        case 2:
            config.ap_1_3 = aps.guestAp
            break
        case 3:
            config.ap_1_4 = aps.guestAp
            break
        case 4:
            config.ap_1_5 = aps.guestAp
            break
        case 5:
            config.ap_1_6 = aps.guestAp
            break
        default:
            break
        }

        switch guestAp5GhzIndex {
        case 0:
            config.ap_2_1 = aps.guestAp5Ghz
            break
        case 1:
            config.ap_2_2 = aps.guestAp5Ghz
            break
        case 2:
            config.ap_2_3 = aps.guestAp5Ghz
            break
        case 3:
            config.ap_2_4 = aps.guestAp5Ghz
            break
        case 4:
            config.ap_2_5 = aps.guestAp5Ghz
            break
        case 5:
            config.ap_2_6 = aps.guestAp5Ghz
            break
        default:
            break
        }

        sendConfigWithCallback(config: config,
                               completion: completion)
    }
}

// MARK: - TableView rendering
extension WiFiSettingsViewModel {

    func headerForSection(section: Int) -> String {
        if section == 0 { return "Primary Network" }
        return "Guest Network"
    }
}
