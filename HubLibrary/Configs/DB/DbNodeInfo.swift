//
//  NodeInfo.swift
//  HubLibrary
//
//  Created by Al on 03/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

struct DbNodeInfo: DbSchemaProtocol {
    static let TableName = "node_info";
    
    static let NodeName = "node_name"
    static let SoftwareVersion = "sw_version"
    static let OSVersion = "os_version"
    static let NodeTime = "node_time"
    static let NodeTimeTrigger = "node_time_trigger"
    static let RebootTime = "reboot_time"
    static let RebootReason = "reboot_reason"
    static let UnitHardwareRevision = "unit_hardware_revision"
    static let UnitHardwareVersion = "unit_hardware_version"
    static let UnitSerialNumber = "unit_serial_number"
    static let ProductModel = "product_model"
    static let NODE_MAC = "node_mac"
    static let BLUETOOTH_ADDRESS = "bluetooth_address"
    
    static let LTE_DRIVER_VERSION = "lte_driver_version"
    static let LTE_FIRMWARE_VERSION = "lte_firmware_version"
    static let PRODUCT_LTE_BACKHAUL = "product_lte_backhaul"
}
