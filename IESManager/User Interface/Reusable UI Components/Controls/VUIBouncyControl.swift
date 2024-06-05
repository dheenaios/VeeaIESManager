//
//  VUIBouncyControl.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/18/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class VUIBouncyControl: UIControl {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addBounceEvents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addBounceEvents()
    }
    
    private func addBounceEvents() {
        self.addTarget(self, action: #selector(self.onTouchDown(sender:)), for: .touchDown)
        self.addTarget(self, action: #selector(self.onTouchCancel(sender:)), for: [.touchDragExit, .touchDragOutside, .touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func onTouchDown(sender: UIControl) {
        
        UIView.animate(withDuration: 0.3) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        
    }
    
    @objc private func onTouchCancel(sender: UIControl) {
        UIView.animate(withDuration: 0.2) {
            sender.transform = CGAffineTransform.identity
        }
    }

}
