//
//  NamingViewViewModel.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 4/5/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation


final class NamingViewViewModel {
    
    var model: NamingViewModel!
    var namingType: NamingViewType!
    var groupId : String!
    
    init(type: NamingViewType, groupId : String) {
        self.namingType = type
        self.groupId = groupId
        self.loadDataForCurrentType()
    }
    
    /// Returns true if first character is a char
    func checkIfFirstCharIsAlpha(textFieldText: String?, string: String) -> Bool {
        
        if textFieldText?.isEmpty ?? true {
            if (string >= "a" && string <= "z") || (string >= "A" && string <= "Z") {
                return true
            }
            return false
        }
        
        return true
    }
    
    func loadDataForCurrentType() {
        if let filepath = Bundle.main.path(forResource: "AddDeviceData", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                if let data = contents.data(using: .utf8) {
                    let json = try JSONDecoder().decode([String: NamingViewModel].self, from: data)
                    self.model = json[self.namingType.rawValue]
                }
            } catch {
                fatalError("Could not read from filepath: \(filepath)")
            }
        }
    }

    func nameGenerator(serial: String?) -> String {
        var serialLast4 = Int(arc4random_uniform(999)).description
        if let serial = serial {
            serialLast4 = serial.split(from: serial.count - 19, to: serial.count - 16)
        }

        if namingType == .device {
            return "VH-\(serialLast4)"
        } else {
            return "VMESH-\(serialLast4)"
        }
    }
    
    static func nameGeneratorForDefaultWifiCredentials(serial: String?) -> String {
        var serialLast4 = Int(arc4random_uniform(999)).description
        if let serial = serial {
            serialLast4 = serial.split(from: serial.count - 19, to: serial.count - 16)
        }

        return "VMESH-\(serialLast4)-wifi"
    }
}
