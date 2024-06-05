//
//  VUIActivityView.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/30/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class VUIActivityView: UIView {
    
    private var activity: UIActivityIndicatorView!
    
    /** Background color of UIView **/
    private var viewColor = UIColor.black.withAlphaComponent(0.55)
    
    /** The color of the activityIndicator **/
    var color: UIColor? {
        didSet {
            self.activity.color = color
        }
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented **** ")
    }
    
    private func setupView() {
        self.backgroundColor = viewColor
        self.isOpaque = false
        activity = UIActivityIndicatorView(style: .large)
        activity.centerInView(superView: self, mode: .absolute)
        self.addSubview(activity)
    }
    
    func beginAnimating() {
        if let key = UIWindow.sceneWindow {
            key.addSubview(self)
        }else {
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundColor = self.viewColor
        }) { (_) in
            self.activity.startAnimating()
        }
    }
    
    func endAnimating(callback: (() -> ())? = nil) {
        self.activity.stopAnimating()
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = .clear
        }) { (_) in
            self.removeFromSuperview()
            callback?()
        }
    }
}
