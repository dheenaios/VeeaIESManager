//
//  StringIntView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 10/02/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import UIKit

protocol TitledTextViewDelegate: AnyObject {
    func textDidChange(sender: TitledTextView)
}

class TitledTextView: UIView {
    
    public var tagStr: String = ""
    
    public weak var delegate: TitledTextViewDelegate?
    
    
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet var xibView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet weak var underLineView: UIView!
    
    private let colorErrorColor = UIColor(named: "errorOrange")
    private let underlineColor = UIColor.lightGray
    private var normalTextColor: UIColor {
        return UIColor.label
    }
    
    var readOnly: Bool? {
        willSet {
            guard let ro = newValue else {
                isEnabled = true
                return
            }
            
            textView.textColor = ro ? UIColor.gray : normalTextColor
            isEnabled = !ro
            titleLabel.textColor = ro ? UIColor.gray : normalTextColor
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            textView.isUserInteractionEnabled = isEnabled
        }
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
        get { return textView.text }
        set {
            textView.text = newValue
            updatePlaceholderVisibility()
        }
    }
    
    /// The placeholder text. We use this to show a default or informational text
    @IBInspectable var placeholderText: String? {
        get { return textView.placeholder }
        set {
            _placeholder = newValue
            guard let phl = placeholderLabel else { return }
            phl.text = newValue
        }
    }
    
    func updatePlaceholderVisibility() {
        guard let phl = placeholderLabel else { return }
        phl.isHidden = !(text?.isEmpty ?? true)
    }
    
    // MARK: - Set Text Field as Int Value
    
    /// The explicityly set cell as an Int
    var intText: Int? {
        get {
            guard titleLabel != nil else { return 0 }
            if let intValue = Int(textView.text!) { return intValue }
            return 0
        }
        set {
            guard let intValue = newValue else {
                textView.text = ""
                return
            }
            
            textView.text = "\(intValue)"
        }
    }
    
    /// The placeholder set cell as an Int
    var defaultIntSetting: Int? {
        willSet {
            guard let intValue = newValue else {
                textView.placeholder = ""
                return
            }
            
            textView.placeholder = "\(intValue)"
        }
        
    }
    
    // MARK: -  Dominant Values
    
    // Returns the dominant value as an String with the order of priority being Text Field Text then Place holder text
    var dominantStringValue: String {
        guard let userSavedSetting = textView.text else {
            if textView.placeholder == "" { return "" }
            return textView.placeholder ?? ""
        }
        
        return userSavedSetting
    }
    
    // Returns the dominant value as an Int with the order of priority being Text Field Text then Place holder text
    var dominantIntValue: Int { let dominantSetting = dominantStringValue
        
        if let intValue = Int(dominantSetting) { return intValue }
        return 0
    }
    
    func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    // MARK: - INIT
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        xibView = Bundle.main.loadNibNamed("TitledTextView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        initialPopulate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibView = Bundle.main.loadNibNamed("TitledTextView", owner: self, options: nil)![0] as? UIView
        xibView?.frame = bounds
        addSubview(xibView!)
        initialPopulate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func initialPopulate() {
        titleLabel.text = _title
        errorLabel.text = ""
        
        if let pht = _placeholder {
            textView.placeholder = pht
        }
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
            textView.textColor = colorErrorColor
            errorLabel.textColor = colorErrorColor
            underLineView.backgroundColor = colorErrorColor
        }
        else {
            textView.textColor = normalTextColor
            errorLabel.textColor = normalTextColor
            underLineView.backgroundColor = underlineColor
        }
    }
    
    public func setKeyboardType(type: UIKeyboardType) {
        textView.keyboardType = type
    }
}

extension TitledTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textDidChange(sender: self)
        updatePlaceholderVisibility()
    }
}
