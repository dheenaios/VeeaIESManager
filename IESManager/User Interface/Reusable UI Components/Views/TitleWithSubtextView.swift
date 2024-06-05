//
//  TitleAndDescriptionView.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/11/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

/** UIView with VUITitle and dark gray subtext.
  Note: By default it will be set to screen width.
 */
class TitleWithSubtextView: UIView {
    
    convenience init(title: String, subtext: String) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        
        // Title
        let titleLabel = VUITitle(frame: CGRect(x: UIConstants.Margin.side, y: self.frame.height, width: UIConstants.contentWidth, height: 0), title: title)
        self.push(titleLabel)
        self.addOffset(UIConstants.Margin.side)
        
        // Info label
        let infoLabel = UILabel(frame: CGRect(x: UIConstants.Margin.side, y: self.frame.height, width: UIConstants.contentWidth, height: 0))
        infoLabel.text = subtext
        darkGrayLabelStyle(infoLabel)
        self.push(infoLabel)
    }

}


/** UIView with VUITitle and dark gray subtext and Image Icon.
 Note: By default it will be set to screen width.
 */
class TitleViewWithImage: UIView {
    
    
    
    convenience init(icon: UIImage?, title: String, subtext: String) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        
        // Icon ImageView
        let iconImageView = UIImageView(frame: CGRect(x: UIConstants.Margin.side, y: self.frame.height, width: 85, height: 85))
        iconImageView.image = icon
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFit
        self.addSubview(iconImageView)
        
        // Title
        let textOrigin = iconImageView.rightEdge + UIConstants.Spacing.standard
        let textContentWidth = self.bounds.width - textOrigin - UIConstants.Margin.side
        let titleLabel = VUITitle(frame: CGRect(x: textOrigin, y: self.frame.height, width: textContentWidth, height: 0), title: title)
        titleLabel.textColor = UIColor.label
        self.push(titleLabel)
        self.addOffset(UIConstants.Margin.side)
        
        // Info label
        let infoLabel = UILabel(frame: CGRect(x: textOrigin, y: self.frame.height, width: textContentWidth, height: 0))
        infoLabel.text = subtext
        darkGrayLabelStyle(infoLabel)
        self.push(infoLabel)
        
        if self.frame.height < iconImageView.frame.height {
            self.frame.size.height = iconImageView.frame.height + UIConstants.Margin.top
        }
        
        iconImageView.centerInView(superView: self, mode: .vertical)
    }
}
