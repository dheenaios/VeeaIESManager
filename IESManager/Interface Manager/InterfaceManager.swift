//
//  InterfaceManager.swift
//  IESManager
//
//  Created by Richard Stockdale on 14/02/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

class InterfaceManager {
    
    static var shared = InterfaceManager()

    /// Returns and instance of the color manager
    lazy var cm: ColorManager = { ColorManager.newInstance() }()
    
    // Font manager is just using static methods at the moment
    
}
