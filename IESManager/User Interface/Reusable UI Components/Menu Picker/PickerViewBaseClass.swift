//
//  PickerViewBaseClass.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 17/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class PickerViewBaseClass: LoadedXibView {
    
    @IBOutlet weak var backingView: UIView!
    @IBOutlet weak var valueText: UILabel!
    @IBOutlet weak var cheveron: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        uiSetUp()
        setUp()
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        uiSetUp()
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func uiSetUp() {
        backingView.layer.cornerRadius = 10
        backingView.clipsToBounds = true
    }
    
    var selectorIsEnabled: Bool {
        get {
            return !cheveron.isHidden
        }
        set {
            backingView.alpha = newValue ? 1.0 : 0.3
            valueText.isHidden = !newValue
            cheveron.isHidden = !newValue
            backingView.isUserInteractionEnabled = newValue
        }
    }
    
    public func setUp() {
        //print("Implement setup in your implementation to kick of any custom action")
    }

}
