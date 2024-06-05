//
//  RadioButtonView.swift
//  RadioButtons
//
//  Created by Richard Stockdale on 28/03/2022.
//

import Foundation
import UIKit

protocol RadioButtonViewDelegate: AnyObject {
    func didSelect(radioButtonView: RadioButtonView)
}

class RadioButtonView: LoadedXibView {
    @IBOutlet weak var radioView: RadioView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var delegate: RadioButtonViewDelegate?
    
    var select: Bool {
        get { return radioView.isOn }
        set { radioView.isOn = newValue }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        guard let delegate = delegate else {
            return
        }
        
        delegate.didSelect(radioButtonView: self)
    }
    
    override func setTheme() {
        super.setTheme()
        
        titleLabel.font = FontManager.light(size: 16)
    }
}
