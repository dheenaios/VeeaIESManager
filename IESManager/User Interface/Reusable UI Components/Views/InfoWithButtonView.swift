//
//  InfoWithButtonView.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/9/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class InfoWithButtonView: UIView {
    
    var buttonCallBack: (() -> Void)?
    
    convenience init(infoText: String, buttonTitle: String) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        
        // Info Label
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 0))
        label.text = infoText
        smallDarkGrayLabelStyle(label)
        label.centerInView(superView: self, mode: .horizontal)
        self.push(label)
        
        // Underlined button
        let underlinedButton = VUIUnderLinedButton(text: buttonTitle)
        underlinedButton.frame.origin.y = label.bottomEdge + 2
        underlinedButton.centerInView(superView: self, mode: .horizontal)
        underlinedButton.addTarget(self, action: #selector(InfoWithButtonView.callback), for: .touchUpInside)
        self.push(underlinedButton)
    }
    
    @objc private func callback() {
        self.buttonCallBack?()
    }
}
