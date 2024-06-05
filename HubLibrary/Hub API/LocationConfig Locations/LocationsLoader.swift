//
//  LocationsLoader.swift
//  HubLibrary
//
//  Created by Richard Stockdale on 27/03/2019.
//  Copyright © 2019 Virtuosys. All rights reserved.
//

import Foundation

public class LocationsLoader {
    
    private static let fileName = "Locations"
    
    public static func getAllLocations() -> [Location] {
        var dataModels = [Location]()
        let data = JsonFileLoader.loadData(fileName+".json")
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [Any]
            
            for item in jsonResult {
                dataModels.append(Location(json: item as! [String : Any]))
            }
        }
        catch {
            Logger.log(tag: "LocationsLoader", message: "Couldnt find the json file")
            return dataModels
        }
        
        return dataModels
    }
}

public struct Location: Equatable {
    private let cityKey = "City"
    private let continentKey = "Continent"
    private let countryCodeKey = "CountryCode"
    
    public enum ContinentCode {
        case AMERICA
        case EUROPE
        case ASIA
        case UNKNOWN
    }
    
    public let city: String
    public let countryCode: String
    public let continent: String
    
    public var readableCity: String {
        get {
            return city.replacingOccurrences(of: "_", with: " ")
        }
    }
    
    // For quick sorting
    public let continentCode: ContinentCode

    init(json: [String : Any]) {
        city = json[cityKey] as! String
        countryCode = json[countryCodeKey] as! String
        continent = json[continentKey] as! String
        
        switch continent {
        case "Asia":
            continentCode = .ASIA
        case "Europe":
            continentCode = .EUROPE
        case "America":
            continentCode = .AMERICA
        default:
            continentCode = .UNKNOWN
        }
    }
    
    init(city: String, countryCode: String, continent: String) {
        self.city = city
        self.countryCode = countryCode
        self.continent = continent
        
        switch continent {
        case "Asia":
            continentCode = .ASIA
        case "Europe":
            continentCode = .EUROPE
        case "America":
            continentCode = .AMERICA
        default:
            continentCode = .UNKNOWN
        }
    }
}

