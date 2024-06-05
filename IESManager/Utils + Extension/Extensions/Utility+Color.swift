//
//  Utility+Color.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 12/27/18.
//  Copyright © 2018 Veea. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            var hexColor = String(hexString[start...])
            
            if hexColor.count == 6 {
                hexColor += "ff"
            }
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    /* App base color */
    class var vPurple: UIColor {
        return UIColor(named: "Veea Background")!
    }
    
    class var vLightPurple: UIColor {
        return UIColor(named: "Light Purple")!
    }
    
    class var vSlightPurple: UIColor {
        return UIColor(named: "Slight Purple")!
    }
    
    class var vBackgroundColor: UIColor {
        return UIColor(named: "Background Color")!
    }

    class var vGreen: UIColor {
        return UIColor(named: "Slight Dark Green")!
    }
    
    class var dashboardIndicatorGreen: UIColor {
        return UIColor(named: "DashboardIconGreen")!
    }
    
    class var vBlue: UIColor {
        return UIColor(named: "Sign Up Blue")!
    }
    
    class var vRed: UIColor {
        return UIColor(named: "vRed")!
    }
    
    class var twitterBlue: UIColor {
        return UIColor(named: "Twitter Blue")!
    }
    
    class var vGray: UIColor {
        return UIColor(named: "vGray")!
    }
    
    class var vLightBrown: UIColor {
        return UIColor(named: "vLighBrown")!
    }
    
    class var vOrange: UIColor {
        return UIColor(named: "vOrange")!
    }
    
    class var vConfigScreenBackground: UIColor {
        return UIColor(named: "Background Color")!
    }
    
    class var vNavBarTint: UIColor {
        return UIColor(named: "NavigationBarTint")!
    }
    
    class var vTabBarTint: UIColor {
        return UIColor(named: "TabBarTint")!
    }
    
    class var vTitleTextColor: UIColor {
        return UIColor(named: "TitleTextColor")!
    }
}
