//
//  HomeDashboardLoader.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

struct HomeDashboardItem: Codable {
    
    /// The title that appears on the dashboard
    let title: String
    
    /// The title that appears in the navigation bar
    let pageTitle: String
    
    let destinationId: String
    let imageName: String
    
    let requiresHubData: Bool
    
    var faded = false
    
    var image: UIImage {
        UIImage(named: imageName)!
    }
}

class HomeDashboardLoader {
    
    lazy var dashboardItems: [HomeDashboardItem] = {
        let allItems = load()
        return allItems
    }()
    
    private let fileName = "HomeDashboardContents"
    
    private func load() -> [HomeDashboardItem] {
        let data = JsonFileLoader.loadData(fileName + ".json")
        
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode([HomeDashboardItem].self, from: data)
            return decoded
        }
        catch {
            assertionFailure("Could not decode the dashboard json")
        }
        
        // Should never be called
        return [HomeDashboardItem]()
    }
}
