//
//  CellularStatsViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 25/06/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking
import UIKit


class CellularStatsViewModel: BaseConfigViewModel {
    
    private var stats: CellularStats?
    
    struct KeyValueModel {
        var key: String
        var value: String
    }
    
    var tableViewRows: [KeyValueModel] {
        var models = [KeyValueModel]()
        
        guard let stats = stats else {
            return models
        }
        
        models.append(KeyValueModel.init(key: "IMEI", value: stats.imei))
        models.append(KeyValueModel.init(key: "ICCID", value: stats.iccid))
        
        if !stats.current_connect_time.isEmpty {
            models.append(KeyValueModel.init(key: "Connect time".localized(), value: stats.current_connect_time))
        }
        
        models.append(KeyValueModel.init(key: "Network mode".localized(), value: stats.network_mode))
        
        if stats.network_mode == "3G" {
            models.append(KeyValueModel.init(key: "RSCP", value: stats.rscp.description + "dBm"))
            models.append(KeyValueModel.init(key: "RSSI", value: stats.rssi.description + "dBm"))
            models.append(KeyValueModel.init(key: "ECIO", value: stats.ecio.description + "dB"))
            
            models.append(KeyValueModel.init(key: "UARFCN", value: stats.arfcn.description))
        }
        else if stats.network_mode == "4G" {
            models.append(KeyValueModel.init(key: "RSRQ", value: stats.rsrq.description + "dB"))
            models.append(KeyValueModel.init(key: "RSRP", value: stats.rsrp.description))
            models.append(KeyValueModel.init(key: "RSSI", value: stats.rssi.description))
            models.append(KeyValueModel.init(key: "SINR", value: stats.sinr.description + "dB"))
            
            models.append(KeyValueModel.init(key: "EARFCN", value: stats.arfcn.description))
            
            models.append(KeyValueModel.init(key: "Bandwidth Up".localized(), value: stats.bandwidth_ul.description))
            models.append(KeyValueModel.init(key: "Bandwidth Down".localized(), value: stats.bandwidth_ul.description))
            models.append(KeyValueModel.init(key: "Network Operator".localized(), value: stats.network_operator.description))
            models.append(KeyValueModel.init(key: "Srxlev", value: stats.srxlev.description))
            models.append(KeyValueModel.init(key: "Tracking Area Code".localized(), value: stats.tac.description))
        }
        
        if let info = HubDataModel.shared.baseDataModel?.nodeInfoConfig {
            if !info.lte_driver_version.isEmpty {
                models.append(KeyValueModel.init(key: "LTE Driver v.".localized(), value: info.lte_driver_version))
            }

            if !info.lte_firmware_version.isEmpty {
                models.append(KeyValueModel.init(key: "LTE Firmware v.".localized(), value: info.lte_firmware_version))
            }

            if !info.product_lte_backhaul.isEmpty {
                models.append(KeyValueModel.init(key: "Product LTE Backhaul".localized(), value: info.product_lte_backhaul))
            }
            
            if stats.sim_status.isEmpty && stats.network_reg_status.isEmpty {
                return models
            }
            
            models.append(KeyValueModel.init(key: "Sim Status".localized(), value: stats.sim_status))
            models.append(KeyValueModel.init(key: "Network Reg. Status".localized(), value: stats.network_reg_status))
        }
        
        return models
    }
    
    var signalStrengthImage: UIImage {
        switch numberOfBars {
        case 1:
            return UIImage(named: "strength_0_bars")!
        case 2:
            return UIImage(named: "strength_1_bars")!
        case 3:
            return UIImage(named: "strength_2_bars")!
        case 4:
            return UIImage(named: "strength_3_bars")!
        case 5:
            return UIImage(named: "strength_4_bars")!
        default:
            return UIImage(named: "strength_5_bars")!
        }
    }

    var numberOfBars: Int {
        guard let signalLevel = stats?.signal_level else {
            return 0
        }
        
        return CellularStrengthToBars.convert(strengthPercentage: signalLevel)
    }
    
    func updateDataModel(completion: @escaping (CellularStats?, String?) -> Void) {
        if TestsRouter.interceptForMocking {
            self.stats = CellularStats.mock()
            completion(self.stats, nil)
            return
        }

        var hub = connectedHub

        if TestsRouter.interceptForMocking && hub == nil {
            hub = MasConnection(nodeId: 123, baseUrl: "")
        }

        guard let hub = hub else {
            completion(nil, "No connected hub")
            //print("No IES")
            return
        }

        ApiFactory.api.getCellularStats(connection: hub) { (cellularStats, error) in
            
            NSLog("here cellular stats -> \(cellularStats.debugDescription)")
        
            if let stats = cellularStats {
                self.stats = stats
                completion(stats, nil)

            } else if let error = error {
                completion(nil, "error obtaining stats: \(error)")
            }
        }
    }
}


