//
//  ViewModelUpdateType.swift
//  IESManager
//
//  Created by Richard Stockdale on 09/11/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

enum ViewModelUpdateType {
    case dataModelUpdated // Use this most of the time
    case sendingData
    case sendingDataSuccess
    case sendingDataFailed(String)
    case noChange // There is no change in the data
}
