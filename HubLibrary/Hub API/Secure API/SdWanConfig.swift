//
//  SdWanConfig.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 07/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

public struct SdWanConfig: TopLevelJSONResponse, Equatable, Codable {
    var originalJson: JSON = JSON()
    
    public var backhauls: [String : SdWanBackhaulConfig]
    
    public var cellularBackHaulConfig: SdWanBackhaulConfig?
    public var wifiBackHaulConfig: SdWanBackhaulConfig?
    public var ethernetBackHaulConfig: SdWanBackhaulConfig?
    
    public var isEmpty: Bool {
        return backhauls.isEmpty
    }
    
    private enum CodingKeys: String, CodingKey {
        case backhauls
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backhauls = try container.decode([String : SdWanBackhaulConfig].self, forKey: .backhauls)
        
        if let val = backhauls[DbNodeSdWan.BackhaulKeys.CellularBackhaulKey] {
            cellularBackHaulConfig = val
        }
        
        if let val = backhauls[DbNodeSdWan.BackhaulKeys.WifiBackhaulKey] {
            wifiBackHaulConfig = val
        }
        
        if let val = backhauls[DbNodeSdWan.BackhaulKeys.EthernetBackhaulKey] {
            ethernetBackHaulConfig = val
        }
    }
    
    public static func == (lhs: SdWanConfig, rhs: SdWanConfig) -> Bool {
        return lhs.cellularBackHaulConfig == rhs.cellularBackHaulConfig &&
            lhs.wifiBackHaulConfig == rhs.wifiBackHaulConfig &&
            lhs.ethernetBackHaulConfig == rhs.ethernetBackHaulConfig
    }
}

extension SdWanConfig: ApiRequestConfigProtocol {
    public static func getTableName() -> String {
        return DbNodeSdWan.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        keys.append(DbNodeSdWan.BackHauls)
        
        return keys
    }
    
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        
        json[DbNodeSdWan.BackHauls] = getUpdateJSON()
        
        var returnJson = SecureUpdateJSON()
        returnJson[SdWanConfig.getTableName()] = json
        return returnJson
    }
    
    // TODO: THIS ONE IS A LITTLE MORE COMPLEX THAN NORMAL. REVIEW
    public func getMasUpdate() -> MasUpdate? {
        // Make some JSON to act as the basis for the patch
        var ojson = JSON()
        ojson[DbNodeSdWan.BackhaulKeys.CellularBackhaulKey] = JSON()
        ojson[DbNodeSdWan.BackhaulKeys.WifiBackhaulKey] = JSON()
        ojson[DbNodeSdWan.BackhaulKeys.EthernetBackhaulKey] = JSON()
        
        let njson = getUpdateJSON()
        let tableName = MeshPortConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                      targetJson: njson,
                                                      tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    private func getUpdateJSON() -> JSON {
        var json = JSON()
        
        json[DbNodeSdWan.BackhaulKeys.CellularBackhaulKey] = cellularBackHaulConfig?.getUpdateJSON()
        json[DbNodeSdWan.BackhaulKeys.WifiBackhaulKey] = wifiBackHaulConfig?.getUpdateJSON()
        json[DbNodeSdWan.BackhaulKeys.EthernetBackhaulKey] = ethernetBackHaulConfig?.getUpdateJSON()
        
        return json
    }
}

// MARK: - SD Wan Backhaul Config

public struct SdWanBackhaulConfig: Codable {
    
    public enum BackHaulState {
        case Active
        case ActiveFailing
        case Inactive
        case InactiveSucceding
    }
    
    public var backHaulStateType: BackHaulState {
        switch backhaul_state {
        case 1:
            return .Active
        case 2:
            return .ActiveFailing
        case 3:
            return .Inactive
        case 4:
            return .InactiveSucceding
        default:
            return .Active
        }
    }
    
    public var alive: Bool
    public var backhaul_state: Int
    @DecodableDefault.Zero var disable_time_out: Int
    public var interface: String
    public var is_ppp: Bool
    public var last_state_change: Int
    public var last_successful_test: Int
    public var last_unsuccessful_test: Int
    
    public var last_test_result: Bool
    public var last_test_time: Int
    
    public var locked: Bool
    public var priority: Int
    public var reenable_timeout: Int
    public var restricted: Bool
    
    public var test: SdWanBackhaulTestConfig
    
    fileprivate func getUpdateJSON() -> JSON {
        var json = JSON()
        
        json[DbNodeSdWan.BackhaulPropertyKeys.alive] = alive
        json[DbNodeSdWan.BackhaulPropertyKeys.backhaul_state] = backhaul_state
        json[DbNodeSdWan.BackhaulPropertyKeys.disable_timeout] = disable_time_out
        json[DbNodeSdWan.BackhaulPropertyKeys.interface] = interface
        json[DbNodeSdWan.BackhaulPropertyKeys.is_ppp] = is_ppp
        json[DbNodeSdWan.BackhaulPropertyKeys.last_state_change] = last_state_change
        json[DbNodeSdWan.BackhaulPropertyKeys.last_successful_test] = last_successful_test
        json[DbNodeSdWan.BackhaulPropertyKeys.last_unsuccessful_test] = last_unsuccessful_test
        json[DbNodeSdWan.BackhaulPropertyKeys.last_test_result] = last_test_result
        json[DbNodeSdWan.BackhaulPropertyKeys.last_test_time] = last_test_time
        json[DbNodeSdWan.BackhaulPropertyKeys.locked] = locked
        json[DbNodeSdWan.BackhaulPropertyKeys.priority] = priority
        json[DbNodeSdWan.BackhaulPropertyKeys.reenable_timeout] = reenable_timeout
        json[DbNodeSdWan.BackhaulPropertyKeys.locked] = restricted
        json[DbNodeSdWan.BackhaulPropertyKeys.TestObjectKey] = test.getUpdateJSON()
        
        return json
    }
}

extension SdWanBackhaulConfig: Equatable {
    public static func == (lhs: SdWanBackhaulConfig, rhs: SdWanBackhaulConfig) -> Bool {
        return lhs.alive == rhs.alive &&
            lhs.backhaul_state == rhs.backhaul_state &&
            lhs.disable_time_out == rhs.disable_time_out &&
            lhs.interface == rhs.interface &&
            lhs.is_ppp == rhs.is_ppp &&
            lhs.last_state_change == rhs.last_state_change &&
            lhs.last_successful_test == rhs.last_successful_test &&
            lhs.last_unsuccessful_test == rhs.last_unsuccessful_test &&
            lhs.last_test_result == rhs.last_test_result &&
            lhs.last_test_time == rhs.last_test_time &&
            lhs.locked == rhs.locked &&
            lhs.priority == rhs.priority &&
            lhs.reenable_timeout == rhs.reenable_timeout &&
            lhs.restricted == rhs.restricted &&
            lhs.test == rhs.test
    }
}

// MARK: - SD Wan Backhaul Test Config

public struct SdWanBackhaulTestConfig: Equatable, Codable {
    public var interval: Int
    public var method: String
    public var remote: String
    public var test_inactive: Bool
    public var timeout: Int
    
    fileprivate func getUpdateJSON() -> JSON {
        var json = JSON()
        
        json[DbNodeSdWan.BackhaulPropertyKeys.TestObject.interval] = interval
        json[DbNodeSdWan.BackhaulPropertyKeys.TestObject.method] = method
        json[DbNodeSdWan.BackhaulPropertyKeys.TestObject.remote] = remote
        json[DbNodeSdWan.BackhaulPropertyKeys.TestObject.test_inactive] = test_inactive
        json[DbNodeSdWan.BackhaulPropertyKeys.TestObject.timeout] = timeout
        
        return json
    }
}
