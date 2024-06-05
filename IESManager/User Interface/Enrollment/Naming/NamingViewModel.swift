//
//  NamingViewModel.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/16/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import Foundation


public enum NamingViewType: String {
    case device
    case mesh
}

struct NamingViewModel: Decodable {
    let vcTitle: String!
    let icon: String!
    let title: String!
    let details: String!
}
