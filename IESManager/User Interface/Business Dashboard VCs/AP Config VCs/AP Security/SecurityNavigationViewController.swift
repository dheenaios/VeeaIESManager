//
//  SecurityNavigationViewController.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 01/12/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import UIKit

class SecurityNavigationViewController: UINavigationController {
    var coordinator: SecurityConfigCoordinator? {
        didSet {
            setRootViewController()
        }
    }
    
    private func setRootViewController() {
        switch coordinator?.secureMode {
        case .preSharedPsk:
            let vc = storyboard?.instantiateViewController(withIdentifier: "SecuritySharedPskTableViewController")
            setViewControllers([vc!], animated: false)
            break
        case .enterprise:
            let vc = storyboard?.instantiateViewController(withIdentifier: "SecurityEnterpriseTableViewController")
            setViewControllers([vc!], animated: false)
            break
        default:
            break
            //print("Ooops. Unsupported type. You should not see this")
        }
    }
}
