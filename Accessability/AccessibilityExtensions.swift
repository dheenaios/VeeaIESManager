//
//  AccessibilityExtensions.swift
//  IESManager
//
//  Created by Richard Stockdale on 29/11/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit

public extension UIView {
    func accessibility(config: AccessibilityConfig) {
        self.accessibilityLabel = config.label
        self.accessibilityIdentifier = config.identifier
    }
}

public extension UIAlertAction {
    func accessibility(config: AccessibilityConfig) {
        self.accessibilityLabel = config.label
        self.accessibilityIdentifier = config.identifier
    }
}

public extension UIBarItem {
    func accessibility(config: AccessibilityConfig) {
        self.accessibilityLabel = config.label
        self.accessibilityIdentifier = config.identifier
    }
}
