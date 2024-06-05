//
//  SecureEntryTextField.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 30/04/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

protocol SecureEntryTextFieldDelegate: AnyObject {
    func valueChanged(sender: SecureEntryTextField)
}

class SecureEntryTextField: UIView {
    
    @IBOutlet private var xibView: UIView!
    @IBOutlet private weak var eye: UIButton!
    @IBOutlet public weak var textField: UITextField!
    
    @IBOutlet public weak var delegate: UITextFieldDelegate? {
        didSet {
            guard textField != nil else {
                return
            }
            
            textField.delegate = delegate
        }
    }
    
    weak public var textChangeDelegate: SecureEntryTextFieldDelegate?
    
    var text: String {
        get {
            return textField.text ?? ""
        }
        set {
            textField.text = newValue
        }
    }
    @IBAction func valueChanged(_ sender: Any) {
        textChangeDelegate?.valueChanged(sender: self)
    }
    
    @IBAction func toggleSecureEntry(_ sender: Any) {
        textField.isSecureTextEntry = !textField.isSecureTextEntry
    }
    
    public func toggleButtonHidden(hidden: Bool) {
        eye.isHidden = hidden
    }
    
    // MARK: - INIT
    override func awakeFromNib() {
        super .awakeFromNib()
        
        xibView = Bundle.main.loadNibNamed("SecureEntryTextField", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        textField.delegate = delegate
        textField.font = FontManager.regular(size: 17)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("SecureEntryTextField", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        
        textField.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
