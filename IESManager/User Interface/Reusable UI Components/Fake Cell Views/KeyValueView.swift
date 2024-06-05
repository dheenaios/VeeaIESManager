//
//  KeyValueView.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 17/02/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

protocol KeyValueViewDelegate: AnyObject {
    func viewWasTapped(sender: KeyValueView)
}

class  KeyValueView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var upperSeperator: UIView!
    @IBOutlet weak var lowerSeperator: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var disclosureView: UIImageView!
    @IBOutlet weak var valueConstraint: NSLayoutConstraint!
    private var noDisclosure: CGFloat = 24
    
    private weak var hostVc: UIViewController?
    private weak var delegate: KeyValueViewDelegate?
    
    private var questionText = ""
    private var isActive = true
    
    var value: String {
        get { return valueLabel.text ?? "" }
        set { valueLabel.text = newValue }
    }
    
    
    func setUp(key: String,
               value: String,
               showLowerSep: Bool,
               showUpperSep: Bool,
               hostViewController: UIViewController?,
               questionText: String?) {
        self.keyLabel.text = key
        self.valueLabel.text = value
        self.lowerSeperator.isHidden = !showLowerSep
        self.upperSeperator.isHidden = !showUpperSep
        self.hostVc = hostViewController
        if let q = questionText { self.questionText = q }
    }
    
    func setUp(key: String,
               value: String,
               showLowerSep: Bool,
               showUpperSep: Bool,
               delegate: KeyValueViewDelegate?,
               questionText: String?) {
        self.keyLabel.text = key
        self.valueLabel.text = value
        self.lowerSeperator.isHidden = !showLowerSep
        self.upperSeperator.isHidden = !showUpperSep
        self.delegate = delegate
        if let q = questionText { self.questionText = q }
    }
    
    func showDisclosureIndicator(show: Bool) {
        disclosureView.isHidden = !show
        if show {
            valueConstraint.constant = noDisclosure + 8
        }
        else {
            valueConstraint.constant = noDisclosure
        }
    }
    
    func setActive(active: Bool) {
        isActive = active
        
        self.contentView.alpha = active ? 1.0 : 0.3
        self.contentView.isUserInteractionEnabled = active
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if let d = delegate {
            d.viewWasTapped(sender: self)
            return
        }
        
        guard let hvc = hostVc,
              let keyLabelText = keyLabel.text,
              let initialValue = valueLabel.text else {
            return
        }
        
        Utils.showInputAlert(from: hvc,
                             title: keyLabelText,
                             message: questionText,
                             initialValue: initialValue,
                             okButtonText: "Ok".localized()) { (newValue) in
            self.valueLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        contentView = Bundle.main.loadNibNamed("KeyValueView", owner: self, options: nil)![0] as? UIView
        contentView?.frame = bounds
        addSubview(contentView!)
        
        keyLabel.text = ""
        valueLabel.text = ""
        showDisclosureIndicator(show: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = Bundle.main.loadNibNamed("KeyValueView", owner: self, options: nil)![0] as? UIView
        contentView?.frame = bounds
        addSubview(contentView!)
        
        keyLabel.text = ""
        valueLabel.text = ""
        showDisclosureIndicator(show: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
