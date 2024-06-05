//
//  DashboardItemModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 02/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

class DashItemModel {
    var title :String
    var subTitle :String
    var icon :UIImage
    var itemID :String
    var isEnabledForThisHub: Bool
    var isHidden: Bool
    
    var segueID: String
    var isOptional: Bool
    
    var warningIconColor: WarningIconState
    
    func setIconColorFromLockState(isOperational: Bool, locks: [Bool]?) {
        warningIconColor = .RED
        if isOperational {
            warningIconColor = .NONE
        } else {
            if let locks = locks {
                if locks.reduce(false, {$0 || $1}) {
                    warningIconColor = .AMBER
                }
            }
        }
    }
    
    init(title: String,
         subTitle: String,
         icon: UIImage,
         itemID :String,
         enabled: Bool,
         segueID: String,
         isOptional: Bool,
         isHidden: Bool) {
        
        self.title = title
        self.subTitle = subTitle
        self.isHidden = isHidden
        self.icon = icon
        self.itemID = itemID
        self.isEnabledForThisHub = enabled
        self.segueID = segueID
        self.isOptional = isOptional
        self.warningIconColor = .NONE
    }
}
