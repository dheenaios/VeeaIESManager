//
//  Log.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 09/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


/// Log to the VHMs debug records
class Log {
    static func tag(tag: String, message: String) {
        Logger.log(tag: tag, message: message)
    }
}
