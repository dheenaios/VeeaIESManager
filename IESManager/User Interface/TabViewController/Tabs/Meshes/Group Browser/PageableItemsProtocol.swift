//
//  PageableItemsProtocol.swift
//  IESManager
//
//  Created by Richard Stockdale on 15/06/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation

// TODO: Probably can be located in a more sencible location
protocol PageableItemsProtocol {
    // The number of items from the bottom of the current data set
    // when displayed should trigger a loading of the next page
    func threshold() -> Int

    // Send the identifiable item each time an item is displayed.
    func isLoadThresholdItem(identifiableItem: any Identifiable)
}

extension PageableItemsProtocol {
    func threshold() -> Int { return 10 }

    func isThresholdItem(itemIndex: Int?, modelsCount: Int) -> Bool {
        guard let itemIndex else { return false }
        let threshholdIndex = modelsCount - threshold()

        return itemIndex == threshholdIndex
    }
}
