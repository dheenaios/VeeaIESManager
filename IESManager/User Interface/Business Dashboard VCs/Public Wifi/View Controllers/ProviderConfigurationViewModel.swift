//
//  ProviderConfigurationViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit

class ProviderConfigurationViewModel: BaseConfigViewModel {
    
    let kSocify = "socifi";
    let kPurple = "purple";
    let kHotspot = "hotspot";
    let kGlobalreach = "globalreach";
    
    let veeaFiImage = UIImage(named: "public_wifi_provider_veeaFi")
    
    func logoImageForProvider(providerName: String?) -> UIImage {
        guard let providerName = providerName else {
            return UIImage(named: "public_wifi_grey")!
        }
        
        guard let img = UIImage(named: "public_wifi_provider_\(providerName.lowercased())") else {
            return UIImage(named: "public_wifi_grey")!
        }
        
        return img
    }
}
