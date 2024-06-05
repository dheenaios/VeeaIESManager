//
//  ConfigurationSnapShot.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 18/10/2019.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation


public struct ConfigurationSnapShot {
        
    private let kRootKey = "ConfigurationSnapShot"
    private let kCreationDateKey = "CreationDate"
    private let kBaseModelJsonKey = "BaseModelJson"
    private let kOptionalModelJsonKey = "OptionalModelJson"
    private let kSnapshotDescription = "SnapshotDescription"
    
    private let creationDate: String
    private let baseModelJson: [String : Any]
    private var optionalModelJson: [String : Any]?
    
    /// Name given to the snapshot
    public var snapShotDescription: String?

    /// Get a json representation of the snapshot
    public func snapShotJsonDictionary() -> [String : Any] {
        var snapShotJson = [String : Any]()
        var inner = [String : Any]()

        
        inner[kSnapshotDescription] = snapShotDescription ?? "No description"
        inner[kCreationDateKey] = creationDate
        inner[kBaseModelJsonKey] = baseModelJson
        inner[kOptionalModelJsonKey] = optionalModelJson
        
        snapShotJson[kRootKey] = inner
        
        return snapShotJson
    }
    
    public func snapshotJsonString() -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: snapShotJsonDictionary(), options: [.prettyPrinted])
            guard let convertedString = String(data: data, encoding: String.Encoding.utf8) else {
                return snapShotJsonDictionary().description
                
            }
            
            return convertedString
        }
        catch {
            return snapShotJsonDictionary().description
        }
    }
    
    // MARK: - Init methods
    
    /// Create a snapshop from the Model JSON
    /// - Parameter baseModel: The base model json
    /// - Parameter optionalModel: The optional db json file
    init(baseModel: [String : Any], optionalModel: [String : Any]?) {
        let df = DateFormatter.iso8601Full
        
        creationDate = df.string(from: Date())
        baseModelJson = baseModel
        
        if let om = optionalModel {
            optionalModelJson = om
        }
    }
    
    /// Create a snapshop from a previous snapshot
    /// - Parameter snapShotJson: The previous snapshots json
    init(snapShotJson: [String : Any]) {
        let inner = snapShotJson[kRootKey] as! [String : Any]
        
        snapShotDescription = inner[kSnapshotDescription] as? String
        creationDate = inner[kCreationDateKey] as! String
        
        baseModelJson = inner[kBaseModelJsonKey] as! [String : Any]
        
        if let val = inner[kOptionalModelJsonKey] {
            optionalModelJson = val as? [String : Any]
        }
    }
}

// MARK: - Getters
extension ConfigurationSnapShot {
    public func getBaseDataModel() -> HubBaseDataModel? {
        let model = HubBaseDataModel.newFromDict(dict: baseModelJson)
        return model
    }
    
    public func getOptionalDataModel() -> OptionalAppsDataModel? {
        guard let optionalModelJson = optionalModelJson else {
            return nil
        }
        
        let model = OptionalAppsDataModel.newFromDict(dict: optionalModelJson)
        return model
    }
}
