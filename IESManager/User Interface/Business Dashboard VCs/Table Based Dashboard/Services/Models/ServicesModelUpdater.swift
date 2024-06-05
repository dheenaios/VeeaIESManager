//
//  SystemModelUpdater.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 30/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class ServicesModelUpdater {
    private var sections = DashLoader().loadServices()
    
    var connectedHub: HubConnectionDefinition? {
        return HubDataModel.shared.connectedVeeaHub
    }
    
    public func getUpdatedModels() -> [DashSectionModel] {
        guard connectedHub != nil else {
            return disabledModels()
        }
        sections = DashLoader().loadServices()
        update()

        return sections
    }
}

// MARK: - Disable
extension ServicesModelUpdater {
    
    private func update() {
        for section in sections {
            for model in section.allItemModels {
                updateModel(model: model)
            }
        }
    }
    
    private func updateModel(model: DashItemModel) {
        if model.itemID == ServicesItemKeys.publicWifi {
            let enabled = HubDataModel.shared.optionalAppDetails?.publicWifiOperatorsConfig != nil
            model.isHidden = !enabled
            
            if let title = HubDataModel.shared.optionalAppDetails?.publicWifiSettingsConfig?.selected_operator {
                if VeeaFiController.providerBrandingShouldBeVeeaFi(provider: title) == true {
                    model.subTitle = "VeeaFi"
                }
                else {
                    model.subTitle = title
                }
            }
            
            model.isEnabledForThisHub = enabled
        }
        else if model.itemID == ServicesItemKeys.sdWanCellularStats {
            let enabled = HubDataModel.shared.optionalAppDetails?.sdWanConfig != nil
            model.isHidden = !enabled
        }
    }
    
    func disabledModels() -> [DashSectionModel] {
        for section in sections {
            disableSection(section: section)
        }
        
        return sections
    }
    
    private func disableSection(section: DashSectionModel) {
        for model in section.allItemModels {
            model.isEnabledForThisHub = false
            model.warningIconColor = .NONE
        }
    }
}
