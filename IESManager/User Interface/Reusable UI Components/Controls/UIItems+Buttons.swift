//
//  UIItems+Buttons.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 12/29/18.
//  Copyright © 2018 Veea. All rights reserved.
//

import UIKit

// Flat buttons
public enum VUIFlatButtonType {
    /* Purple color with white title */
    case standard
    case blue
    case green
    case red
    case gray
    
    public var color: UIColor {
        switch self {
        case .green:
            return .vGreen
        case .red:
            return .vRed
        case .blue:
            return .vBlue
        case .gray :
            return .gray
        default:
            return .vPurple
        }
    }
}

class VUIFlatButton: UIButton {
    
    convenience init(frame: CGRect, type: VUIFlatButtonType, title: String) {
        self.init(frame: frame)
        self.adjustsImageWhenHighlighted = false
        self.setTitle(title, for: .normal)
        flatButtonStyle(type)(self)
        
        self.addTarget(self, action: #selector(VUIFlatButton.buttonUp), for: [UIControl.Event.touchUpOutside, UIControl.Event.touchCancel])
        self.addTarget(self, action: #selector(VUIFlatButton.buttonDown), for: UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(VUIFlatButton.buttonUpDown), for: UIControl.Event.touchUpInside)
        
    }
    
    @objc open func buttonUp() {
        self.alpha = 1
    }
    
    @objc open func buttonDown() {
        self.alpha = 0.5
    }
    
    @objc open func buttonUpDown() {
        self.alpha = 0.5
        
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(0.11 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.alpha = 1
        })
    }
}

extension VUIFlatButton {
    func setEnabledState(enabled : Bool = true, enabledType: VUIFlatButtonType = VUIFlatButtonType.standard) {
        self.isEnabled = enabled
        enabled ? flatButtonStyle(enabledType)(self) : flatButtonStyle(VUIFlatButtonType.gray)(self)
    }
}

extension VUIFlatButton {
    
    struct Activity {
        static var control: UIActivityIndicatorView?
    }
    
    func showActivity() {
        self.titleLabel?.alpha = 0
        
        Activity.control = UIActivityIndicatorView(style: .medium)
        Activity.control?.centerInView(superView: self, mode: .absolute)
        self.addSubview(Activity.control!)
        Activity.control?.startAnimating()
        
        self.isEnabled = false
    }
    
    func stopActivity() {
        Activity.control?.stopAnimating()
        Activity.control?.removeFromSuperview()
        Activity.control = nil
        self.titleLabel?.alpha = 1
        self.isEnabled = true
    }
}

class VUIUnderLinedButton: UIControl {
    
    private var textLabel: UILabel!
    
    var color: UIColor = .darkGray {
        didSet {
            textLabel.textColor = color
        }
    }
    
    convenience init(text: String, fontSize: CGFloat = UIFont.smallSystemFontSize) {
        
        self.init()
        
        textLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        textLabel.textColor = UIColor.gray
        textLabel.font = FontManager.bold(size: fontSize)
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: text, attributes: underlineAttribute)
        textLabel.attributedText = underlineAttributedString
        textLabel.sizeToFit()
        textLabel.isUserInteractionEnabled = false
        self.addSubview(textLabel)

        self.frame.size.width = textLabel.frame.width
        self.frame.size.height = textLabel.frame.height
        
        self.addTarget(self, action: #selector(VUIFlatButton.buttonUp), for: [UIControl.Event.touchUpOutside, UIControl.Event.touchCancel])
        self.addTarget(self, action: #selector(VUIFlatButton.buttonDown), for: UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(VUIFlatButton.buttonUpDown), for: UIControl.Event.touchUpInside)
        
    }
    
    @objc open func buttonUp() {
        self.alpha = 1
    }
    
    @objc open func buttonDown() {
        self.alpha = 0.5
    }
    
    @objc open func buttonUpDown() {
        self.alpha = 0.5
        
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(0.11 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.alpha = 1
        })
    }
    
}
