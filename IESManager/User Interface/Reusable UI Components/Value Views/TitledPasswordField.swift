//
//  StringIntView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 10/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

protocol TitledPasswordFieldDelegate: AnyObject {
    func textDidChange(sender: TitledPasswordField)
}

class TitledPasswordField: UIView {
    
    public var tagStr: String = ""
    
    public weak var delegate: TitledPasswordFieldDelegate?
    
    @IBOutlet var xibView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var textField: SecureEntryTextField!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet weak var underLineView: UIView!
    
    private let colorErrorColor = UIColor(named: "errorOrange")
    private let underlineColor = UIColor.lightGray
    private var normalTextColor: UIColor {
        return UIColor.label
    }
    
    var readOnly: Bool? {
        willSet {
            textField.textField.clearButtonMode = .never
            guard let ro = newValue else {
                textField.textField.isEnabled = true
                return
            }
            
            textField.textField.alpha = ro ? 0.3 : 1.0
            textField.textField.isEnabled = !ro
            titleLabel.alpha = ro ? 0.3 : 1.0
        }
    }
    
    
    
    @objc func textFieldDidChange(_ sender: UITextField) {
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
        get { return textField.textField.text }
        set { textField.textField.text = newValue }
    }
    
    /// The placeholder text. We use this to show a default or informational text
    @IBInspectable var placeholderText: String? {
        get { return textField.textField.placeholder }
        set {
            _placeholder = newValue
            guard titleLabel != nil else { return }
            textField.textField.placeholder = (newValue?.isEmpty)! ? "" : newValue
            
        }
    }
    
    // MARK: - Set Text Field as Int Value
    
    /// The explicityly set cell as an Int
    var intText: Int? {
        get {
            guard titleLabel != nil else { return 0 }
            if let intValue = Int(textField.textField.text!) { return intValue }
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
                textField.textField.placeholder = ""
                return
            }
            
            textField.textField.placeholder = "\(intValue)"
        }
        
    }
    
    // MARK: -  Dominant Values
    
    // Returns the dominant value as an String with the order of priority being Text Field Text then Place holder text
    var dominantStringValue: String {
        guard let userSavedSetting = textField.textField.text else {
            if textField.textField.placeholder == "" { return "" }
            return textField.textField.placeholder ?? ""
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
        
        xibView = Bundle.main.loadNibNamed("TitledPasswordField", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        textField.delegate = self
        initialPopulate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("TitledPasswordField", owner: self, options: nil)![0] as? UIView
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
        textField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        titleLabel.text = _title
        textField.textField.placeholder = _placeholder
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
            textField.textField.textColor = colorErrorColor
            errorLabel.textColor = colorErrorColor
            underLineView.backgroundColor = colorErrorColor
        }
        else {
            textField.textField.textColor = normalTextColor
            errorLabel.textColor = normalTextColor
            underLineView.backgroundColor = underlineColor
        }
    }
    
    public func setKeyboardType(type: UIKeyboardType) {
        textField.textField.keyboardType = type
    }
}

extension TitledPasswordField : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textFieldDidChange(textField)
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        textFieldDidChange(textField)
        return true
    }
}
