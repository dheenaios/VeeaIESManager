//
//  DashLoader.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 02/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

class DashLoader {
    private let dashboardItemsFileName = "DashboardContents"
    private let serviceItemsFileName = "ServicesContents"
    
    private struct SectionKeys {
        fileprivate static let sectionKey = "section"
        fileprivate static let isHiddenKey = "isHidden"
        fileprivate static let contentsKey = "contents"
    }
        
    public func getDashboardModels() -> [DashSectionModel] {
        return loadFile(fileName: dashboardItemsFileName)
    }
    
    public func loadServices() -> [DashSectionModel] {
        loadFile(fileName: serviceItemsFileName)
    }
    
    private func loadFile(fileName: String) -> [DashSectionModel] {
        var dataModels = [DashSectionModel]()
        let data = JsonFileLoader.loadData(fileName+".json")
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [Any]
            for item in jsonResult {
                if let sectionJson = item as? [String : Any] {
                    if let section = processSection(json: sectionJson) {
                        dataModels.append(section)
                    }
                }
                else { print("Error in Json") }
            }
        }
        catch {
            return dataModels
        }

        return dataModels
    }
    
    private func processSection(json: [String : Any]) -> DashSectionModel? {
        let hidden = json[SectionKeys.isHiddenKey] as! Bool
        
        if hidden {
            return nil
        }
        
        let title = json[SectionKeys.sectionKey] as! String
        
        let items = json[SectionKeys.contentsKey] as! [[String : Any]]
        
        var models = [DashItemModel]()
        for item in items {
            let id = item[ItemKeys.itemIDKey] as! String
            let title = item[ItemKeys.titleKey] as! String
            let subTitle = item[ItemKeys.subTitleKey] as! String
            let segueID = item[ItemKeys.iosSegueIDKey] as! String
            let enabled = item[ItemKeys.isEnabledKey] as! Bool
            let imageIconString = item[ItemKeys.iosIconNameKey] as! String
            let itemHidden = item[ItemKeys.isHiddenKey] as! Bool
            
            let image = UIImage(named: imageIconString)!

            let isOptional = item[ItemKeys.isOptionalKey] as! Bool
            
            let itemModel = DashItemModel.init(title: title,
                                                    subTitle: subTitle,
                                                    icon: image,
                                                    itemID: id,
                                                    enabled: enabled,
                                                    segueID: segueID,
                                                    isOptional: isOptional,
                                                    isHidden: itemHidden)
            
            models.append(itemModel)
        }
        
        let sectionModel = DashSectionModel.init(sectionTitle: title, itemModels: models)

        return sectionModel
    }
}
