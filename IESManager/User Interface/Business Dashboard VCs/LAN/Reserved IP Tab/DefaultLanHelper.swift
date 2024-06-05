//
//  DefaultLanHelper.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 27/04/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

class DefaultLanHelper {
    
    private lazy var meshLanConfig: MeshLanConfig? = {
        return HubDataModel.shared.baseDataModel?.meshLanConfig
    }()
    
    public var meshLans: [MeshLan] {
        guard  let c = meshLanConfig else {
            return [MeshLan]()
        }
        
        return c.lans
    }
    
    
    /// Get details of default dhcp LAN
    /// - Parameter selectedLanNumber: the lan number
    /// - Returns: start end and number of hosts
    func getDefultRangeDetails(selectedLanNumber: Int) -> (String, String, Int) {
        let meshModel = meshLans[selectedLanNumber]
        let subnet = meshModel.ip4_subnet
        let subnetModel = SubnetModel.subnet(fromIpAndPrefix: subnet)
        
        let s = subnetModel?.startHostAddress ?? ""
        let e = subnetModel?.endHostAddress ?? ""
        let h = subnetModel?.numberOfHosts ?? 0
         
        return (s, e, h)
    }
}
