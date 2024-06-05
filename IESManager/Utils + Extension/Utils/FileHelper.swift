//
//  FileHelper.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 22/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation

public class FileHelper {
    public static func saveDictionary(dict: [String : Any ], named name: String) -> URL? {
                
        guard let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let filePath = docPath.appendingPathComponent(name)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
            try data.write(to: filePath, options: [])
            
            return filePath
        } catch {
            //print(error)
        }
        
        return nil
    }
}
