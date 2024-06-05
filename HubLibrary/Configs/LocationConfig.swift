//
//  LocationConfig.swift
//  HubLibrary
//
//  Created by Al on 03/03/2017.
//  Copyright © 2017 Virtuosys. All rights reserved.
//

import Foundation

/**
 Configuration items relating to the IES's location (locale).
 */
public struct LocationConfig: TopLevelJSONResponse, Equatable, Codable {
    
    var originalJson: JSON = JSON()
    
    var node_country: String
    var node_timezone_area: String
    var node_timezone_region: String
    
    /// The configured location from the Hub
    var configuredLocation: Location {
        get {
            Location(city: node_timezone_region,
                     countryCode: node_country,
                     continent: node_timezone_region)
        }
        set {
            node_timezone_region = newValue.city
            node_timezone_area = newValue.countryCode
            node_timezone_region = newValue.continent
        }
    }
    
    /// Location options
    public var locations = LocationsLoader.getAllLocations()
    
    public static func == (lhs: LocationConfig, rhs: LocationConfig) -> Bool {
        return lhs.configuredLocation == rhs.configuredLocation
    }
    
    private enum CodingKeys: String, CodingKey {
        case node_country, node_timezone_area, node_timezone_region
    }
}

extension LocationConfig: ApiRequestConfigProtocol {
    public func getHubApiUpdateJSON() -> SecureUpdateJSON {
        var json = SecureUpdateJSON()
        json[LocationConfig.getTableName()] = getUpdateJson()
        
        return json
    }
    
    private func getUpdateJson() -> JSON {
        var json = originalJson
        json[DbNodeConfig.NodeCountry] = configuredLocation.countryCode
        json[DbNodeConfig.NodeTimezoneArea] = configuredLocation.continent
        json[DbNodeConfig.NodeTimezoneRegion] = configuredLocation.city
        
        return json
    }
    
    public func getMasUpdate() -> MasUpdate? {
        
        let ojson = originalJson
        let njson = getUpdateJson()
        let tableName = LocationConfig.getTableName()
        
        guard let patch = MasApiPatchDataHelper.patch(sourceJson: ojson,
                                                      targetJson: njson,
                                                      tableName: tableName) else {
            return nil
        }
        
        return MasUpdate(tableName: tableName, data: patch)
    }
    
    public static func getTableName() -> String {
        return DbNodeConfig.TableName
    }
    
    public static func getAllKeys() -> [String] {
        var keys = [String]()
        
        keys.append(DbNodeConfig.NodeCountry)
        keys.append(DbNodeConfig.NodeTimezoneArea)
        keys.append(DbNodeConfig.NodeTimezoneRegion)
        
        return keys
    }
}
