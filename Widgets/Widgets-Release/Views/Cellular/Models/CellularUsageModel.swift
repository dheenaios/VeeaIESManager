import SwiftUI

struct CellularUsageModel {
    let todayUp: String
    let todayDown: String
    
    let yesterdayUp: String
    let yesterdayDown: String
    
    let thisMonthUp: String
    let thisMonthDown: String
    
    let lastMonthUp: String
    let lastMonthDown: String

    func valueAndMetric(_ valueMetricString: String) -> (String, String) {
        let components = valueMetricString.split(separator: " ")
        if let first = components.first, let last = components.last {
            return (String(first), String(last))
        }

        return (valueMetricString, "")
    }
}
