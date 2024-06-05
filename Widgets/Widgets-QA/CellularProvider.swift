//
//  CellularProvider.swift
//  Widgets-QAExtension
//
//  Created by Richard Stockdale on 09/07/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import SharedBackendNetworking
import AVFoundation

struct CellularProvider: TimelineProvider {

    typealias Entry = CellularWidgetEntry

    func placeholder(in context: Context) -> CellularWidgetEntry {

        return CellularWidgetEntry(date: Date(),
                                   viewModel: CellularWidgetModel.placeHolderModel(state: .ok))
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (CellularWidgetEntry) -> ()) {
        let entry =  CellularWidgetEntry(date: Date(),
                                         viewModel: CellularWidgetModel.placeHolderModel(state: .ok))
        completion(entry)
    }

    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)

        if !UserSessionManager.shared.isUserLoggedIn {
            let entry = CellularWidgetEntry(date: Date(),
                                            viewModel: CellularWidgetModel.placeHolderModel(state: .loadingError("Log in to your account".localized())))

            let timeline = Timeline(entries: [entry], policy: .after(refreshDate!))
            completion(timeline)
            return
        }

        let fetcher = CellularDataFetcher()
        fetcher.getCellularDetails {
            let entry = self.getWidgetForResult(fetcher: fetcher)
            completion(entry)
        }

    }

    private func getNotConfigurableTimelineEntry() -> Timeline<Entry> {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)

        if !BackEndEnvironment.isHome {
            let entry = CellularWidgetEntry(date: Date(),
                                            viewModel: CellularWidgetModel.placeHolderModel(state: .loadingError("Widgets only supported for home users".localized())))

            let timeline = Timeline(entries: [entry], policy: .after(refreshDate!))

            return timeline
        }

        let entry = CellularWidgetEntry(date: Date(),
                                        viewModel: CellularWidgetModel.placeHolderModel(state: .loadingError("Please configure".localized())))

        let timeline = Timeline(entries: [entry], policy: .after(refreshDate!))

        return timeline
    }

    private func getWidgetForResult(fetcher: CellularDataFetcher) -> Timeline<Entry> {
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)

            switch fetcher.cellularState {
            case .allGood:
                return validWidget(fetcher: fetcher)
            case .noSubscription:
                let entry = CellularWidgetEntry(date: Date(),
                                                viewModel: CellularWidgetModel.placeHolderModel(state: .loadingError("No Cellular Subscription".localized())))
                return Timeline(entries: [entry], policy: .after(refreshDate!))
            case .somethingWentWrong(let reason):
                let entry = CellularWidgetEntry(date: Date(),
                                                viewModel: CellularWidgetModel.placeHolderModel(state: .loadingError("Error: \(reason)".localized())))
                return Timeline(entries: [entry], policy: .after(refreshDate!))
            default:
                let entry = CellularWidgetEntry(date: Date(),
                                                viewModel: CellularWidgetModel.placeHolderModel(state: .loadingError("Unknown Error".localized())))
                return Timeline(entries: [entry], policy: .after(refreshDate!))
            }
        }

    private func validWidget(fetcher: CellularDataFetcher) -> Timeline<Entry> {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)

        let signalStengthModel = CellularSignalStrengthModel(networkType: fetcher.networkMode,
                                                             carrierName: fetcher.carrierName,
                                                             signalStrengthBars: fetcher.signalStrength)

        let usageModel = CellularUsageModel(todayUp: fetcher.todayUp,
                                            todayDown: fetcher.todayDown,
                                            yesterdayUp: fetcher.yesterdayUp,
                                            yesterdayDown: fetcher.yesterdayDown,
                                            thisMonthUp: fetcher.thisMonthUp,
                                            thisMonthDown: fetcher.thisMonthDown,
                                            lastMonthUp: fetcher.lastMonthUp,
                                            lastMonthDown: fetcher.lastMonthDown)

        let model = CellularWidgetModel(state: .ok,
                                        cellularSignalStrengthModel: signalStengthModel,
                                        cellularUsageModel: usageModel)

        let entry = CellularWidgetEntry(date: Date(),
                                        viewModel: model)

        return Timeline(entries: [entry], policy: .after(refreshDate!))
    }
}
