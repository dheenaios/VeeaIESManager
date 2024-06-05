//
//  UIItems+Labels.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/3/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

// MARK: - Function label styling

func fontStyle(ofSize size: CGFloat, weight: UIFont.Weight) -> (UILabel) -> Void {
    return {
        $0.font = .systemFont(ofSize: size, weight: weight)
    }
}

func textColorStyle(_ color: UIColor) -> (UILabel) -> Void {
    return {
        $0.textColor = color
    }
}

let centerStyle: (UILabel) -> Void = {
    $0.textAlignment = .center
}

let sizeToFitStyle: (UILabel) -> Void = {
    $0.numberOfLines = 0
    $0.sizeToFit()
}

let sizeToFitOneLineStyle: (UILabel) -> Void = {
    $0.numberOfLines = 1
    $0.sizeToFit()
}

fileprivate let darkGrayLabel: (UILabel) -> Void =
textColorStyle(.darkGray)
<> sizeToFitStyle

let smallDarkGrayLabelStyle: (UILabel) -> Void =
fontStyle(ofSize: UIFont.smallSystemFontSize, weight: UIFont.Weight.regular)
<> darkGrayLabel

let darkGrayLabelStyle: (UILabel) -> Void =
fontStyle(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.regular)
<> darkGrayLabel

let darkGrayBoldLabel: (UILabel) -> Void =
fontStyle(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.bold)
<> darkGrayLabel

let mediumLabelStyle: (UILabel) -> Void =
fontStyle(ofSize: UIFont.labelFontSize, weight: UIFont.Weight.medium)
<> sizeToFitStyle

let multilineLabelStyle: (UILabel) -> Void = fontStyle(ofSize: 15, weight: UIFont.Weight.regular)
<> sizeToFitStyle

let multilineCenterLabelStyle: (UILabel) -> Void = multilineLabelStyle
<> centerStyle

let mediumRedLabelStyle: (UILabel) -> Void = mediumLabelStyle
<> textColorStyle(.vRed)

let titleBaseStyle: (UILabel) -> Void = textColorStyle(.vTitleTextColor)
<> sizeToFitStyle

let smallTitleStyle: (UILabel) -> Void = fontStyle(ofSize: 17, weight: .bold)
<> titleBaseStyle

fileprivate let titleStyle: (UILabel) -> Void = fontStyle(ofSize: 20, weight: UIFont.Weight.bold)
<> titleBaseStyle

fileprivate let largeTitleStyle: (UILabel) -> Void = fontStyle(ofSize: 25, weight: UIFont.Weight.bold)
<> titleBaseStyle


// MARK: - Custom Labels

class VUILargeTitle: UILabel {
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        self.text = title
        largeTitleStyle(self)
        
    }
}

class VUITitle: UILabel {
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        self.text = title
        titleStyle(self)
        
    }
}
