//
//  TimeZonesLoader.swift
//  IESManager
//
//  Created by Richard Stockdale on 11/08/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

struct TimeZonesLoader {

    var defaultCountryCode = "US"
    var defaultUserTimeZone = "New York"

    var jsonCountries = [String]()
    var timezones: [String : String]?

    init() {
        do {
            guard let dataCountries = try Bundle.main.jsonData(fromFile: "Countries", format: "json") else {
                return
            }

            jsonCountries = try JSONDecoder().decode([String].self, from: dataCountries)

            let countryCodeNSLocale = NSLocale.current.regionCode ?? "US"
            let timeZoneSystem = TimeZone.current.identifier

            if(jsonCountries.contains(countryCodeNSLocale)) {

                do {
                    let fileName = "Timezone_\(countryCodeNSLocale)"
                    if let dataTimeZone = try Bundle.main.jsonData(fromFile: fileName, format: "json") {
                        let jsonTimeZone = try JSONDecoder().decode([String: String].self, from: dataTimeZone)

                        self.timezones = jsonTimeZone

                        if (jsonTimeZone.keys.contains(timeZoneSystem)) {
                            defaultCountryCode = countryCodeNSLocale
                            defaultUserTimeZone = jsonTimeZone[timeZoneSystem]!
                        }
                    }
                } catch {
                    fatalError("could not get country code")
                }
            }
        }
        catch {
            fatalError("Could not read from file)")
        }
    }
}
