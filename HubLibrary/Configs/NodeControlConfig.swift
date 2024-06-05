//
//  NodeControlConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 10/04/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

public struct NodeControlConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    public private(set) var reboot_trigger: Bool
    public private(set) var reinstall_trigger: Bool
    public private(set) var shutdown_trigger: Bool
    public private(set) var recovery_trigger: Bool
    
    public private(set) var reboot_delay: Int
    public private(set) var reboot_reason: String
    
    public static func == (lhs: NodeControlConfig, rhs: NodeControlConfig) -> Bool {
        return lhs.reboot_trigger == rhs.reboot_trigger &&
            lhs.reinstall_trigger == rhs.reinstall_trigger &&
            lhs.shutdown_trigger == rhs.shutdown_trigger &&
            lhs.recovery_trigger == rhs.recovery_trigger &&
            lhs.reboot_delay == rhs.reboot_delay &&
            lhs.reboot_reason == rhs.reboot_reason
    }
    
    private enum CodingKeys: String, CodingKey {
        case reboot_trigger, reinstall_trigger, shutdown_trigger, recovery_trigger, reboot_delay, reboot_reason
    }
    
    func getUpdateJSON() -> JSON {
        var json = originalJson
        json[DbNodeControl.REBOOT_TRIGGER] = reboot_trigger
        json[DbNodeControl.REINSTALL_TRIGGER] = reinstall_trigger
        json[DbNodeControl.SHUTDOWN_TRIGGER] = shutdown_trigger
        json[DbNodeControl.RECOVERY_TRIGGER] = recovery_trigger
        json[DbNodeControl.REBOOT_DELAY] = reboot_delay
        json[DbNodeControl.REBOOT_REASON] = reboot_reason
        
        return json
    }
    
    public mutating func resetAllTriggers() {
        reboot_trigger = false
        reinstall_trigger = false
        shutdown_trigger = false
        recovery_trigger = false
    }
}

extension NodeControlConfig {
    public mutating func setRebootTrigger() {
        reboot_trigger = true
    }
    
    public mutating func setShutdownTrigger() {
        shutdown_trigger = true
    }
    
    public mutating func setRecoveryTrigger() {
        recovery_trigger = true
    }
    
    public mutating func setReinstallTrigger() {
        reinstall_trigger = true
    }
}

extension NodeControlConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbNodeControl.TableName
    }

    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[NodeControlConfig.getTableName()] = getUpdateJSON()
        
        return json
    }
    
    public func getMasUpdate() -> MasUpdate? {
        let ojson = originalJson
        let njson = getUpdateJSON()
        let tableName = NodeControlConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                     targetJson: njson,
                                                     tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
}
