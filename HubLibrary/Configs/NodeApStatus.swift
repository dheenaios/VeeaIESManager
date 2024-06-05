//
//  NodeApStatus.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 27/01/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

public struct NodeApStatus: TopLevelJSONResponse, Equatable, Codable {
    public static func == (lhs: NodeApStatus, rhs: NodeApStatus) -> Bool {
        return lhs.ap1 == rhs.ap1 &&
            lhs.ap_1_1 == rhs.ap_1_1 &&
            lhs.ap_1_2 == rhs.ap_1_2 &&
            lhs.ap_1_3 == rhs.ap_1_3 &&
            lhs.ap_1_4 == rhs.ap_1_4 &&
            lhs.ap_1_5 == rhs.ap_1_5 &&
            lhs.ap_1_6 == rhs.ap_1_6 &&
            lhs.ap2 == rhs.ap2 &&
            lhs.ap_2_1 == rhs.ap_2_1 &&
            lhs.ap_2_2 == rhs.ap_2_2 &&
            lhs.ap_2_3 == rhs.ap_2_3 &&
            lhs.ap_2_4 == rhs.ap_2_4 &&
            lhs.ap_2_5 == rhs.ap_2_5 &&
            lhs.ap_2_6 == rhs.ap_2_6
    }
    
    let ap1: NodeApStatusAp
    let ap2: NodeApStatusAp
    let ap_1_1: NodeApStatusApX_X
    let ap_1_2: NodeApStatusApX_X
    let ap_1_3: NodeApStatusApX_X
    let ap_1_4: NodeApStatusApX_X
    let ap_1_5: NodeApStatusApX_X
    let ap_1_6: NodeApStatusApX_X
    let ap_2_1: NodeApStatusApX_X
    let ap_2_2: NodeApStatusApX_X
    let ap_2_3: NodeApStatusApX_X
    let ap_2_4: NodeApStatusApX_X
    let ap_2_5: NodeApStatusApX_X
    let ap_2_6: NodeApStatusApX_X
    
    private enum CodingKeys: String, CodingKey {
        case ap1,
             ap2,
             ap_1_1,
             ap_1_2,
             ap_1_3,
             ap_1_4,
             ap_1_5,
             ap_1_6,
             ap_2_1,
             ap_2_2,
             ap_2_3,
             ap_2_4,
             ap_2_5,
             ap_2_6
    }
    
    var allAP1s: [NodeApStatusApX_X] {
        return [ap_1_1, ap_1_2, ap_1_3, ap_1_4, ap_1_5, ap_1_6]
    }
    
    var allAP2s: [NodeApStatusApX_X] {
        return [ap_2_1, ap_2_2, ap_2_3, ap_2_4, ap_2_5, ap_2_6]
    }
    
    var originalJson: JSON = JSON()
    
    public static func getTableName() -> String {
        return DbNodeApStatus.TableName
    }
}

struct NodeApStatusAp: Equatable, Codable {
    static func == (lhs: NodeApStatusAp, rhs: NodeApStatusAp) -> Bool {
        return lhs.fitted == rhs.fitted &&
            lhs.bssid == rhs.bssid &&
            lhs.mac == rhs.mac &&
            lhs.opstate == rhs.opstate
    }
    
    let fitted: Bool
    let bssid: String
    let mac: String
    let opstate: Bool
    
    private var originalJson: JSON = JSON()
    
    private enum CodingKeys: String, CodingKey {
        case fitted, bssid, mac, opstate
    }
}

struct NodeApStatusApX_X: Equatable, Codable {
    static func == (lhs: NodeApStatusApX_X, rhs: NodeApStatusApX_X) -> Bool {
        return lhs.timestamp == rhs.timestamp &&
            lhs.mac == rhs.mac &&
            lhs.opstate == rhs.opstate
    }
    
    let mac: String
    var opstate: Bool
    let timestamp: Int
    
    private enum CodingKeys: String, CodingKey {
        case mac, timestamp, opstate
    }
    
    private var originalJson: JSON = JSON()
}
