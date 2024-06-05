//
//  CurvedButton.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 19/02/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class CurvedButton: UIButton {
    
    private var _borderColor: UIColor?
    
    @IBInspectable var borderColor: UIColor {
        get { return _borderColor ?? .clear }
        set {
            _borderColor = newValue
            layer.borderColor = newValue.cgColor
        }
    }

    func setCustomFontSize(_ size: CGFloat) {
        titleLabel?.font = FontManager.medium(size: size)
    }
    
    @IBInspectable var fillColor: UIColor {
        get { return backgroundColor ?? .clear }
        set { backgroundColor = newValue }
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp() {
        layer.cornerRadius = 7.0
        layer.borderWidth = 2.0
        
        titleLabel?.font = FontManager.bigButtonText
    }
}
