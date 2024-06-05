//
//  HealthPillView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/08/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class HealthPillView: UIView {

    @IBOutlet weak var colorIndicatorYPosConstraint: NSLayoutConstraint!
    private static let nib = "HealthPillView"
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var backingView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var healthIndicator: UIView!
    @IBOutlet weak var restartInfoLabel: UILabel!
    public func setState(state: MeshNodeHealthState) {
        setDetails(pillColor: state.color, titleStr: state.stateTitle, subTitleStr: state.meshDescription)
    }
    
    private func setDetails(pillColor: UIColor, titleStr: String, subTitleStr: String) {
        healthIndicator.backgroundColor = pillColor
        title.text = titleStr
        title.isAccessibilityElement = true
        title.accessibility(config: AccessibilityConfig(label: titleStr, identifier: "mesh_head_status"))
        subTitle.text = subTitleStr
        colorIndicatorYPosConstraint.constant = 0
        restartInfoLabel.isHidden = true
    }
    
    public func setDetailsWithRestartStatus(pillColor: UIColor, titleStr: String, subTitleStr: String,restartStatusCount:Int) {
        healthIndicator.backgroundColor = pillColor
        title.text = titleStr
        title.isAccessibilityElement = true
        title.accessibility(config: AccessibilityConfig(label: titleStr, identifier: "mesh_head_status"))
        subTitle.text = subTitleStr
        restartInfoLabel.text = "\(restartStatusCount)" + "VeeaHubs need a restart".localized()
        restartInfoLabel.textColor = UIColor(named: "stateNeedReboot")!
        colorIndicatorYPosConstraint.constant = 0
        restartInfoLabel.isHidden = true
        if restartStatusCount != 0 {
            colorIndicatorYPosConstraint.constant = -10
            restartInfoLabel.isHidden = false
            if restartStatusCount == 1 {
                restartInfoLabel.text = "\(restartStatusCount)" + "VeeaHub needs a restart".localized()
            }
            else {
                restartInfoLabel.text = "\(restartStatusCount)" + "VeeaHubs need a restart".localized()
            }
        }
    }
    
    private func setup() {
        backingView.layer.cornerRadius = 15
        backingView.clipsToBounds = true
        
        healthIndicator.layer.cornerRadius = 3
        healthIndicator.clipsToBounds = true
        
        setDetails(pillColor: .lightGray, titleStr: "", subTitleStr: "")
    }
    
    // MARK: - Init
    override func awakeFromNib() {
        super .awakeFromNib()
        
        rootView = Bundle.main.loadNibNamed(HealthPillView.nib, owner: self, options: nil)![0] as? UIView
        rootView?.frame = bounds
        addSubview(rootView!)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        rootView = Bundle.main.loadNibNamed(HealthPillView.nib, owner: self, options: nil)![0] as? UIView
        rootView?.frame = bounds
        addSubview(rootView!)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        rootView = Bundle.main.loadNibNamed(HealthPillView.nib, owner: self, options: nil)![0] as? UIView
        rootView?.frame = bounds
        addSubview(rootView!)
        setup()
    }
}
