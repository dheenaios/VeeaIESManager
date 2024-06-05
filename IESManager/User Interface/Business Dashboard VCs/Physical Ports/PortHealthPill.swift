//
//  PortHealthPill.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 17/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit
import CloudKit

class PortHealthPill: LoadedXibView {
    @IBOutlet weak var backingView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    
    func configure(icon: UIImage,
                   backgroundColor: UIColor,
                   title: String,
                   reason: String) {
        statusImageView.image = icon
        backingView.backgroundColor = backgroundColor
        titleLabel.text = title
        reasonLabel.text = reason
    }
    
    override func loaded() {
        backingView.layer.cornerRadius = 10
        backingView.clipsToBounds = true
    }
}
