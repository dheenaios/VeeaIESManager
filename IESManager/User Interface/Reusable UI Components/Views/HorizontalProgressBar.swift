//
//  HorizontalProgressBar.swift
//  CustomProgressBar
//
//  Created by Richard Stockdale on 11/03/2022.
//

import Foundation
import UIKit

@IBDesignable
class HorizontalProgressBar: UIView {
    @IBInspectable var color: UIColor? = .black
    
    var progress: CGFloat = 0.5 {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(progressLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.addSublayer(progressLayer)
    }
    
    private let progressLayer = CALayer()
    
    override func draw(_ rect: CGRect) {
        let backgroundMask = CAShapeLayer()
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.50).cgPath
        layer.mask = backgroundMask
        
        let progressRect = CGRect(origin: .zero,
                                  size: CGSize(width: rect.width * progress,
                                               height: rect.height))
        
        progressLayer.frame = progressRect
        layer.addSublayer(progressLayer)
        progressLayer.backgroundColor = color?.cgColor
    }
}
