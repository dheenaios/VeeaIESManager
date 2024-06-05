//
//  DashSectionModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 02/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation

struct DashSectionModel {
    let sectionTitle: String
    let allItemModels: [DashItemModel]
    
    var visibleModels: [DashItemModel] {
        var models = [DashItemModel]()
        
        for model in allItemModels {
            if !model.isHidden {
                models.append(model)
            }
        }
        
        return models
    }
    
    var visibleRows: Int {
        var i = 0
        for model in allItemModels {
            if !model.isHidden {
                i += 1
            }
        }
        
        return i
    }
    
    init(sectionTitle: String, itemModels: [DashItemModel]) {
        self.sectionTitle = sectionTitle
        self.allItemModels = itemModels
    }
}
