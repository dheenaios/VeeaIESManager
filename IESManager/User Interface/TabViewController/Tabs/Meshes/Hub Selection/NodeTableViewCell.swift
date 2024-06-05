//
//  NodeTableCellTableViewCell.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/08/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class NodeTableViewCell: UITableViewCell {    
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var activityViewContainer: UIView!
    var activityView: UIActivityIndicatorView?
    @IBOutlet weak var healthPill: UIView!
    @IBOutlet weak var detailStackView: UIStackView!
    
    //The disclosure indicator showing effects the alignent of the pill. Compensate
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    private let disclosureIndicatorWidth: CGFloat = -19
    private let noDisclosureIndicatorConst: CGFloat = -39
    
    var viewModel: NodeTableCellModel!
    var meshDetailViewModel: MeshDetailViewModel!

    func setupcell(cellModel: NodeTableCellModel, vm: MeshDetailViewModel?) {
        self.viewModel = cellModel
        self.accessibilityLabel = cellModel.titleText.data
        self.statusImage?.image = UIImage(named: viewModel.icon.data)
        
        let textWidth = self.contentView.frame.width
        self.titleLabel.frame.size.width = textWidth
        self.titleLabel.text = viewModel.titleText.data
        self.titleLabel.accessibility(config: AccessibilityConfig(label: viewModel.titleText.data, identifier: "meshdetails_node_name"))
        self.titleLabel.sizeToFit()
        
        self.detailLabel?.frame.size.width = textWidth
        self.detailLabel.text = viewModel.detailText.data
        self.detailLabel.accessibility(config: AccessibilityConfig(label: viewModel.detailText.data, identifier: "meshdetails_node_status"))
        self.detailLabel.sizeToFit()
        
        self.meshDetailViewModel = vm
        self.toggleAccessary(viewModel.isAccessoryEnabled.data)
        
        addActivityView()
        self.toggleCell(viewModel.isEnabled.data)
        setHealthState()
        
        self.bindViewModel()
    }
    
    private func setHealthState() {
        healthPill.backgroundColor = viewModel.healthState.data.color
        detailLabel.textColor = viewModel.healthState.data.color
        detailLabel.text = viewModel.healthState.data.stateTitle
        let arrayOfFilteredHubs = self.meshDetailViewModel.hubInfo?.filter{$0.UnitSerial == viewModel.veeaHub.hubId}
        if arrayOfFilteredHubs?.count ?? 0 > 0 {
            let obj =  arrayOfFilteredHubs?.first
            var str = ""
            if ((obj?.NodeState.RebootRequired) == true) {
                let combinedStatusStr = String().setTwoDifferentFontsForLabel(string1: viewModel.healthState.data.stateTitle, string2: " (Restart required)", str1TextColor: viewModel.healthState.data.color, str2TextColor: UIColor(named: "stateNeedReboot")!)
                 detailLabel.attributedText = combinedStatusStr
            }
            else {
                 str = viewModel.healthState.data.stateTitle
                 detailLabel.text = str
            }
        }
    }
    
    private func addActivityView() {
        if activityView == nil {
            activityView = UIActivityIndicatorView(style: .medium)
            activityView?.transform = activityView!.transform.scaledBy(x: 0.8, y: 0.8)
            activityView?.frame = activityViewContainer.bounds
            self.activityViewContainer.addSubview(activityView!)
            activityView?.startAnimating()
        }
    }
    
    func toggleAccessary(_ enable: Bool) {
        if enable {
            self.accessoryType = .disclosureIndicator
            trailingConstraint.constant = noDisclosureIndicatorConst - disclosureIndicatorWidth
        } else {
            self.accessoryType = .none
            trailingConstraint.constant = noDisclosureIndicatorConst
        }
        setNeedsLayout()
    }
    
    func toggleCell(_ enable: Bool) {
        if enable {
            self.selectionStyle = .default
            for view in self.contentView.subviews {
                view.alpha = 1.0
            }
        } else {
            self.selectionStyle = .none
            for view in self.contentView.subviews {
                view.alpha = 0.45
            }
        }
    }
    
    func bindViewModel() {
        viewModel.icon.observer = { [weak self] imageName in
            self?.statusImage?.image = UIImage(named: imageName)
        }
        
        viewModel.isAccessoryEnabled.observer = { [weak self] enabled in
            self?.toggleAccessary(enabled)
        }
        
        viewModel.isActivityEnabled.observer = { [weak self] enabled in
            
            if let s = self {
                if enabled {
                    s.detailStackView.insertSubview(s.activityViewContainer, at: 0)
                    s.activityView?.startAnimating()
                } else {
                    s.detailStackView.removeArrangedSubview(s.activityViewContainer)
                    s.activityView?.stopAnimating()
                }
                self?.setNeedsLayout()
            }
        }
        
        viewModel.titleText.observer = { [weak self] text in
            self?.titleLabel.text = text
            self?.setNeedsLayout()
            self?.titleLabel.frame.size.width = self?.contentView.frame.width ?? 300
        }
        
        viewModel.detailText.observer = { [weak self] text in
            self?.setHealthState()
            self?.setNeedsLayout()
        }
        
        viewModel.isEnabled.observer = { [weak self] enabled in
            self?.toggleCell(enabled)
        }
        
        viewModel.isAvailableOnLan.observer = { [weak self] enabled in
            self?.toggleCell(enabled)
            self?.toggleAccessary(true)
        }
        
        viewModel.healthState.observer = { [weak self] state in
            self?.setHealthState()
        }
    }
    
    private func setupViews() {
        healthPill.layer.cornerRadius = 3
        healthPill.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
}
