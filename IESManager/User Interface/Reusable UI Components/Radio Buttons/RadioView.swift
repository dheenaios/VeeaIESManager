//
//  RadioView.swift
//  RadioButtons
//
//  Created by Richard Stockdale on 28/03/2022.
//

import UIKit

class RadioView: UIView {
    var isOn: Bool = false {
        didSet {
            if onView == nil { return }
            onView.isHidden = !isOn
        }
    }
    
    private var onView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        let onViewInset = self.bounds.height / 2
        
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
        
        backgroundColor = .clear
        self.layer.borderColor = InterfaceManager.shared.cm.themeTint.colorForAppearance.cgColor
        self.layer.borderWidth = 1.0
        
        let onViewHeight = self.bounds.height - onViewInset
        let onViewWidth = self.bounds.width - onViewInset
        
        onView = UIView.init(frame: CGRect(x: onViewInset / 2,
                                           y: onViewInset / 2 ,
                                           width: onViewWidth,
                                           height: onViewHeight))
        
        onView.layer.cornerRadius = min(onView.frame.size.height,
                                        onView.frame.size.width) / 2.0
        onView.clipsToBounds = true
        
        onView.backgroundColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
        self.addSubview(onView)
        
        isOn = false
    }
}
