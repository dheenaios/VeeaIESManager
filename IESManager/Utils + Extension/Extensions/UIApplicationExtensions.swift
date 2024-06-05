//
//  UIApplicationExtensions.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 03/04/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    public static func getTopMostViewController(base: UIViewController? = UIWindow.sceneWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
    
    public static func getTopMostTabBarController(base: UIViewController? = UIWindow.sceneWindow?.rootViewController) -> UITabBarController? {
        if let tab = base as? UITabBarController {
            return tab
        }
        
        if let nav = base as? UINavigationController {
            return getTopMostTabBarController(base: nav.visibleViewController)
        }
        
        if let presented = base?.presentedViewController {
            return getTopMostTabBarController(base: presented)
        }
        
        return nil
    }
}
