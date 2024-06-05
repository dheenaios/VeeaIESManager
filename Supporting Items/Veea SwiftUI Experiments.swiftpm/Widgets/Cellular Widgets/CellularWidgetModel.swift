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
    
    let type: WidgetType
    
    var cellularSignalStrengthModel: CellularSignalStrengthModel
    var cellularUsageModel: CellularUsageModel
    
    let isInError: Bool
}
