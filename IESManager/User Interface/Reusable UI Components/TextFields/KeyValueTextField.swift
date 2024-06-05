//
//  KeyValueTextField.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 06/02/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

protocol KeyValueTextFieldDelegate {
    func textDidChange(sender: KeyValueTextField, newText: String)
}

class KeyValueTextField: UIView {
    
    @IBOutlet var xibView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet weak var eyeButton: UIButton!
    
    var contentsValid: Bool {
        get {
            guard let validator = validator,
                  let entry = textField.text else {
                return true
            }
            
            return validator.validate(str: entry).0
        }
    }
    
    var delegate: KeyValueTextFieldDelegate?
    
    var text: String {
        get {
            return textField.text ?? ""
        }
        set {
            textField.text = newValue
        }
    }
    
    // Optional Validation
    public var validator: StringValidator?
    
    public var isPasswordField: Bool = false {
        didSet {
            textField.isSecureTextEntry = false
            eyeButton.isHidden = !isPasswordField
        }
    }
    
    public func errorText(errorText: String) {
        errorLabel.text = errorText
    }
    
    public func setValues(title: String, placeHolder: String, text: String) {
        titleLabel.text = title
        textField.placeholder = placeHolder
        textField.text = text
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        xibView = Bundle.main.loadNibNamed("KeyValueTextField", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        textField.delegate = self
        titleLabel.text = ""
        textField.placeholder = ""
        errorLabel.text = ""
        eyeButton.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("KeyValueTextField", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        textField.delegate = self
        titleLabel.text = ""
        textField.placeholder = ""
        errorLabel.text = ""
        eyeButton.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    private var fieldActive: Bool = false {
        didSet {
            titleLabel.textColor = fieldActive ? UIColor.systemBlue : UIColor.lightGray
        }
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        validate()
    }
    
    private func validate() {
        errorLabel.text = ""
        delegate?.textDidChange(sender: self, newText: textField.text ?? "")
        
        guard let validator = validator, let str = textField.text else {
            return
        }
        
        let validationResult = validator.validate(str: str)
        
        
        let success = validationResult.0
        if !success {
            guard let message = validationResult.1 else {
                return
            }
            
            errorLabel.text = message
        }
    }
    
    @IBAction func secureInputTapped(_ sender: Any) {
        textField.isSecureTextEntry = !textField.isSecureTextEntry
    }
}

extension KeyValueTextField : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        fieldActive = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        fieldActive = false
        validate()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (isPasswordField == true
                && !self.textField.isSecureTextEntry) {
            //self.textField.isSecureTextEntry = true
        }
        return true
    }
}
