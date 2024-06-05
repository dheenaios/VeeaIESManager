//
//  NodeConfigWifiScan.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 24/04/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

/// A convenience sub configuration to allow quick setting of channel scan
/// related runctionality.
/// This model is not included on the HubDataModel and should be intialised from the NodeConfig json
/// Note that these properties are also included in NodeConfig
/// - access2_acs_exclude_dfs if 5ghz
/// - access_restart_trigger
public struct NodeConfigWifiScan: TopLevelJSONResponse, Codable {
    
    var originalJson: JSON = JSON()
    
    public var accessRestartTrigger: Bool
    public var vmeshRestartTrigger: Bool
    public var access1_acs_rescanTrigger: Bool
    public var access2_acs_rescanTrigger: Bool
    public var vmesh_acs_rescanTrigger: Bool
    public var vmesh_bkgnd_scan: Bool
    public var access1_bkgnd_scan: Bool
    public var access2_bkgnd_scan: Bool
    
    private enum CodingKeys: String, CodingKey {
        case accessRestartTrigger, vmeshRestartTrigger,access1_acs_rescanTrigger,access2_acs_rescanTrigger,vmesh_acs_rescanTrigger, vmesh_bkgnd_scan, access1_bkgnd_scan, access2_bkgnd_scan
    }
    
    /// Initialise from the NodeConfig Original JSON.
    init(from json: JSON) {
        originalJson = json
        accessRestartTrigger = JSONValidator.valiate(key: DbNodeConfig.AccessRestartTrigger,
                                                     json: json,
                                                     expectedType:Bool.self,
                                                     defaultValue: false) as! Bool
        
        vmeshRestartTrigger = JSONValidator.valiate(key: DbNodeConfig.vmesh_restart_trigger,
                                                    json: json,
                                                    expectedType:Bool.self,
                                                    defaultValue: false) as! Bool
        access1_acs_rescanTrigger = JSONValidator.valiate(key: DbNodeConfig.access1_acs_rescan,
                                                     json: json,
                                                     expectedType:Bool.self,
                                                     defaultValue: false) as! Bool
        access2_acs_rescanTrigger = JSONValidator.valiate(key: DbNodeConfig.access2_acs_rescan,
                                                     json: json,
                                                     expectedType:Bool.self,
                                                     defaultValue: false) as! Bool
        vmesh_acs_rescanTrigger = JSONValidator.valiate(key: DbNodeConfig.vmesh_acs_rescan,
                                                     json: json,
                                                     expectedType:Bool.self,
                                                     defaultValue: false) as! Bool
        
        access1_bkgnd_scan = JSONValidator.valiate(key: DbNodeConfig.access1_bkgnd_scan,
                                                     json: json,
                                                     expectedType:Bool.self,
                                                     defaultValue: false) as! Bool
        access2_bkgnd_scan = JSONValidator.valiate(key: DbNodeConfig.access2_bkgnd_scan,
                                                     json: json,
                                                     expectedType:Bool.self,
                                                     defaultValue: false) as! Bool
        
        vmesh_bkgnd_scan = JSONValidator.valiate(key: DbNodeConfig.vmesh_bkgnd_scan,
                                                     json: json,
                                                     expectedType:Bool.self,
                                                     defaultValue: false) as! Bool
    }
    
    func getUpdateJSON() -> JSON {
        var json = JSON()
        
        json[DbNodeConfig.AccessRestartTrigger] = accessRestartTrigger
        json[DbNodeConfig.vmesh_restart_trigger] = vmeshRestartTrigger
        json[DbNodeConfig.access1_acs_rescan] = access1_acs_rescanTrigger
        json[DbNodeConfig.access2_acs_rescan] = access2_acs_rescanTrigger
        json[DbNodeConfig.vmesh_acs_rescan] = vmesh_acs_rescanTrigger
        json[DbNodeConfig.access1_bkgnd_scan] = access1_bkgnd_scan
        json[DbNodeConfig.access2_bkgnd_scan] = access2_bkgnd_scan
        json[DbNodeConfig.vmesh_bkgnd_scan] = vmesh_bkgnd_scan

        return json
    }
}

extension NodeConfigWifiScan: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbNodeConfig.TableName
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeConfig.getTableName()] = getUpdateJSON()
        
        return json
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        var njson = originalJson
        njson[DbNodeConfig.AccessRestartTrigger] = accessRestartTrigger
        njson[DbNodeConfig.vmesh_restart_trigger] = vmeshRestartTrigger
        njson[DbNodeConfig.access1_acs_rescan] = access1_acs_rescanTrigger
        njson[DbNodeConfig.access2_acs_rescan] = access2_acs_rescanTrigger
        njson[DbNodeConfig.vmesh_acs_rescan] = vmesh_acs_rescanTrigger
        njson[DbNodeConfig.access1_bkgnd_scan] = access1_bkgnd_scan
        njson[DbNodeConfig.access2_bkgnd_scan] = access2_bkgnd_scan
        njson[DbNodeConfig.vmesh_bkgnd_scan] = vmesh_bkgnd_scan
        
        let tableName = NodeConfigWifiScan.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                      targetJson: njson,
                                                      tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
}
