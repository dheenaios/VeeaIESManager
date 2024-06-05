//
//  HeaderImageViewWithTitle.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/29/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

/// TableCell like view with Image, title label and detail label.
class HeaderImageViewWithTitle: UIView {

    convenience init(image: UIImage?, title: String, detailText: String) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIConstants.Margin.top))
        self.backgroundColor = UIColor.systemGroupedBackground
        
        // ImageView
        let imageView = UIImageView(frame: CGRect(x: UIConstants.Margin.top, y: self.bounds.height, width: 60, height: 60))
        imageView.image = image
        self.push(imageView)
        
        // Text contentView
        let contentWidth = image != nil ? self.bounds.width - imageView.rightEdge - (10 * 2) : self.bounds.width -  (10 * 2)
        let textContentView = UIView(frame: CGRect(x: image != nil ? imageView.rightEdge + 10 : UIConstants.Margin.top, y: 0, width: contentWidth, height: 0))
        
        // Title label
        let titleLabel = VUITitle(frame: CGRect(x: 0, y: 0, width: contentWidth, height: 0), title: title)
        
        if traitCollection.userInterfaceStyle == .dark {
            titleLabel.textColor = UIColor.white
        }
        
        textContentView.push(titleLabel)
        textContentView.addOffset(4)
        
        // Detail label
        let detailLabel = UILabel(frame: CGRect(x: 0, y: textContentView.frame.height, width: contentWidth, height: 0))
        detailLabel.text = detailText
        darkGrayLabelStyle(detailLabel)
        if traitCollection.userInterfaceStyle == .dark {
            detailLabel.textColor = UIColor.white
        }
        textContentView.push(detailLabel)
        
        // Adjust overall height here
        self.frame.size.height += UIConstants.Margin.top // Bottom contnet inset 
        if textContentView.bounds.height > imageView.bounds.height {
            self.frame.size.height += textContentView.bounds.height - imageView.bounds.height
        }
        
        textContentView.centerInView(superView: self, mode: .vertical)
        self.addSubview(textContentView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    func setTheme() {
        
    }

}
