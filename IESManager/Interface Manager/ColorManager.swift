//
//  ColorManager.swift
//  IESManager
//
//  Created by Richard Stockdale on 14/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

class ColorManager: Codable {
    
    /// White in lighjt mode
    let background1: DynamicColor
    
    /// A light grey in light mode
    let background2: DynamicColor
    let background3: DynamicColor
    let themeTintLightBackground: DynamicColor
    
    /// Black / White
    let text1: DynamicColor
    
    /// Grey for subtitle or caption text
    let text2: DynamicColor
    
    /// White / Black
    let text3: DynamicColor
    
    /// Always white
    let textWhite: DynamicColor
    
    /// Red for warnings
    let textWarningRed1: DynamicColor
    
    /// Blue for button backgrounds
    let themeTint: DynamicColor
    
    /// Orange for button backgrounds
    let buttonOrange1: DynamicColor
    
    let statusGreen: DynamicColor
    let statusGrey: DynamicColor
    let statusRed: DynamicColor
    let statusOrange: DynamicColor
    
    let switchGreen: DynamicColor
    let accountPurple: DynamicColor
    
    let loginSplashScreenBackground: DynamicColor
    
    static func newInstance() -> ColorManager {
        if let cm = newInstanceFailing() {
            return cm
        }
        
        fatalError("Could not load colors")
    }
    
    static func newInstanceFailing() -> ColorManager? {
        do {
            let data = try Bundle.main.jsonData(fromFile: "InterfaceColors",
                                                   format: "json")
            let c = try JSONDecoder().decode(ColorManager.self, from: data!)
            return c
        }
        catch {
            //print("Error: \(error)")
            return nil
        }
    }
}

class DynamicColor: Codable {
    
    lazy var light: UIColor = {
        UIColor(hexString: lightHex)!
    }()
    lazy var dark: UIColor = {
        UIColor(hexString: darkHex)!
    }()
    
    private let lightHex: String
    private let darkHex: String
    
    var colorForAppearance: UIColor {
        if UITraitCollection.current.userInterfaceStyle == .dark { return dark }
        
        return light
    }
}
