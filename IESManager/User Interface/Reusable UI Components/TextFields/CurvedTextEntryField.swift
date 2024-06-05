//
//  CurvedTextEntryField.swift
//  TextEntryComponenet
//
//  Created by Richard Stockdale on 25/02/2022.
//

import Foundation
import UIKit

class CurvedTextEntryField: LoadedXibView {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var labelBackground: UIView!
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
    public var validator: StringValidator?
    
    public var isPasswordField: Bool = false {
        didSet {
            textField.isSecureTextEntry = false
        }
    }
    
    override func loaded() {
        infoLabel.text = "This is some text text"
        infoLabel.font = FontManager.infoText
        
        backgroundView.backgroundColor = .clear
        backgroundView.layer.borderColor = UIColor.secondaryLabel.cgColor
        labelBackground.backgroundColor = .systemBackground
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.cornerRadius = 7
        backgroundView.clipsToBounds = translatesAutoresizingMaskIntoConstraints
        eyeButton.isHidden = true
    }
    
    public func setValues(title:String,placeHolder:String,keyboardType: UIKeyboardType, tag: Int,validatorType:StringValidator,isSecured:Bool) {
       
        textField.keyboardType = keyboardType
        textField.tag = tag
        validator = validatorType
        infoLabel.text = title
        textField.placeholder = placeHolder
        textField.isSecureTextEntry = isSecured
        eyeButton.isHidden = !isSecured
    }
    
    @IBAction func passwordEyeButtonTapped(_ sender: UIButton) {
        textField.isSecureTextEntry = !textField.isSecureTextEntry
    }
    
}
