//
//  UIItems+TextField.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/11/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

private let baseStyle: (UITextField) -> Void = {
    $0.backgroundColor = .white
    $0.tintColor = .gray
    $0.attributedPlaceholder = NSAttributedString(string: " ",
                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
}


let baseTextFieldStyle: (UITextField) -> Void = baseStyle <> {
    $0.frame.size.height = 45
} <> roundedStyle <> dropShadow(radius: 0.8, offsetWidth: 1, offsetHeight: 1, opacity: 0.3)

let emailTextFieldStyle: (UITextField) -> Void = baseTextFieldStyle <> {
    $0.placeholder = "e-mail".localized()
    $0.keyboardType = .emailAddress
    $0.autocapitalizationType = .none
    $0.returnKeyType = .next
    $0.textContentType = .username
}

let passwordTextFieldStyle: (UITextField) -> Void = baseTextFieldStyle <> {
    $0.placeholder = "password".localized()
    $0.isSecureTextEntry = true
    $0.autocapitalizationType = .none
    $0.returnKeyType = .done
    $0.textContentType = .password
}

let transparentFieldStyle: (UITextField) -> Void = baseStyle <> {
    $0.returnKeyType = .done
    $0.textAlignment = .right
    $0.textColor = .darkGray
}
