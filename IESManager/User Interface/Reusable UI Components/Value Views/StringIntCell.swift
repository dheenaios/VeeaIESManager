//
//  StringIntCell.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 19/01/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

class StringIntCell: BaseValueTableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    
    private let noDefaultSetting = "No Default Set"
    
    // MARK: - Set Title
    
    /// Returns the current title of the cell
    var title: String? {
        willSet {
            
            // TODO: Set type to String
            
            titleLabel.text = newValue
        }
    }
    
    // MARK: - Set Text Field as String Value
    
    /// The explicityly set cell as a String
    var userSavedSetting: String? {
        willSet {
            
            // TODO: Set type to String
            textField.text = newValue
        }
    }
    
    /// The placeholder text. We use this to show a default or informational text
    var defaultSetting: String? {
        willSet {
            
            // TODO: Set type to String
            
            textField.placeholder = (newValue?.isEmpty)! ? noDefaultSetting : newValue
        }
    }
    
    // MARK: - Set Text Field as Int Value
    
    /// The explicityly set cell as an Int
    var userSavedIntSetting: Int? {
        willSet {
            guard let intValue = newValue else {
                textField.text = ""
                
                return
            }
            
            textField.text = "\(intValue)"
        }
    }
    
    /// The placeholder set cell as an Int
    var defaultIntSetting: Int? {
        willSet {
            guard let intValue = newValue else {
                textField.placeholder = noDefaultSetting
                
                return
            }
            
            textField.placeholder = "\(intValue)"
        }

    }
    
    // MARK: - Get current values from the textfield
    
    // Get the current user entered value as an Int from the text field
    var intValue: Int {
        if let intValue = Int(textField.text!) {
            return intValue
        }
        
        return 0
    }
    
    // Get the current user entered value as an String from the text field
    var stringValue: String {
        if let stringValue = textField.text {
            return stringValue
        }
        
        return ""
    }
    
    // MARK: -  Dominant Values
    
    // Returns the dominant value as an String with the order of priority being Text Field Text then Place holder text
    var dominantStringValue: String {
        guard let userSavedSetting = textField.text else {
            if textField.placeholder == noDefaultSetting {
                return ""
            }
            
            return textField.placeholder ?? ""
        }
        
        return userSavedSetting
    }
    
    // Returns the dominant value as an Int with the order of priority being Text Field Text then Place holder text
    var dominantIntValue: Int {
        let dominantSetting = dominantStringValue
        
        if let intValue = Int(dominantSetting) {
            return intValue
        }
        
        return 0
    }
    
    override func awakeFromNib() {
         textField.delegate = self
    }
    
    override func dismissKeyboard() {
        textField.resignFirstResponder()
    }
}

extension StringIntCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        // To be implemented by subclasses
        
        return true
    }
}
