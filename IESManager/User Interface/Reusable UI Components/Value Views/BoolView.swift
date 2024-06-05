//
//  BoolView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 10/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

class BoolView: UIView {
    @IBOutlet var xibView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var boolSwitch: UISwitch!
    
    var readOnly: Bool? {
        willSet {
            guard let ro = newValue else {
                boolSwitch.isEnabled = true
                return
            }
            
            boolSwitch.isEnabled = !ro
        }
    }
    
    private var _title: String?
    @IBInspectable var title: String? {
        get {
            return titleLabel.text
        }
        set {
            _title = newValue
            guard titleLabel != nil else {
                return
            }
            
            titleLabel.text = newValue
        }
    }
    
    @IBInspectable var subTitleText: String? {
        willSet {
            guard subTitleLabel != nil else {
                return
            }
            
            subTitleLabel.text = newValue
        }
    }
    
    var switchIsOn: Bool {
        get {
            return boolSwitch.isOn
        }
        set {
            boolSwitch.isOn = newValue
        }
    }

    // MARK: - INIT
    override func awakeFromNib() {
        super .awakeFromNib()
        
        xibView = Bundle.main.loadNibNamed("BoolView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        initialPopulate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("BoolView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialPopulate() {
        titleLabel.text = _title
        subTitleLabel.text = subTitleText
    }
}
