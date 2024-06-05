//
//  NodeCapabilities+Vmesh.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 11/06/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

// MARK: - Vmesh extensions
extension NodeCapabilities {
    
    public var hasVmeshCapability: Bool {
        return hasCapabilityForKey(key: "vmesh")
    }
    
    public var vmeshDfsSupport: Bool {
        guard let cap = getVmeshCapability()?.sourceJson else {
            return false
        }
        
        return boolFor(key: DbNodeCapabilities.vmeshDfsSupport, in: cap)
    }
    
    public var vmeshAcsSupport: Bool? {
        guard let cap = getVmeshCapability()?.sourceJson else {
            return nil
        }
        
        guard let acsSup = cap[DbNodeCapabilities.vmeshAcsSupport] as? Bool else {
            return nil
        }
        
        return acsSup
    }
    
    public var vmeshName: String {
        guard let cap = getVmeshCapability()?.sourceJson else {
            return ""
        }
        
        return stringFor(key: DbNodeCapabilities.vmeshName, in: cap)
    }
    
    public var radioSelect: Bool {
        guard let cap = getVmeshCapability()?.sourceJson else {
            return false
        }
        
        return boolFor(key: DbNodeCapabilities.radioSelect, in: cap)
    }

    public var hasMeshWdsTopologyTable: Bool {
        get {
            guard let m = originalJson[DbNodeCapabilities.management] as? [String : Any],
                  let tables = m[DbNodeCapabilities.managementTables] as? [String : Any] else {
                return false
            }

            if tables["mesh_wds_topology"] != nil {
                return true
            }

            return false
        }
    }

    public var wdsSupport: Bool {
        guard let cap = getVmeshCapability()?.sourceJson else {
            return false
        }

        return boolFor(key: DbNodeCapabilities.wdsSupport, in: cap)
    }
    
    public var vmeshUnii1AndDfsCh: Bool {
        guard let cap = getVmeshCapability()?.sourceJson else {
            return false
        }
        
        return boolFor(key: DbNodeCapabilities.vmeshUnii1AndDfsCh, in: cap)
    }
    
    public var supportsVeeaHubMixedWiredWirelessDeployments: Bool {
        guard let m = capabilityForKey(key: DbNodeCapabilities.management),
              let rw = m.sourceJson?[DbNodeCapabilities.keysRewritable] as? [String : Any] else {
            return false
        }
//        guard let _ = rw["vmesh_locked_wired"],
//              let _ = rw["vmesh_local_control"] else {
//            return false
//        }
        guard let _ = rw["vmesh_local_control"] else {
            return false
        }
        return true
    }
    
    public var supportForHideAndShowWLANEnabled: Bool {
        guard let m = capabilityForKey(key: DbNodeCapabilities.management),
              let rw = m.sourceJson?[DbNodeCapabilities.keysRewritable] as? [String : Any] else {
            return false
        }
        
        guard let _ = rw["vmesh_locked_wired"] else {
            return false
        }
        
        return true
    }
    
    private func getVmeshCapability() -> NodeCapability? {
        guard let vmesh = capabilityForKey(key: DbNodeCapabilities.VmeshKey) else {
            return nil
        }
        
        return vmesh
    }
    
}
