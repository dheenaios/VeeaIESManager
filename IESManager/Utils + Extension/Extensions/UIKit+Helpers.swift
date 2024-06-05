//
//  UIKit+Helpers.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 12/28/18.
//  Copyright © 2018 Veea. All rights reserved.
//

import UIKit

// Function compostion using custom operator
precedencegroup SingleTypeComposition {
    associativity: right
}

infix operator <>: SingleTypeComposition

public func <> <A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> ((A) -> Void) {
    return { a in
        f(a)
        g(a)
    }
}

// MARK: - UIView

let roundedStyle: (UIView) -> Void = {
    $0.layer.cornerRadius = 6
    $0.clipsToBounds = true
}

func borderStyle(color: UIColor, width: CGFloat) -> (UIView) -> Void {
    return {
        $0.layer.borderColor = color.cgColor
        $0.layer.borderWidth = width
    }
}

let circularStyle: (UIView) -> Void = {
    $0.clipsToBounds = true
    $0.layer.cornerRadius = $0.frame.height/2
    
}

/**
 Adds a shadow to the view its called on
 
 - parameter radius:       Radius of the shadow.
 - parameter offsetWidth:  Width of the shadow.
 - parameter offsetHeight: Height of the shadow.
 - parameter color:        Color of the shadow.
 - parameter opacity:      Opacity of shadow [0,1] range will give undefined results.
 */

func dropShadow(radius: CGFloat = 3, offsetWidth: CGFloat = 2, offsetHeight: CGFloat = 2, color: UIColor = UIColor(white: 0.0, alpha: 0.5), opacity: Float = 0.6, path: Bool = true) -> (UIView) -> Void {
    return {
        $0.layer.masksToBounds = false
        $0.layer.shadowColor = color.cgColor
        $0.layer.shadowOffset = CGSize(width: offsetWidth, height: offsetHeight)
        $0.layer.shadowRadius = radius
        $0.layer.shadowOpacity = opacity
        if path {
            $0.layer.shadowPath = UIBezierPath(roundedRect: $0.bounds, cornerRadius: $0.layer.cornerRadius).cgPath
        }
        $0.layer.shouldRasterize = true
        $0.layer.rasterizationScale = UIScreen.main.scale
    }
}


// MARK: - UIButton

let baseButtonStyle: (UIButton) -> Void = {
    $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
    $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
}

let roundedButtonStyle = baseButtonStyle <> roundedStyle


func filledButtonStyle(color: UIColor, textColor: UIColor = UIColor(named: "Background Color Light")!) -> (UIButton) -> Void {
    return {
        $0.backgroundColor = color
        let title = $0.titleLabel?.text ?? ""
        let attrString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: FontManager.bold(size: 15), NSAttributedString.Key.foregroundColor: textColor])
        $0.setAttributedTitle(attrString, for: .normal)
    }
}

let imageButtonStyle: (UIImage?) -> (UIButton) -> Void = { image in
    return {
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
}


let flatButtonStyle: (VUIFlatButtonType) -> (UIButton) -> Void = { type in
    roundedButtonStyle
    <> filledButtonStyle(color: type.color)
    <> dropShadow()
}


// MARK :- UIScrollView

let keyboardDismissMode: (UIScrollView.KeyboardDismissMode) -> (UIScrollView) -> Void = { mode in
    return {
        $0.keyboardDismissMode = mode
    }
}

let scrollViewDefaultStyle: (UIScrollView) -> Void = {
    $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    $0.backgroundColor = .clear
}

let scrollVerticalStyle: (UIScrollView) -> Void = scrollViewDefaultStyle <> {
    $0.alwaysBounceVertical = true
    $0.showsVerticalScrollIndicator = false
}

let scrollHorizontalStyle: (UIScrollView) -> Void = scrollViewDefaultStyle <> {
    $0.alwaysBounceHorizontal = true
    $0.showsHorizontalScrollIndicator = false
}

let scrollVerticalWithDismissStyle: (UIScrollView) -> Void = scrollVerticalStyle
<> keyboardDismissMode(.interactive)
