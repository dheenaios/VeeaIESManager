//
//  MacAddressEntryTextView.swift
//  MacAddress_TextField
//
//  Created by Richard Stockdale on 02/05/2018.
//  Copyright © 2018 JunctionSeven. All rights reserved.
//

import UIKit

protocol MacAddressTextViewProtocol {
    func entryWasDeleted(deletedView: MacAddressEntryTextView)
    func entryCompleted(completedView: MacAddressEntryTextView)
}

class MacAddressEntryTextView: UIView {
    public var delegate: MacAddressTextViewProtocol?
    
    private var xibView: UIView?
    private var octets = [String]()
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet private weak var octet0: UITextField!
    @IBOutlet private weak var octet1: UITextField!
    @IBOutlet private weak var octet2: UITextField!
    @IBOutlet private weak var octet3: UITextField!
    @IBOutlet private weak var octet4: UITextField!
    @IBOutlet private weak var octet5: UITextField!
    @IBOutlet private weak var deleteButton: UIButton!
    
    
    
    private var textFields: [UITextField] {
        get {
            return [octet0, octet1, octet2, octet3, octet4, octet5]
        }
    }
    
    var macAddress: String {
        get {
            var macAddress = String()
            
            for field in textFields {
                guard let text = field.text else {
                    return ""
                }
                
                macAddress.append(contentsOf: text)
                macAddress.append(contentsOf: ":")
            }
            
            // Remove the last colon
            return String(macAddress.dropLast())
        }
        set {
            processMacAddress(address: newValue)
        }
    }
    
    private func processMacAddress(address: String) {
        octets = [String]()
        let stripped = address.replacingOccurrences(of: ":", with: "").lowercased()
        
        var workingString = ""
        for char in stripped {
            workingString.append(char)
            
            if workingString.count == 2 {
                octets.append(workingString)
                workingString = ""
            }
        }
        
        if octets.count > 6 {
            return
        }
        
        populateMacAddress()
    }
    
    private func populateMacAddress() {
        guard octets.count <= 6 else {
            return
        }
        
        let textFields = [octet0, octet1, octet2, octet3, octet4, octet5]
        
        for (index, octet) in octets.enumerated() {
            textFields[index]?.text = octet
        }
    
    }
    
    @IBAction private func deleteTapped(_ sender: Any) {
        delegate?.entryWasDeleted(deletedView: self)
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        guard let entry = sender.text else {
            return
        }
        
        let sanitisedString = santisedString(string: entry)
        sender.text = sanitisedString
        
        let entryLength = sanitisedString.count
        let nextFieldIndex = sender.tag + 1
        
        if entryLength == 2 {
            if sender.tag == 5 {
                sender.resignFirstResponder()
                delegate?.entryCompleted(completedView: self)
                return
            }
            
            textFields[nextFieldIndex].becomeFirstResponder()
        }
        else if entryLength > 2 {
            // Split the string
            let thisFieldText = sanitisedString.prefix(2)
            let remainderText = sanitisedString.suffix(entry.count - 2)
            
            if sender.tag == 5 {
                sender.text = String(thisFieldText)
                sender.resignFirstResponder()
                return
            }
            
            sender.text = String(thisFieldText)
            textFields[nextFieldIndex].text = String(remainderText)
            
            // Add the remainder to the next field
            textFields[nextFieldIndex].becomeFirstResponder()
            
            // Move on to the next cell, placing the cursor at the end of the cell
        }
    }
    
    private func santisedString(string: String) -> String {
        let pattern = "^*[0-9a-fA-F]*$"
        
        // Does the whole string match?
        if let typeRange = string.range(of: pattern,
                                        options: .regularExpression) {
            
            let fullMatch = String(string[typeRange])
            if fullMatch.count == string.count {
                return string
            }
        }
        
        // If not then spin through the string and remove unwanted chars
        var strippedString = String()
        for char in string {
            let str = String(char)
            
            if let typeRange = str.range(of: pattern,
                                         options: .regularExpression) {
                let fullMatch = String(string[typeRange])
                if fullMatch.count > 0 {
                    strippedString.append(char)
                }
            }
        }
        
        return strippedString
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()

        xibView = Bundle.main.loadNibNamed("MacAddressEntryTextView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("MacAddressEntryTextView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 0.5
        containerView.layer.cornerRadius = 2.0
    }
}

extension MacAddressEntryTextView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        // TODO. Place the cursor at the end
        
        return true
    }
}

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

//class CrippledTextView: UITextView {
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        <#code#>
//    }
//}

