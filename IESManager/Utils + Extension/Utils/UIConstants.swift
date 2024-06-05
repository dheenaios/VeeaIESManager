//
//  UIConstants.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/2/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

public struct UIConstants {
    struct Margin {
        static let side: CGFloat = 15
        static let top: CGFloat = 20
        static let topSmall: CGFloat = 6
    }
    
    struct Spacing {
        /// Standard inter-item spacing - 10
        static let standard: CGFloat = 10
        /// Small inter-item spacing - 5
        static let small: CGFloat = 5
    }
    static let contentWidth: CGFloat = UIScreen.main.bounds.width - (UIConstants.Margin.side * 2)
}
