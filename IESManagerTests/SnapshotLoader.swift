//
//  SnapshotLoader.swift
//  VeeaHub ManagerTests
//
//  Created by Richard Stockdale on 03/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import Foundation

/*
 
 NEVER CHANGE THE INDIVIDUAL SNAPSHOTS ARE THEY ARE USED TO RUN TESTS.
 CHANGING THE SNAPSHOT TEXT MAY CHANGE TEXT OUTPUT
 CHANGE THE HUBDATAMODEL VALIABLES AFTER LOADING
 
 */

class SnapshotLoader {
    
    lazy var fileNames: [String] = {
        guard let bundle = getSnapshotBundle() else {
            return [String]()
        }
        
        var fileNames = [String]()
        let paths = bundle.paths(forResourcesOfType: ".json", inDirectory: nil)
        for path in paths {
            let componenets = path.split(separator: "/")
            
            if let last = componenets.last {
                fileNames.append(String(last))
            }
        }
        
        return fileNames
    }()
    
    public func getSnapshots() -> [[String : Any]]? {
        guard let bundle = getSnapshotBundle() else {
            return nil
        }
        
        let paths = bundle.paths(forResourcesOfType: ".json", inDirectory: nil)
        
        // Load each string
        var snapshots = [[String : Any]]()
        for path in paths {
            if let fileContents = try? String(contentsOfFile: path),
               let data = fileContents.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data, options : .allowFragments) as! [ String : Any] {
                snapshots.append(json)
            }
        }

        return snapshots
    }
    
    private func getSnapshotBundle() -> Bundle? {
        guard let url = Bundle(for: Self.self)
                .url(forResource: "Snapshots", withExtension: "bundle") else { return nil }
        let b = Bundle(url: url)
        
        return b
    }
}
