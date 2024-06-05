//
//  Widgets_QA.swift
//  Widgets-QA
//
//  Created by Richard Stockdale on 18/06/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import SharedBackendNetworking

struct HealthProvider: IntentTimelineProvider {

    typealias Entry = HealthWidgetEntry

    let nodeHealthFetcher = NodeHealthFetcher()

    func placeholder(in context: Context) -> HealthWidgetEntry {
        return HealthWidgetEntry(date: Date(),
                                 configuration: SelectHubIntent(),
                                 viewModel: WidgetModel.placeHolderModel(state: .ok))
    }

    func getSnapshot(for configuration: SelectHubIntent, in context: Context, completion: @escaping (HealthWidgetEntry) -> ()) {
        let entry =  HealthWidgetEntry(date: Date(),
                                       configuration: SelectHubIntent(),
                                       viewModel: WidgetModel.placeHolderModel(state: .ok))
        completion(entry)
    }

    func getTimeline(for configuration: SelectHubIntent,
                     in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)

        if !UserSessionManager.shared.isUserLoggedIn {
            let entry = HealthWidgetEntry(date: Date(), configuration: SelectHubIntent(),
                                          viewModel: WidgetModel.placeHolderModel(state: .loadingError("Log in to your account".localized())))
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate!))
            completion(timeline)
            return
        }

        guard let param = configuration.parameter else {
            completion(getNotConfigurableTimelineEntry())
            return
        }

        let widgetHubIds = param.map { $0.identifier! }

        // Check these are still valid hub ids. We may have moved to a different account
        if !DeviceOptionsManager.allHubIdsStillValid(widgetHubIds: widgetHubIds) {
            completion(getNotConfigurableTimelineEntry())
            return
        }

        getLatestDetails(widgetHubIds: widgetHubIds) { models, errorMessage  in
            if let errorMessage = errorMessage {
                let entry = HealthWidgetEntry(date: Date(), configuration: SelectHubIntent(),
                                              viewModel: WidgetModel.placeHolderModel(state: .loadingError(errorMessage)))
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate!))

                completion(timeline)
                return
            }

            if models.isEmpty {
                let entry = HealthWidgetEntry(date: Date(), configuration: SelectHubIntent(),
                                              viewModel: WidgetModel.placeHolderModel(state: .loadingError("No models returned")))
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate!))

                completion(timeline)
                return
            }

            var hubModels = [HubEntryModel]()
            for model in models {
                hubModels.append(HubEntryModel(iconName: NameToImageParser.deviceNameToImageName(deviceName: model.deviceName),
                                               locationDescription: model.deviceName,
                                               iconColor: .blue,
                                               healthColor: model.state.color,
                                               healthStateText: model.state.stateTitle))
            }

            let entry = HealthWidgetEntry(date: Date(),
                                          configuration: SelectHubIntent(),
                                          viewModel: WidgetModel(hubModels: hubModels, state: .ok))

            let timeline = Timeline(entries: [entry], policy: .after(refreshDate!))

            completion(timeline)
        }
    }

    private func getNotConfigurableTimelineEntry() -> Timeline<Entry> {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)

        if !BackEndEnvironment.isHome {
            let entry = HealthWidgetEntry(date: Date(), configuration: SelectHubIntent(),
                                          viewModel: WidgetModel.placeHolderModel(state: .loadingError("Widgets only supported for home users".localized())))
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate!))

            return timeline
        }

        let entry = HealthWidgetEntry(date: Date(), configuration: SelectHubIntent(),
                                      viewModel: WidgetModel.placeHolderModel(state: .loadingError("Please configure".localized())))
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate!))

        return timeline
    }

    func getLatestDetails(widgetHubIds: [String], completion: @escaping([DeviceHealthSummary], String?) -> Void) {
        nodeHealthFetcher.fetchNodeHealthStates(widgetHubIds: widgetHubIds) { healthSummaries, errorString  in
            completion(healthSummaries, errorString)
        }
    }
}
