//
//  NodeCapabilities+ACS.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 22/04/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

// MARK: - ACS
extension NodeCapabilities {
    
    // MARK: - AP DETAILS
    
    public var ap1AcsSupport: Bool {
        if let ap = capabilityForKey(key: DbNodeCapabilities.apKey) {
            if let sourceJson = ap.sourceJson {
                return boolFor(key: DbNodeCapabilities.acsSupport, in: sourceJson)
            }
        }
        
        return false
    }
    
    public var ap2AcsSupport: Bool {
        if let ap = capabilityForKey(key: DbNodeCapabilities.ap2Key) {
            if let sourceJson = ap.sourceJson {
                return boolFor(key: DbNodeCapabilities.acsSupport, in: sourceJson)
            }
        }
        
        return false
    }
    
    public var ap1DfsSupport: Bool {
        if let ap = capabilityForKey(key: DbNodeCapabilities.apKey) {
            if let sourceJson = ap.sourceJson {
                return boolFor(key: DbNodeCapabilities.dfsSupport, in: sourceJson)
            }
        }
        
        return false
    }
    
    public var ap2DfsSupport: Bool {
        if let ap = capabilityForKey(key: DbNodeCapabilities.ap2Key) {
            if let sourceJson = ap.sourceJson {
                return boolFor(key: DbNodeCapabilities.dfsSupport, in: sourceJson)
            }
        }
        
        return false
    }
    
    public var unii1AndDfsCh_Ap1: Bool {
        let chars = ap1Charateristics
        
        return chars?.unii1AndDfsCh ?? false
    }
    
    public var unii1AndDfsCh_Ap2: Bool {
        let chars = ap2Charateristics
        
        return chars?.unii1AndDfsCh ?? false
    }
}
