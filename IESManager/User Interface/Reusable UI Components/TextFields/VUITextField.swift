//
//  VUITextField.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/2/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class VUITextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customize()
    }
    
    func customize() {
        // NADA
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 15, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
}


extension VUITextField {
    
    func removeHighlights() {
        UIView.animate(withDuration: 2.5, animations: {
            self.layer.borderWidth = 0
        }) { (_) in
            self.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func showErrorHighlight() {
        self.layer.borderColor = UIColor.vRed.cgColor
        self.layer.borderWidth = 1.5
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
            self.removeHighlights()
            timer.invalidate()
        }
    }
}
