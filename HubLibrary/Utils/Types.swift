//
//  Types.swift
//  HubLibrary
//
//  Created by Al on 02/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

typealias CompletionHandler = (JSON?, Error?) -> Void

public typealias JSON = [String : Any]

public typealias SecureUpdateJSON = [String : [String : Any]]

/// Success and an optional message
public typealias SuccessAndOptionalMessage = (Bool, String?)

// Struct containing all the information needed for a mas update
public struct MasUpdate {
    let tableName: String
    let data: Data
}

/// A Struct or Class that represents a table response from the Hub or MAS
protocol TopLevelJSONResponse {
    var originalJson: JSON { get }
}

/// Provides the info required to create a new update to either API
public protocol ApiRequestConfigProtocol {
    
    /// The name of the table the request will be made again
    ///
    /// - Returns: the table name
    static func getTableName() -> String
    
    /// JSON for the secure update request
    func getHubApiUpdateJSON() -> SecureUpdateJSON
    
    /// Has the config changed. See the default implementation and override is needed
    func hasConfigChanged() -> Bool
    
    /// JSON encoded as data for sending to the MAS Api
    func getMasUpdate() -> MasUpdate?
}

// MARK: Default implementations
extension ApiRequestConfigProtocol {
    
    /// All the keys. This should cover all requests. However, you should use only the keys you need.
    /// This will keep the size of requests down.
    /// Default implementation gets everything.
    ///
    /// - Returns: Array of keys
    static func getAllKeys() -> [String] {
        return [String]()
    }
    
    public func hasConfigChanged() -> Bool {
        var original: JSON?
        
        if let s = self as? TopLevelJSONResponse {
            original = s.originalJson
        }
        
        guard let o = original else {
            return false
        }
        
        let u = getHubApiUpdateJSON()
        if u.keys.count != 1 { return false }
        
        guard let tableName = u.keys.first else { return false }
        guard let updatedJson = u[tableName] else { return false }
        if updatedJson.isEmpty { return false }

        do {
            let diff = try JsonDiffer.diffJson(original: o, target: updatedJson)
            //print("Diff JSON: \(diff)")
            return !diff.isEmpty
        }
        catch {
            Logger.log(tag: "TopLevelJSONResponse",
                       message: "Json Differ error \(error.localizedDescription)")
        }

        return false
    }
    
    // Call this to notify any observer of a change to the config
    public func notifyOfChange() {
        NotificationCenter.default.post(name: NSNotification.Name.userDidUpdateConfig,
                                        object: self)
    }
}
