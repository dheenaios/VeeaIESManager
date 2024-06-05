//
//  PatchData.swift
//  MAS API
//
//  Created by Richard Stockdale on 01/09/2020.
//  Copyright © 2020 Richard Stockdale. All rights reserved.
//

import Foundation

class MasApiPatchDataHelper {
    
    static let tag = "MasApiPatchDataHelper"
    
    static func patch(sourceJson: JSON, targetJson: JSON, tableName: String) -> Data? {
        do {
            let source = try JSONSerialization.data(withJSONObject: sourceJson, options:.prettyPrinted)
            let target = try JSONSerialization.data(withJSONObject: targetJson, options:.prettyPrinted)
            
            return createPatch(sourceData: source, targetData: target, tableName: tableName)
        }
        catch {
            Logger.log(tag: tag, message: "Error converting request json to data")
            return nil
        }
    }
    
    static private func createPatch(sourceData: Data, targetData: Data, tableName: String) -> Data? {
        let patch = try! JSONPatch(source: sourceData, target: targetData)
        let patchData = try! patch.data()
        
        return wrap(data: patchData, in: tableName)
    }
    
    private static func wrap(data: Data, in tableName: String) -> Data? {
        guard let patchText = patchTextFromData(data: data) else {
            return nil
        }
        
        let wrapped = """
        {\"\(tableName)\":
        \(patchText)
        }
        """
        
        //print("Patch = \(wrapped)")
        
        return patchDataFromText(str: wrapped)
    }
    
    public static func patchDataFromText(str: String) -> Data? {
        return str.data(using: .utf8)
    }
    
    public static func patchTextFromData(data: Data) -> String? {
        return String(data: data, encoding: .utf8)!
    }
}
