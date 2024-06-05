//
//  VUIErrorView.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 2/11/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class VUIErrorView: UIView {
    
    var callback: Callback?
    
    convenience init(frame: CGRect, title: String, message: String, buttonTitle: String = "Retry") {
        self.init(frame: frame)
        
        
        // Message Label
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width * 0.8, height: 0))
        messageLabel.text = message
        multilineCenterLabelStyle(messageLabel)
        messageLabel.centerInView(superView: self, mode: .absolute)
        self.addSubview(messageLabel)
        
        // Title
        let titleLabel = VUITitle(frame: CGRect(x: 0, y: 0, width: frame.width * 0.8, height: 0), title: title)
        titleLabel.frame.origin.y = messageLabel.topEdge - UIConstants.Spacing.standard - titleLabel.frame.height
        titleLabel.centerInView(superView: self, mode: .horizontal)
        titleLabel.textColor = UIColor(named: "TitleTextColor")
        self.addSubview(titleLabel)
        
        // Retry button
        let retryButton = VUIFlatButton(frame: CGRect(x: 0, y: messageLabel.bottomEdge + UIConstants.Margin.top, width: 150, height: 35), type: .blue, title: buttonTitle)
        retryButton.centerInView(superView: self, mode: .horizontal)
        retryButton.addTarget(self, action: #selector(VUIErrorView.retry), for: .touchUpInside)
        self.addSubview(retryButton)
        
//        self.backgroundColor = UIColor(named: "Dashboard Background")
        self.backgroundColor = UIColor.systemBackground
    }
    
    @objc private func retry() {
        callback?()
    }
}
