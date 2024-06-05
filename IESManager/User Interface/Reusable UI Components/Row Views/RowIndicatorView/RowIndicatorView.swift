//
//  RowIndicatorView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 16/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation
import UIKit

class RowIndicatorView: LoadedXibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
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
    
    @IBInspectable var indicatorColor: UIColor = .clear {
        didSet {
            indicatorView.backgroundColor = indicatorColor
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
        indicatorView.makeCircular()
        indicatorView.backgroundColor = indicatorColor
    }
}
