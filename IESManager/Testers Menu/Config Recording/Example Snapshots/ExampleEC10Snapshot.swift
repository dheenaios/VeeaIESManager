//
//  ExampleEC10Snapshot.swift
//  IESManager
//
//  Created by Richard Stockdale on 07/12/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

struct ExampleSnapshots {
    static var ec10Snapshot: String? {
        if let filepath = Bundle.main.path(forResource: "ExampleEC10Snapshot", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
