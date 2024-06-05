//
//  StatusBar.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 26/01/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

protocol StatusBarDelegate: AnyObject {
    func inUseChanged(inUse: Bool)
    func inUseTitleTapped()
}

class StatusBarWithLeftRightContent: UIView {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet weak var inUseSwitch: UISwitch!
    @IBOutlet private weak var inUseLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var labelsLeadingContraint: NSLayoutConstraint!
    private let switchHiddenConstraint: CGFloat = -51
    private let switchShowingConstraint: CGFloat = 8
    
    weak var delegate: StatusBarDelegate?
    
    var inUse: Bool {
        get { return inUseSwitch.isOn }
        set { inUseSwitch.isOn = newValue }
    }
    
    var switchTitleText: String {
        get { return inUseLabel.text ?? "" }
        set { inUseLabel.text = newValue }
    }
    
    var switchSubTitleText: String {
        get { return subtitleLabel.text ?? "" }
        set { subtitleLabel.text = newValue }
    }
    
    var hideSwitch: Bool = false {
        didSet {
            inUseSwitch.isHidden = hideSwitch
            
            if hideSwitch {
                labelsLeadingContraint.constant = switchHiddenConstraint
            }
            else {
                labelsLeadingContraint.constant = switchShowingConstraint
            }
            
            layoutIfNeeded()
        }
    }
    
    func switchSubTitleTextFaded(faded: Bool) {
        subtitleLabel.alpha = faded ? 0.4 : 1.0
    }
    
    @IBAction func inUseChanged(_ sender: UISwitch) {
        inUse = sender.isOn
        delegate?.inUseChanged(inUse: inUse)
    }
    
    @IBAction func inUseTitleTapped(_ sender: Any) {
        delegate?.inUseTitleTapped()
    }
    
    func setConfig(config: StatusBarConfig) {
        setUp(text: config.text ?? "",
              barBackGroundColor: config.barBackgroundColor,
              iconColor: config.iconColor,
              icon: config.icon)
    }
    
    func setUp(text: String,
               barBackGroundColor: UIColor?,
               iconColor: UIColor?,
               icon: UIImage?) {
        DispatchQueue.main.async {
            self.textLabel.text = text
            
            self.contentView.backgroundColor = barBackGroundColor
            self.iconImageView.tintColor = iconColor
            self.iconImageView.image = icon
        }
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        contentView = Bundle.main.loadNibNamed("StatusBarWithSwitch", owner: self, options: nil)![0] as? UIView
        contentView?.frame = bounds
        addSubview(contentView!)
        
        textLabel.text = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = Bundle.main.loadNibNamed("StatusBarWithSwitch", owner: self, options: nil)![0] as? UIView
        contentView?.frame = bounds
        addSubview(contentView!)
        
        textLabel.text = ""
        switchSubTitleText = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
