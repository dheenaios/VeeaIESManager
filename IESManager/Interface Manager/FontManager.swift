//
//  FontManager.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

class FontManager {
    /// Text for a big, screen spanning button
    static var bigButtonText: UIFont {
        UIFont(name: "Ubuntu-Medium", size: 18)!
    }
    
    static var bodyText: UIFont {
        UIFont(name: "Ubuntu", size: 17)!
    }
    
    static var infoText: UIFont {
        UIFont(name: "Ubuntu", size: 15)!
    }
    
    static var infoTextBold: UIFont {
        UIFont(name: "Ubuntu-Bold", size: 14)!
    }
    
    static var ssidPasswordText: UIFont {
        UIFont(name: "Ubuntu", size: 26)!
    }
    
    // MARK: - Fonts
    static func bold(size: CGFloat) -> UIFont {
        UIFont(name: "Ubuntu-Bold", size: size)!
    }
    
    static func medium(size: CGFloat) -> UIFont {
        UIFont(name: "Ubuntu-Medium", size: size)!
    }
    
    static func light(size: CGFloat) -> UIFont {
        UIFont(name: "Ubuntu-Light", size: size)!
    }
    
    static func regular(size: CGFloat) -> UIFont {
        UIFont(name: "Ubuntu", size: size)!
    }
}
