//
//  NoDevicesView.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/7/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

final class NoDevicesView: UIView {
    
    var openDeviceCallback: Callback?
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        self.backgroundColor = .clear
        self.addOffset(UIConstants.Margin.top * 2)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: self.frame.height, width: 90, height: 90))
        imageView.image = UIImage(named: "no-hub")
        imageView.contentMode = .scaleAspectFill
        imageView.centerInView(superView: self, mode: .horizontal)
        self.push(imageView)
        self.addOffset(UIConstants.Margin.top * 2)
        
        let contentWidth = self.bounds.width - (UIConstants.Margin.side * 2)
        let titleLabel = VUITitle(frame: CGRect(x: 0, y: self.frame.height, width: contentWidth, height: 0), title: "No VeeaHubs, yet".localized())
        titleLabel.centerInView(superView: self, mode: .horizontal)
        self.push(titleLabel)
        self.addOffset(UIConstants.Margin.side)
        
        let desc = UILabel(frame: CGRect(x: 0, y: self.frame.height, width: contentWidth, height: 0))
        desc.text = "You don't have any VeeaHubs added yet. \n Please tap on add VeeaHub button below to get started.".localized()
        multilineCenterLabelStyle(desc)
        desc.centerInView(superView: self, mode: .horizontal)
        self.push(desc)
        
        self.addOffset(UIConstants.Margin.top * 2)
        
        let addDeviceButton = VUIFlatButton(frame: CGRect(x: UIConstants.Margin.side, y: self.frame.height, width: contentWidth, height: 40),
                                            type: .green,
                                            title: "Add New VeeaHub".localized())
        addDeviceButton.accessibility(config: AccessibilityConfigurations.buttonAddFirstHub)
        addDeviceButton.addTarget(self, action: #selector(NoDevicesView.openAddNewDeviceView), for: .touchUpInside)
        self.push(addDeviceButton)
        self.addOffset(UIConstants.Margin.top)
        
    }
    
    @objc func openAddNewDeviceView() {
        openDeviceCallback?()
    }
}
