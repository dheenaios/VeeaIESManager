//
//  LanPickerView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 23/07/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class LanPickerView: PickerViewBaseClass {
    
    var hostVc: LanConfigurationChildViewControllerProtocol?
    
    enum Lans: String, CaseIterable {
        case lan1 = "LAN 1"
        case lan2 = "LAN 2"
        case lan3 = "LAN 3"
        case lan4 = "LAN 4"
        
        static func lanFromInt(lan: Int) -> Lans {
            switch lan {
            case 0:
                return .lan1
            case 1:
                return .lan2
            case 2:
                return .lan3
            case 3:
                return .lan4
            default:
                return lan1
            }
        }
        
        var lanNumber: Int {
            switch self {
            case .lan1: return 0
            case .lan2: return 1
            case .lan3: return 2
            case .lan4: return 3
            }
        }
    }
    
    var selectedLan: Lans = .lan1 {
        didSet {
            setLan(lan: selectedLan)
        }
    }
    
    private var lanNames = [Lans.lan1.rawValue, Lans.lan2.rawValue ,Lans.lan3.rawValue, Lans.lan4.rawValue]
    
    @IBAction func tapped(_ sender: Any) {
        guard let vc = hostVc else { return }
        
        var options = [MenuViewController.MenuItemOption]()
        for lanName in lanNames {
            options.append(MenuViewController.MenuItemOption(title: lanName))
        }
        
        let picker = MenuViewController.createMenuViewController(title: "Choose LAN".localized(),
                                                                 subTitle: "Choose a LAN to configure".localized(),
                                                                 options: options,
                                                                 originView: self) { index, str in
            if let lan = Lans.init(rawValue: str) {
                self.setLan(lan: lan)
            }
        }
        
        vc.present(picker, animated: true)
    }
    
    private func setLan(lan: Lans) {
        valueText.text = lan.rawValue
        hostVc?.childDidUpdateSelectedLan(lan: lan.lanNumber)
    }
}
