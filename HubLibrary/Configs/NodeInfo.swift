//
//  IesInfo.swift
//  HubLibrary
//
//  Created by Al on 03/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/** 
 General IES information 
 */
public struct NodeInfo: TopLevelJSONResponse, Codable {
    var originalJson: JSON = JSON()

    /// - nodeName: the name of the IES
    public internal(set) var node_name: String
    
    /// - nodeTime: the time last registered on the IES
    public internal(set) var node_time: String
    
    /// - osVersion: the IES's OS version
    public internal(set) var os_version: String
    
    /// - restartTime: the UTC time the IES was last restarted
    public internal(set) var reboot_time: String
    
    /// - restartReason: the reason that the IES was restarted
    public internal(set) var reboot_reason: String
    
    /// - softwareVersion: the IES's software version
    public internal(set) var sw_version: String
    
    /// - unitHardwareVersion: the IES's hardware version
    public internal(set) var unit_hardware_version: String
    
    /// - unitHardwareRevision: the IES's hardware revision
    public internal(set) var unit_hardware_revision: String

    /// - units MacAddress
    @DecodableDefault.EmptyString var node_mac: String
    
    /// - unitSerialNumber: the IES's hardware serial number
    public internal(set) var unit_serial_number: String
    
    public internal(set) var product_model: String
    
    @DecodableDefault.EmptyString var bluetooth_address: String
    
    @DecodableDefault.EmptyString var lte_driver_version: String
    
    @DecodableDefault.EmptyString var lte_firmware_version: String
    
    @DecodableDefault.EmptyString var product_lte_backhaul: String
    
    private enum CodingKeys: String, CodingKey {
     case node_name,
          node_time,
          os_version,
          reboot_time,
          reboot_reason,
          sw_version,
          unit_hardware_version,
          unit_hardware_revision,
          unit_serial_number,
          product_model,
          bluetooth_address,
          lte_driver_version,
          lte_firmware_version,
          product_lte_backhaul,
          node_mac
     }
}

extension NodeInfo: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeInfo.getTableName()] = getUpdateJson()

        return json
    }
    
    private func getUpdateJson() -> JSON {
        var vals = originalJson
        for (index, element) in NodeInfo.getAllKeys().enumerated() {
            vals[element] = getAllValues()[index]
        }
        
        return vals
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = NodeInfo.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public func getTableName() -> String {
        return NodeInfo.getTableName()
    }
    
    public func getAllKeys() -> [String] {
        return NodeInfo.getAllKeys()
    }
    
    public func getAllValues() -> [Any] {
        var values = [Any]()
        values.append(node_name)
        values.append(sw_version)
        values.append(os_version)
        values.append(node_time)
        values.append(reboot_time)
        values.append(reboot_reason)
        values.append(unit_hardware_revision)
        values.append(unit_hardware_version)
        values.append(unit_serial_number)
        
        return values
    }
    
    public static func getTableName() -> String {
        return DbNodeInfo.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        keys.append(DbNodeInfo.NodeName)
        keys.append(DbNodeInfo.SoftwareVersion)
        keys.append(DbNodeInfo.OSVersion)
        keys.append(DbNodeInfo.NodeTime)
        keys.append(DbNodeInfo.NodeTimeTrigger)
        keys.append(DbNodeInfo.RebootTime)
        keys.append(DbNodeInfo.RebootReason)
        keys.append(DbNodeInfo.UnitHardwareRevision)
        keys.append(DbNodeInfo.UnitHardwareVersion)
        keys.append(DbNodeInfo.UnitSerialNumber)
        keys.append(DbNodeInfo.ProductModel)
        
        return keys
    }
}
