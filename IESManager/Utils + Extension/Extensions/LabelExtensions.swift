//
//  LabelExtensions.swift
//  IESManager
//
//  Created by Richard Stockdale on 07/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func setExistingTextWithLineSpacing() {
        guard let text = text else { return }
        setTextWithDefaultSpacing(text: text)
    }
    
    func setTextWithDefaultSpacing(text: String) {
        setTextWithSpacing(text: text, spacing: 1.5)
    }
    
    func setTextWithSpacing(text: String, spacing: CGFloat) {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = spacing

        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        // *** Set Attributed String to your label ***
        attributedText = attributedString
    }
    
}
