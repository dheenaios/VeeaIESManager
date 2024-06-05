//
//  CellularWidgets.swift
//  Widgets-QAExtension
//
//  Created by Richard Stockdale on 05/07/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit


/*

 Views for usage and signal strength widgets

 */

// MARK: - Usage Widgets
struct CellularUsageWidget: Widget {
    let kind: String = "CellularUsageWidget"

    var body: some WidgetConfiguration {

        StaticConfiguration(kind: kind,
                            provider: CellularProvider()) { entry in
            CellularUsageWidgetEntryView(entry: entry)
        }
                            .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CellularUsageWidgetEntryView : View {
    var entry: CellularProvider.Entry 

    @Environment(\.widgetFamily) var family: WidgetFamily

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallUsageView(vm: entry.viewModel)
        case .systemMedium:
            MediumUsageView(vm: entry.viewModel)
        case .systemLarge:
            Text("Large - Not supported")
        case .systemExtraLarge:
            Text("Extra Large - Not supported")
        default:
            Text("Unknown - Not supported")
        }
    }
}



// MARK: - Signal Strength Widgets

struct CellularSignalWidget: Widget {
    let kind: String = "CellularSignalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: CellularProvider()) { entry in
            CellularSignalWidgetEntryView(entry: entry)
        }
                            .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CellularSignalWidgetEntryView : View {
    var entry: CellularProvider.Entry

    @Environment(\.widgetFamily) var family: WidgetFamily

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallSignalStrengthView(vm: entry.viewModel)
        case .systemMedium:
            MediumSignalStrengthView(vm: entry.viewModel)
        case .systemLarge:
            Text("Large - Not supported")
        case .systemExtraLarge:
            Text("Extra Large - Not supported")
        default:
            Text("Unknown - Not supported")
        }
    }
}



// MARK: - Common

struct CellularWidgetEntry: TimelineEntry {
    let date: Date
    let viewModel: CellularWidgetModel
}
