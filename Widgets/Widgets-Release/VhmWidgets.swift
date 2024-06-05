//
//  VhmWidgets.swift
//  WidgetsExtension
//
//  Created by Richard Stockdale on 04/07/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct VhmWidgets: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        HealthWidget()
        CellularUsageWidget()
        CellularSignalWidget()
    }
}
