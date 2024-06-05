//
//  DbNodeControl.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 10/04/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

struct DbNodeControl: DbSchemaProtocol {
    static let TableName = "node_control"
    
    static let REBOOT_TRIGGER = "reboot_trigger"
    static let REINSTALL_TRIGGER = "reinstall_trigger"
    static let REBOOT_DELAY = "reboot_delay"
    static let REBOOT_ERROR_CTRL = "reboot_error_ctrl"
    static let REBOOT_REASON = "reboot_reason"
    static let RECOVERY_TRIGGER = "recovery_trigger"
    static let SHUTDOWN_TRIGGER = "shutdown_trigger"
}
