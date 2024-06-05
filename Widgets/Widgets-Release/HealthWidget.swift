//
//  HealthWidget.swift
//  WidgetsExtension
//
//  Created by Richard Stockdale on 04/07/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import SwiftUI
import WidgetKit

struct HealthWidget: Widget {
    let kind: String = "HealthWidgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: SelectHubIntent.self,
                            provider: HealthProvider()) { entry in
            HealthWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Veea Hub State")
        .description("Your Veea Hub state at a quick glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct HealthWidgetWidget_Previews: PreviewProvider {
    static var previews: some View {
        HealthWidgetsEntryView(entry: HealthWidgetEntry(date: Date(),
                                                        configuration: SelectHubIntent(),
                                                        viewModel: WidgetModel.placeHolderModel(state: .ok)))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct HealthWidgetsEntryView : View {
    var entry: HealthProvider.Entry

    @Environment(\.widgetFamily) var family: WidgetFamily

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallHealthWidgetView(vm: entry.viewModel)
        case .systemMedium:
            MediumHealthWidgetView(vm: entry.viewModel)
        case .systemLarge:
            LargeHealthWidgetView(vm: entry.viewModel)
        case .systemExtraLarge:
            Text("Extra Large - Not supported")
        default:
            Text("Unknown - Not supported")
        }
    }
}

struct HealthWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: SelectHubIntent
    let viewModel: WidgetModel
}
