//
//  RowView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 16/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit

class RowView: LoadedXibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet weak var disclosureIndicator: UIImageView!
    @IBOutlet private weak var valueLabel: UILabel!
    
    @IBInspectable var title: String = "Title" {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBInspectable var subTitle: String = "" {
        didSet {
            subTitleLabel.text = subTitle
        }
    }
    
    @IBInspectable var valueText: String = "Value" {
        didSet {
            valueLabel.text = valueText
        }
    }
    
    @IBInspectable var hideValueLabel: Bool = false {
        didSet {
            valueLabel.isHidden = hideValueLabel
        }
    }
    
    @IBInspectable var hideDisclosureIndicator: Bool = false {
        didSet {
            disclosureIndicator.isHidden = hideValueLabel
        }
    }
    
    private var observer: (() -> Void)?
    
    @IBAction func rowTapped(_ sender: Any) {
        guard let o = observer else { return }
        o()
    }
    
    func observerTaps(observer: @escaping (() -> Void)) {
        self.observer = observer
    }
    
    override func loaded() {
        titleLabel.text = title
        subTitleLabel.text = subTitle
        valueLabel.text = valueText
        valueLabel.isHidden = hideValueLabel
        disclosureIndicator.isHidden = hideDisclosureIndicator
    }
}
