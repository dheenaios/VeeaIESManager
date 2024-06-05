//
//  VUIProgressView.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/29/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class VUIProgressView: UIView {

    private var progressView: UIView!
    
    var progressColor: UIColor? {
        didSet {
            self.progressView?.backgroundColor = progressColor
        }
    }
    
    var trackColor: UIColor? {
        didSet {
            self.backgroundColor = trackColor
        }
    }
    
    /** Value of progress ranges from 0 to 100. Anything grater than 100 is considered as full width.**/
    var progress: Double = 0 {
        didSet {
            self.setProgress(value: progress)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray
        self.layer.cornerRadius = frame.height/2
        self.clipsToBounds = true
        
        self.progressView = UIView(frame: self.bounds)
        self.progressView.frame.size.width = 0
        self.progressView.backgroundColor = .vPurple
        self.addSubview(progressView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setProgress(value: Double) {
        var widthToAnimate = self.frame.width
        if value < 100 {
            widthToAnimate = CGFloat(value/100) * self.frame.width
        }
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.frame.size.width = widthToAnimate
        }) { (_) in
            //NADA
        }
        
        
    }
}
