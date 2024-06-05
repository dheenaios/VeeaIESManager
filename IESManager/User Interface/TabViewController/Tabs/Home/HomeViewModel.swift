//
//  HomeViewModel.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/7/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

enum VeeaTableCellStyle: String, Decodable {
    case icon // Cell with image view, left aligned text label and label on bottom with gray text
    case text // Simple cell with Left aligned label on left
}

struct VHHomeViewModel: Decodable {
    
    var sectionTitle: String?
    var rows: [VUITableCellModel]!

}

protocol VUITableCellModelProtocol {
    
}

struct VUITableCellModel: VUITableCellModelProtocol, Decodable {
    var type: VeeaTableCellStyle = .text
    var title: String!
    var subtitle: String?
    var icon: String?
    var link: String?
    var isActionEnabled = true
    var roundedIcon : Bool = true

}
