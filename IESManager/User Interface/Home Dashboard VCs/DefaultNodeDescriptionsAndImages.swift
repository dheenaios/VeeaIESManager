//
//  DefaultNodeDescriptionsAndImages.swift
//  IESManager
//
//  Created by Richard Stockdale on 10/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import UIKit

struct DefaultNodeDescriptionsAndImages {
    
    // Try to work out what the appropriate image for the title will be
    static func imageForTitle(_ title: String) -> UIImage {
        
        // Strip off some crap to get to the description
        let strippedOfNumbers = title.components(separatedBy: CharacterSet.decimalDigits).joined()
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
    
    static var titles: [String] {
        return ["Living Room".localized(),
                "Hallway".localized(),
                "Kitchen".localized(),
                "Bedroom".localized(),
                "Master Bedroom".localized(),
                "Study".localized(),
                "Custom".localized()]
    }
    
    static var images: [UIImage] {
        let imageNames = ["location_sofa",
                          "location_sofa",
                          "location_kitchen",
                          "location_bed",
                          "location_bed",
                          "location_study",
                          "location_custom"]
        
        var images = [UIImage]()
        for imageName in imageNames {
            let i = UIImage(named: imageName)!
            images.append(i)
        }
        
        return images
    }
}
