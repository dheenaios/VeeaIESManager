//
//  JsonFileLoader.swift
//  VeeaHub Manager
//
//  Created by richardstockdale on 12/02/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

struct JsonFileLoader {

    private static var frameworkBundle: Bundle? {
        for framework in Bundle.allFrameworks {
            if let id = framework.bundleIdentifier {
                if id.contains("veea.SharedBackendNetworking") {
                    return framework
                }
            }
        }

        return nil
    }

    static func loadData(_ filename: String) -> Data {
        let data: Data
        
        guard let file = frameworkBundle?.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
            return data
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
    }
    
    // For Codeable Objects
    static func load<T: Decodable>(_ filename: String) -> T {
        let data: Data
        
        guard let file = frameworkBundle?.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}
