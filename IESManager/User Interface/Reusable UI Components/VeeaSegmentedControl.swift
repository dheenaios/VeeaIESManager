//
//  VeeaSegmentedControl.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 03/02/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class VeeaSegmentedControl: UISegmentedControl {
    
    var selectedItemTintColor = InterfaceManager.shared.cm.themeTint
    
    var allowDeselect = false
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        defaultConfiguration()
        selectedConfiguration()
        setTheme()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        defaultConfiguration()
        selectedConfiguration()
        setTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        defaultConfiguration()
        selectedConfiguration()
        setTheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        DispatchQueue.main.async { self.setTheme() }
    }
    
    func setTheme() {
        selectedSegmentTintColor = selectedItemTintColor.colorForAppearance
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let previousSelectedSegmentIndex = selectedSegmentIndex
        
        super.touchesEnded(touches, with: event)
        
        if !allowDeselect {
            return
        }
        
        if previousSelectedSegmentIndex == selectedSegmentIndex {
            let touch = touches.first!
            let touchLocation = touch.location(in: self)
            if bounds.contains(touchLocation) {
                selectedSegmentIndex = UISegmentedControl.noSegment
                sendActions(for: .valueChanged)
            }
        }
    }
}

extension VeeaSegmentedControl {
    func removeLastSegment() {
        if numberOfSegments == 0 { return }
        let lastIndex = numberOfSegments - 1
        removeSegment(at: lastIndex, animated: true)
    }
}

extension UISegmentedControl
{
    func smallPhoneConfiguration() {
        defaultConfiguration(font: FontManager.regular(size: 10))
    }


    func defaultConfiguration(font: UIFont = FontManager.regular(size: 12),
                              color: UIColor = UIColor(named: "SegmentedControllerDisabledText")!) {
        let defaultAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(defaultAttributes, for: .normal)
    }
    
    func selectedConfiguration(font: UIFont = FontManager.regular(size: 12),
                               color: UIColor = UIColor.white) {
        let selectedAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}

