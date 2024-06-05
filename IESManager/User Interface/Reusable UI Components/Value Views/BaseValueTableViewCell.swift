//
//  BaseValueTableViewCell.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 21/01/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

class BaseValueTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func dismissKeyboard() {
        // Implement in sub class if relevent
    }

}
