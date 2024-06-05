//
//  NodeCapabilities+ApCharateristics.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 14/11/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

extension NodeCapabilities {
    
    public var isAP1Available: Bool {
        get {
            return hasCapabilityForKey(key: DbNodeCapabilities.PhysicalAP1Key)
        }
    }
    
    public var isAP2Available: Bool {
        get {
            return hasCapabilityForKey(key: DbNodeCapabilities.PhysicalAP2Key)
        }
    }
    
    public var ap1Charateristics: ApRadioCharacteristics? {
        get {
            if let ap = capabilityForKey(key: DbNodeCapabilities.apKey) {
                if let sourceJson = ap.sourceJson {
                    let apC = ApRadioCharacteristics.init(apNum: 1, json: sourceJson)
                    
                    return apC
                }
            }
            
            return nil
        }
    }
    
    public var ap2Charateristics: ApRadioCharacteristics? {
        get {
            if let ap = capabilityForKey(key: DbNodeCapabilities.ap2Key) {
                if let sourceJson = ap.sourceJson {
                    let apC = ApRadioCharacteristics.init(apNum: 2, json: sourceJson)
                    
                    return apC
                }
            }
            
            return nil
        }
    }
}

public struct ApRadioCharacteristics {
    public let apNumber: Int
    public let meshRadio: Bool
    public let singleBand: Bool
    public let multiRadio: Bool
    public let unii1AndDfsCh: Bool
    public let accessSupports801_22ax: Bool
    
    init(apNum: Int, json: JSON) {
        apNumber = apNum
        
        meshRadio = JSONValidator.valiate(key: DbNodeCapabilities.meshRadioKey,
                                          json: json,
                                          expectedType: Bool.self,
                                          defaultValue: false) as! Bool
        
        singleBand = JSONValidator.valiate(key: DbNodeCapabilities.singleBand,
                                          json: json,
                                          expectedType: Bool.self,
                                          defaultValue: false) as! Bool
        
        multiRadio = JSONValidator.valiate(key: DbNodeCapabilities.multiRadio,
                                          json: json,
                                          expectedType: Bool.self,
                                          defaultValue: false) as! Bool
        
        unii1AndDfsCh = JSONValidator.valiate(key: DbNodeCapabilities.unii1_and_dfs_ch,
                                              json: json,
                                              expectedType: Bool.self,
                                              defaultValue: false) as! Bool
        
        accessSupports801_22ax = JSONValidator.valiate(key: DbNodeCapabilities.supports80211ax,
                                              json: json,
                                              expectedType: Bool.self,
                                              defaultValue: false) as! Bool
    }
}
