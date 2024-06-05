//
//  NameToImageParser.swift
//  IESManager
//
//  Created by Richard Stockdale on 20/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

struct NameToImageParser {
    static func deviceNameToImageName(deviceName: String) -> String {
        let strippedOfNumbers = deviceName.components(separatedBy: CharacterSet.decimalDigits).joined()
        let strippedOfDash = strippedOfNumbers.components(separatedBy: "-").joined()

        let t = strippedOfDash.lowercased().replacingOccurrences(of: "_", with: " ")
        for (index, nTitle) in titles.enumerated() {
            let n = nTitle.lowercased().replacingOccurrences(of: "_", with: " ")

            if t == n {
                return images[index]
            }
        }

        return images.last!
    }

    private static var titles: [String] {
        return ["Living Room",
                "Hallway",
                "Kitchen",
                "Bedroom",
                "Master Bedroom",
                "Study",
                "Custom"]
    }

    static var images: [String] {
        ["location_sofa",
         "location_sofa",
         "location_kitchen",
         "location_bed",
         "location_bed",
         "location_study",
         "location_custom"]
    }
}
