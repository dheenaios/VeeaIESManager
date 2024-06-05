//
//  HubDataModel+Snapshots.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 23/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

// Methods relating to use of snapshots
extension HubDataModel {
    
    func updateDataModelsFromSnapshots() {
        guard let snapshot = configurationSnapShotItem else {
            return
        }
        
        let bm = snapshot.getBaseDataModel()
        baseDataModel = bm
        
        if let optionalModel = snapshot.getOptionalDataModel() {
            optionalAppDetails = optionalModel
        }
        else {
            optionalAppDetails = nil
        }
    }
}
