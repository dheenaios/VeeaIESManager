//
//  StringIntView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 10/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

protocol TitledTextFieldDelegate: AnyObject {
    func textDidChange(sender: TitledTextField)
}

class TitledTextField: UIView {
    
    public var tagStr: String = ""
    
    public weak var delegate: TitledTextFieldDelegate?
    
    @IBOutlet var xibView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet weak var underLineView: UIView!
    
    private let colorErrorColor = UIColor(named: "errorOrange")
    private let underlineColor = UIColor.lightGray
    private var normalTextColor: UIColor {
        return UIColor.label
    }
    
    var readOnly: Bool? {
        willSet {
            textField.clearButtonMode = .never
            guard let ro = newValue else {
                textField.isEnabled = true
                return
            }
            
            textField.textColor = ro ? UIColor.gray : normalTextColor
            textField.isEnabled = !ro
            titleLabel.textColor = ro ? UIColor.gray : normalTextColor
        }
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        delegate?.textDidChange(sender: self)
    }
    
    // MARK: - Set Title
    
    /// Returns the current title of the cell
    private var _title: String?
    private var _placeholder: String?
    @IBInspectable var title: String? {
        get {
            guard titleLabel != nil else { return "" }
            return titleLabel.text
        }
        set {
            _title = newValue
            guard titleLabel != nil else { return }
            titleLabel.text = newValue
        }
    }
    
    // MARK: - Set Text Field as String Value
    
    /// The explicityly set cell as a String
    @IBInspectable var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    
    /// The placeholder text. We use this to show a default or informational text
    @IBInspectable var placeholderText: String? {
        get { return textField.placeholder }
        set {
            _placeholder = newValue
            guard titleLabel != nil else { return }
            textField.placeholder = (newValue?.isEmpty)! ? "" : newValue
            
        }
    }
    
    // MARK: - Set Text Field as Int Value
    
    /// The explicityly set cell as an Int
    var intText: Int? {
        get {
            guard titleLabel != nil else { return 0 }
            if let intValue = Int(textField.text!) { return intValue }
            return 0
        }
        set {
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
                textField.placeholder = ""
                return
            }
            
            textField.placeholder = "\(intValue)"
        }
        
    }
    
    // MARK: -  Dominant Values
    
    // Returns the dominant value as an String with the order of priority being Text Field Text then Place holder text
    var dominantStringValue: String {
        guard let userSavedSetting = textField.text else {
            if textField.placeholder == "" { return "" }
            return textField.placeholder ?? ""
        }
        
        return userSavedSetting
    }
    
    // Returns the dominant value as an Int with the order of priority being Text Field Text then Place holder text
    var dominantIntValue: Int { let dominantSetting = dominantStringValue
        
        if let intValue = Int(dominantSetting) { return intValue }
        return 0
    }
    
    func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    
    // MARK: - INIT
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        xibView = Bundle.main.loadNibNamed("TitledTextField", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        textField.delegate = self
        initialPopulate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("TitledTextField", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        textField.delegate = self
        initialPopulate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func initialPopulate() {
        titleLabel.text = _title
        textField.placeholder = _placeholder
        errorLabel.text = ""
    }
    
    func setErrorLabel(message: String?) {
        if message == nil || message!.isEmpty {
            setErrorShowing(showing: false)
            errorLabel.text = ""
            return
        }
        
        errorLabel.text = message
        setErrorShowing(showing: true)
    }
    
    private func setErrorShowing(showing: Bool) {
        if showing {
            textField.textColor = colorErrorColor
            errorLabel.textColor = colorErrorColor
            underLineView.backgroundColor = colorErrorColor
        }
        else {
            textField.textColor = normalTextColor
            errorLabel.textColor = normalTextColor
            underLineView.backgroundColor = underlineColor
        }
    }
    
    public func setKeyboardType(type: UIKeyboardType) {
        textField.keyboardType = type
    }
}

extension TitledTextField : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Keyboard Accessory
extension TitledTextField {
    public func addSubnetEntryAccessory() {
        let toolBar = accessoryToolBar(field: self.textField)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let forwardSlashButton = UIBarButtonItem(title: " / (Add subnet prefix)".localized(), style: .plain, target: self, action: #selector(forwardSlashButtonTapped))
        forwardSlashButton.setTitleTextAttributes([.foregroundColor: UIColor.vPurple], for: .normal)

        toolBar.setItems([flexSpace, forwardSlashButton, flexSpace], animated: true)
    }

    @objc private func forwardSlashButtonTapped() {
        guard let text = self.text else { return }
        if text.contains("/") == true { return }
        self.text = text + "/"
    }

    private func accessoryToolBar(field: UITextField) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolBar.barStyle = .default
        field.inputAccessoryView = toolBar

        return toolBar
    }
}
