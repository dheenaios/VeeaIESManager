//
//  LoginPageInfoView.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 12/27/18.
//  Copyright © 2018 Veea. All rights reserved.
//

import UIKit

class LoginPageInfoView: UIView {
        
    convenience init(frame: CGRect, title: String, info: String, icon: UIImage? = nil) {
        self.init(frame: frame)
        self.backgroundColor = .clear
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width * 0.85, height: 0))
        // Image View
        if icon != nil {
            let iconView = UIImageView(frame: CGRect(x: 0, y: contentView.frame.height, width: 65, height: 65))
            iconView.image = icon
            iconView.tintColor = UIColor(named: "Login Icon Tint")
            iconView.centerInView(superView: contentView, mode: .horizontal)
            contentView.push(iconView)
            contentView.addOffset(15)
        }
        
        // Title Label
        let titleLabel = UILabel(frame: CGRect(x: 0, y: contentView.frame.height, width: contentView.frame.width, height: 0))
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = FontManager.bold(size: 25)
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.centerInView(superView: contentView, mode: .horizontal)
        contentView.push(titleLabel)
        contentView.addOffset(15)
        
        //Info Label
        let infoLabel = UILabel(frame: CGRect(x: 0, y: contentView.frame.height, width: contentView.frame.width, height: 0))
        infoLabel.textColor = UIColor.white
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.font = FontManager.regular(size: 17)
        infoLabel.text = info
        infoLabel.sizeToFit()
        infoLabel.centerInView(superView: contentView, mode: .horizontal)
        contentView.push(infoLabel)
        
        contentView.centerInView(superView: self, mode: .absolute)
        self.addSubview(contentView)
        
    }

}
