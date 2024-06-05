import SwiftUI

// Shows a single
struct CellularWidgetModel {
    enum WidgetType {
        case signalStrengthSmall
        case signalStrengthMedium
        case usageSmall
        case usageMedium
        
        var title: String {
            switch self {
            case .signalStrengthSmall:
                return "CELLULAR STATS"
            case .signalStrengthMedium:
                return "CELLULAR STATS"
            case .usageSmall:
                return "DATA USAGE 24h"
            case .usageMedium:
                return "DATA USAGE"
            }
        }
    }
    
    func widgetTitle(type: WidgetType) -> String {
        type.title
    }

    let state: WidgetState
    
    var cellularSignalStrengthModel: CellularSignalStrengthModel
    var cellularUsageModel: CellularUsageModel
}

extension CellularWidgetModel {

    static func placeHolderModel(state: WidgetState) -> CellularWidgetModel {
        let model = CellularWidgetModel(state: state,
                                        cellularSignalStrengthModel: placeHolderSignalModelModel(),
                                        cellularUsageModel: placeHolderUsageModelModel())

        return model
    }

    private static func placeHolderUsageModelModel() -> CellularUsageModel {
        let placeHolderModel = CellularUsageModel(todayUp: "20 GB",
                                                  todayDown: "20 GB",
                                                  yesterdayUp: "20 GB",
                                                  yesterdayDown: "20 GB",
                                                  thisMonthUp: "20 GB",
                                                  thisMonthDown: "20 GB",
                                                  lastMonthUp: "20 GB",
                                                  lastMonthDown: "20 GB")

        return placeHolderModel
    }

    private static func placeHolderSignalModelModel() -> CellularSignalStrengthModel {
        let placeHolderModel = CellularSignalStrengthModel(networkType: "5G",
                                                           carrierName: "VeeaNet",
                                                           signalStrengthBars: 4)

        return placeHolderModel
    }
}
