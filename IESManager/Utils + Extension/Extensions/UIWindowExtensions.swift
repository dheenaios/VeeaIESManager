//
//  UIWindowExtensions.swift
//  IESManager
//
//  Created by Richard Stockdale on 03/05/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    public static var sceneWindow: UIWindow? {
        let window = UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }

        return window
    }
}
