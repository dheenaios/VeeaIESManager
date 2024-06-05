//
//  WanPickerView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 23/07/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class WanPickerView: PickerViewBaseClass {    
    var hostVc: WanGatewayTabViewControllerDelegate?
    
    enum Wans: String, CaseIterable {
        case wan1 = "WAN 1"
        case wan2 = "WAN 2"
        case wan3 = "WAN 3"
        case wan4 = "WAN 4"
        
        static func wanFromInt(lan: Int) -> Wans {
            switch lan {
            case 0:
                return .wan1
            case 1:
                return .wan2
            case 2:
                return .wan3
            case 3:
                return .wan4
            default:
                return wan1
            }
        }
        
        var wanNumber: Int {
            switch self {
            case .wan1: return 0
            case .wan2: return 1
            case .wan3: return 2
            case .wan4: return 3
            }
        }
    }
    
    var selectedWan: Wans = .wan1 {
        didSet {
            setWan(wan: selectedWan)
        }
    }
    
    private var lanNames = [Wans.wan1.rawValue, Wans.wan2.rawValue ,Wans.wan3.rawValue, Wans.wan4.rawValue]
    
    @IBAction func tapped(_ sender: Any) {
        guard let vc = hostVc else { return }
        
        var options = [MenuViewController.MenuItemOption]()
        for lanName in lanNames {
            options.append(MenuViewController.MenuItemOption(title: lanName))
        }
        
        let picker = MenuViewController.createMenuViewController(title: "Choose WAN".localized(),
                                                                 subTitle: "Choose a WAN to configure".localized(),
                                                                 options: options,
                                                                 originView: self) { index, str in
            if let wan = Wans.init(rawValue: str) {
                self.setWan(wan: wan)
            }
        }
        
        vc.present(picker, animated: true)
    }
    
    private func setWan(wan: Wans) {
        valueText.text = wan.rawValue
        hostVc?.selectedWan = wan.wanNumber
    }
}
