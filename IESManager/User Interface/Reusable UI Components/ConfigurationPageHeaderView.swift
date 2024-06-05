//
//  ConfigurationPageHeaderView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 19/07/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import UIKit

class ConfigurationPageHeaderView: UIView {
    
    private var xibView: UIView?

    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var title: UILabel!
    
    func setImage(image: UIImage, andTitle titleText: String) {
        icon.image = image
        title.text = titleText
    }
    
    func setImage(image: UIImage, withTint tint: UIColor, andTitle titleText: String) {
        icon.image = image
        icon.tintColor = tint
        title.text = titleText
    }
    
    @IBInspectable var headerImage: UIImage? {
        get {
            return icon.image
        }
        set {
            icon.image = newValue
        }
    }
    
    @IBInspectable var headerTitle: String {
        get {
            return title.text ?? ""
        }
        set {
            title.text = newValue
        }
    }
    
    func setImage(imageNamed: String, andTitle titleText: String) {
        let image = UIImage.init(named: imageNamed)
        
        icon.image = image
        title.text = titleText
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        xibView = Bundle.main.loadNibNamed("ConfigurationPageHeaderView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("ConfigurationPageHeaderView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
