//
//  AdvancedSettingsMenuTableViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 21/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

class HomeAdvancedSettingsMenuTableViewController: HomeUserBaseTableViewController {

    static func new() -> HomeAdvancedSettingsMenuTableViewController {
        let vc = UIStoryboard(name: StoryboardNames.WiFiSettings.rawValue, bundle: nil).instantiateViewController(withIdentifier: "HomeAdvancedSettingsMenuTableViewController") as! HomeAdvancedSettingsMenuTableViewController
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Advanced Settings".localized()
    }
}
