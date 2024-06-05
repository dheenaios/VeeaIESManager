//
//  VUIAnimatedButton.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 2/6/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class VUIAnimatedButton: UIControl {
    private var textLabel: UILabel!
    private var imageView: UIImageView!
    private var activityIndicator: UIActivityIndicatorView?
    private var originalWidth: CGFloat = 0
    private var originalBG: UIColor = UIColor.white
    
    var status: (image: UIImage, color: UIColor?)? {
        didSet {
            if let image_ = status?.image {
                self.setStatus(with: image_, color: status?.color ??  self.backgroundColor)
            }
        }
    }
    
    convenience init(frame: CGRect, title: String, color: UIColor) {
        self.init(frame: frame)
        
        self.backgroundColor = color
        self.originalBG = color
        self.originalWidth = self.frame.width
        roundedStyle(self)
        
        textLabel = UILabel(frame: self.bounds)
        textLabel.font = FontManager.bold(size: 16)
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        textLabel.text = title
        textLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(textLabel)
        
        self.addTarget(self, action: #selector(self.onTouchDown(sender:)), for: .touchDown)
        self.addTarget(self, action: #selector(self.onTouchCancel(sender:)), for: [.touchDragExit, .touchDragOutside, .touchUpInside, .touchUpOutside, .touchCancel])
        self.addTarget(self, action: #selector(self.OnTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    @objc func onTouchDown(sender: UIControl) {
        UIView.animate(withDuration: 0.2) {
            sender.alpha = 0.6
        }
    }
    
    @objc func onTouchCancel(sender: UIControl) {
        UIView.animate(withDuration: 0.3) {
            sender.alpha = 1.0
        }
    }
    
    @objc func OnTouchUpInside(sender: UIControl) {
        self.isUserInteractionEnabled = false
        self.textLabel.alpha = 0
        //Animate and start loading view
        activityIndicator = UIActivityIndicatorView(style: .medium)

        activityIndicator?.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        activityIndicator?.startAnimating()
        self.addSubview(activityIndicator!)
        
        UIView.animate(withDuration: 0.4, animations: {
            circularStyle(self)
            self.frame.size.width = self.frame.height
            self.activityIndicator?.center.x = self.frame.width/2
            self.center.x = self.superview!.frame.width/2
        }) { (_) in
            //Customize here after animation completion
        }
    }
    
    private func setStatus(with image: UIImage, color: UIColor?) {
        self.activityIndicator?.stopAnimating()
        imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: self.frame.height/2, height: self.frame.height/2))
        imageView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        imageView.image = image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        self.addSubview(imageView)
        UIView.animate(withDuration: 0.3, animations: {
            self.imageView.alpha = 1.0
            self.backgroundColor = color
        }) { (_) in
            self.activityIndicator?.removeFromSuperview()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.finish()
            })
        }
    }
    
    func finish() {
        self.activityIndicator?.removeFromSuperview()
        self.imageView?.removeFromSuperview()
        self.imageView = nil
        
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundColor = self.originalBG
            self.frame.size.width = self.originalWidth
            self.center.x = self.superview!.frame.width/2
            self.textLabel.alpha = 1.0
            roundedStyle(self)
        }) { (_) in
            self.isUserInteractionEnabled = true
        }
    }
}
