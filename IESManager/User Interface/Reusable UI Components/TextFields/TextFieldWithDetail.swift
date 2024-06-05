//
//  TextFieldWithDetail.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/11/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

class TextFieldWithDetail: UIView {
    
    private var detailLabel: UILabel!
    var textField: UITextField!
    
    weak var textfieldDelegate: UITextFieldDelegate? {
        didSet {
            self.textField?.delegate = textfieldDelegate
        }
    }

    convenience init(detail: String, text: String) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
        self.backgroundColor = .white
        
        let lineThickness: CGFloat = 0.5
        self.drawLine(from: .zero, to: CGPoint(x: self.bounds.width, y: 0), thickness: lineThickness, color: UIColor(white: 0, alpha: 0.15))
        
        // Label
        detailLabel = UILabel(frame: CGRect(x: UIConstants.Margin.side, y: 0, width: self.frame.width, height: 0))
        detailLabel.text = detail
        titleBaseStyle(detailLabel)
        detailLabel.frame.size.height = self.frame.height
        if detailLabel.frame.width > (self.frame.width/2) {
            detailLabel.frame.size.width = self.frame.width/2
        }
                
        self.addSubview(detailLabel)
        
        // TextField
        textField = VUITextField(frame: CGRect(x: (self.frame.width/2)-5, y: 5, width: self.frame.width/2, height: self.frame.height-10))
        transparentFieldStyle(textField)
        
        textField.attributedPlaceholder =
        NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.autocorrectionType = .no
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 16.0
        textField.textAlignment = .center
        self.addSubview(textField)
        
        self.drawLine(from: CGPoint(x: 0, y: self.bounds.height - lineThickness), to: CGPoint(x: self.bounds.width, y: self.bounds.height - lineThickness), thickness: lineThickness, color: UIColor(white: 0, alpha: 0.15))
        
        backgroundColor = UIColor.secondarySystemBackground
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.textColor = UIColor.label
        detailLabel.backgroundColor = UIColor.secondarySystemBackground
        detailLabel.textColor = UIColor.label
    }

}
