//
//  WifiStatsViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 13/07/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class WifiStatsViewModel: BaseConfigViewModel {

    func refresh(completion: @escaping(WifiStats?, APIError?) -> Void) {
        ApiFactory.api.getWifiStats(connection: connectedHub!) { (wifiStats, error) in
            completion(wifiStats, error)
        }
    }
}
