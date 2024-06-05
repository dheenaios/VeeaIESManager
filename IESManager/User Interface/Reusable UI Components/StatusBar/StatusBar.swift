//
//  StatusBar.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 26/01/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class StatusBar: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    private let imageWidth: CGFloat = 26
    
    weak var delegate: StatusBarDelegate?
    
    @IBAction func inUseTitleTapped(_ sender: Any) {
        delegate?.inUseTitleTapped()
    }
    
    func setConfig(config: StatusBarConfig) {
        setUp(text: config.text ?? "",
              barBackGroundColor: config.barBackgroundColor,
              iconColor: config.iconColor,
              icon: config.icon)
    }
    
    func setUp(text: String,
               barBackGroundColor: UIColor?,
               iconColor: UIColor?,
               icon: UIImage?) {
        DispatchQueue.main.async {
            self.textLabel.text = text
            
            self.contentView.backgroundColor = barBackGroundColor
            self.iconImageView.tintColor = iconColor
            self.iconImageView.image = icon
            
            // Check for an empty image
            if icon?.size.width == 0 {
                self.imageWidthConstraint.constant = 0
            }
            else {
                self.imageWidthConstraint.constant = self.imageWidth
            }
        }
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        contentView = Bundle.main.loadNibNamed("StatusBar", owner: self, options: nil)![0] as? UIView
        contentView?.frame = bounds
        addSubview(contentView!)
        
        textLabel.text = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = Bundle.main.loadNibNamed("StatusBar", owner: self, options: nil)![0] as? UIView
        contentView?.frame = bounds
        addSubview(contentView!)
        
        textLabel.text = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
