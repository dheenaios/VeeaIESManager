//
//  PortsPickerView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 17/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

protocol PortsPickerProtocol: UIViewController {
    func didSelectPort(port: PortsPickerView.PortDetail)
}

class PortsPickerView: PickerViewBaseClass {
    
    struct PortDetail {
        var portNumber: Int // Starting at 0
        var portState: PortStatusBarConfig
        var portName: String
        
        var portDescription: String {
            if portName.isEmpty {
                return "Port \(portNumber + 1)"
            }
            
            return "Port \(portNumber + 1): \(portName)"
        }
        
        var stateImage: UIImage? {
            guard let icon = portState.icon else { return nil }
            
            if let color = portState.iconColor {
                icon.withRenderingMode(.alwaysTemplate)
                return icon.tintWithColor(color)
            }
            
            return icon
        }
        
        var stateTextColor: UIColor? {
            portState.iconColor
        }
    }
    
    // MARK: -
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    var portDetails: [PortDetail]? {
        didSet {
            update()
        }
    }
    
    var hostVc: PortsPickerProtocol?
    private var selectedPortIndex: Int?
    
    @IBAction func tapped(_ sender: Any) {
        guard let vc = hostVc,
              let portDetails = portDetails  else { return }
        
        update()
        
        var options = [MenuViewController.MenuItemOption]()
        for port in portDetails {
            options.append(MenuViewController.MenuItemOption(title: port.portDescription,
                                                             image: port.stateImage,
                                                             textColor: port.stateTextColor))
        }
        
        let picker = MenuViewController.createMenuViewController(title: "Choose a Port".localized(),
                                                                 subTitle: "Choose a Port to configure".localized(),
                                                                 options: options,
                                                                 originView: self) { index, str in
            self.setPort(portIndex: index)
        }
        
        vc.present(picker, animated: true)
    }
    
    func update() {
        guard let portDetails = portDetails,
                  let selectedPortIndex = selectedPortIndex else { return }
        let selectedPort = portDetails[selectedPortIndex]
        valueText.text = selectedPort.portDescription
        statusImageView.image = selectedPort.stateImage
    }
    
    func setPort(portIndex: Int) {
        selectedPortIndex = portIndex
        guard let portDetails = portDetails else { return }
        let port = portDetails[portIndex]
        valueText.text = port.portDescription
        statusImageView.image = port.stateImage
        hostVc?.didSelectPort(port: port)
    }
}
