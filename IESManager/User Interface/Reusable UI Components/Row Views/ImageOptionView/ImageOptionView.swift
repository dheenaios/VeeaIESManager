//
//  ImageOptionView.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

class ImageOptionView: LoadedXibView {
    
    struct ImageOptionViewModel {
        var title: String
        var image: UIImage
        var imageBackgroundColor: UIColor?
        var tintColor: UIColor?
        var subTitle = ""
        var indicatorColor: UIColor?
    }
    
    @IBOutlet var backingView: UIView!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBInspectable var isTappable: Bool = true {
        didSet {
            button.isEnabled = isTappable
        }
    }

    @IBInspectable var title: String = "Title" {
        didSet { self.titleLabel.text = title }
    }

    @IBInspectable var imageBackgroundColor: UIColor {
        get { return imageBackgroundView.backgroundColor ?? .clear }
        set { imageBackgroundView.backgroundColor = newValue }
    }
    
    private var observer: (() -> Void)?
    
    public func setFromModel(_ model: ImageOptionViewModel) {
        title = model.title
        imageView.image = model.image
        
        if let color = model.imageBackgroundColor {
            imageBackgroundColor = color
        }
        else {
            imageBackgroundColor = .clear
        }
        
        if let color = model.tintColor {
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
        }
    }
    
    @IBAction func rowTapped(_ sender: Any) {
        guard let o = observer else { return }
        o()
    }
    
    func observerTaps(observer: @escaping (() -> Void)) {
        self.observer = observer
    }
    
    override func setTheme() {
        super.setTheme()
        backingView.backgroundColor = InterfaceManager.shared.cm.background2.colorForAppearance
    }
    
    override func loaded() {
        titleLabel.text = title
        titleLabel.font = FontManager.bodyText
        
        backingView.backgroundColor = InterfaceManager.shared.cm.background2.colorForAppearance
        backingView.layer.cornerRadius = 10.0
        backingView.clipsToBounds = true
        
        imageBackgroundView.layer.cornerRadius = 8.0
        imageBackgroundView.clipsToBounds = true
        
        button.isEnabled = isTappable
    }
}


/// A cell with the option view inside it
class NameSelectionCell: UITableViewCell {
    @IBOutlet weak var imageOptionView: ImageOptionView!
    
    func configure(model: ImageOptionView.ImageOptionViewModel) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = .clear
        selectedBackgroundView = bgColorView
        
        imageOptionView.setFromModel(model)
    }
}
