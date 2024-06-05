//
//  UIImage+TemplateColor.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 03/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
