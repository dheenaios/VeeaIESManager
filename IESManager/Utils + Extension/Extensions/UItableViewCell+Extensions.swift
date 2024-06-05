//
//  UItableViewCell+Extensions.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    
    var isChecked: Bool {
        get {
            return accessoryType == .checkmark
        }
        set {
            accessoryType = newValue ? .checkmark : .none
        }
        
    }
    
    // Toggles the checked state of a cell. Checked / None
    func toggleCheckMark() {
        if accessoryType == .checkmark {
            accessoryType = .none
        }
        else {
            accessoryType = .checkmark
        }
    }
}
