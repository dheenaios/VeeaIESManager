//
//  UITabBarExtensions.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 11/10/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)

        guard let window = UIWindow.sceneWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = window.safeAreaInsets.bottom + 40
        return sizeThatFits
    }
}
