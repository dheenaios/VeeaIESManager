//
//  NameVeeaHubViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 24/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

class NameVeeaHubViewModel {
    var options: [ImageOptionView.ImageOptionViewModel] {

        if DefaultNodeDescriptionsAndImages.titles.count != DefaultNodeDescriptionsAndImages.images.count {
            assertionFailure("Titles and Images arrays should be the same length")
        }
        
        var models = [ImageOptionView.ImageOptionViewModel]()
        for (index, title) in DefaultNodeDescriptionsAndImages.titles.enumerated() {
            let i = DefaultNodeDescriptionsAndImages.images[index]
            
            let m = ImageOptionView.ImageOptionViewModel.init(title: title,
                                                              image: i,
                                                              imageBackgroundColor: .clear,
                                                              tintColor: InterfaceManager.shared.cm.themeTint.colorForAppearance)
            models.append(m)
        }
        
        return models
    }
    
    // Last option is custom
    func optionIsCustom(index: Int) -> Bool {
        index == (DefaultNodeDescriptionsAndImages.titles.count - 1)
    }
}
