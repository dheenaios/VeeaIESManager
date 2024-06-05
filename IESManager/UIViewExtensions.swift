//
//  UIViewExtensions.swift
//  IESManager
//
//  Created by Richard Stockdale on 26/10/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation
import UIKit

/// Sets the X origin for view; Params $0 - View $1 - OriginX
let setOriginX: (UIView, CGFloat) -> Void = {
    $0.frame.origin.x = $1
}

/// Sets the Y origin for view; Params $0 - View $1 - OriginY
let setOriginY: (UIView, CGFloat) -> Void = {
    $0.frame.origin.y = $1
}


// MARK: - Imaging extensions
extension UIView {
    
    public var bottomEdge: CGFloat {
        
        set(newValue) {
            self.frame.origin.y = newValue - self.frame.height
        }
        
        get {
            return self.frame.origin.y + self.frame.height
        }
    }
    
    public var topEdge: CGFloat {
        return self.frame.origin.y
    }
    
    public var leftEdge: CGFloat {
        return self.frame.origin.x
    }
    
    public var rightEdge: CGFloat {
        get {
            return self.frame.origin.x + self.frame.width
        }
        
        set(newValue) {
            self.frame.origin.x = newValue - self.frame.width
        }
    }
    
    public func imageOfView() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // Crop of the image
    public func imageOfView(width: CGFloat, height: CGFloat) -> UIImage {
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    public static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /** Adds subview and increases the height of the view*/
    @objc public func push(_ view: UIView) {
        self.addSubview(view)
        self.frame.size.height += view.frame.height
    }
    
    /** Increases the height of the view */
    @objc public func addOffset(_ offset: CGFloat) {
        self.frame.size.height += offset
    }
    
    public func centerInView(superView view: UIView, mode: UIViewCenterMode) {
        switch mode {
            
        case .horizontal:
            
            self.frame.origin.x = (view.frame.width / 2) - (self.frame.width / 2)
            
        case .vertical:
            
            self.frame.origin.y = (view.frame.height / 2) - (self.frame.height / 2)
            
        case .absolute:
            
            self.frame.origin.x = (view.frame.width / 2) - (self.frame.width / 2)
            self.frame.origin.y = (view.frame.height / 2) - (self.frame.height / 2)
            
        }
    }
    
    func drawLine(from: CGPoint, to: CGPoint, thickness: CGFloat, color: UIColor) {
        
        // Path for the line
        let linePath = UIBezierPath()
        linePath.move(to: from)
        linePath.addLine(to: to)
        
        // Layer for the line
        let line = CAShapeLayer()
        line.path = linePath.cgPath
        line.strokeColor = color.cgColor
        line.lineWidth = 1.0
        
        self.layer.addSublayer(line)
        
    }
}

public enum UIViewCenterMode {
    case horizontal
    case vertical
    case absolute
}


extension UIScrollView {
    
    /** Adds view to scrollView with content height as Y origin. Increases contentSize of the scrollView. */
    public override func push(_ view: UIView) {
        view.frame.origin.y = self.contentSize.height
        self.addSubview(view)
        self.contentSize.height += view.frame.height
    }
    
    /** Increase the height of contentSize for given offset. */
    public override func addOffset(_ offset: CGFloat) {
        self.contentSize.height += offset
    }
}
