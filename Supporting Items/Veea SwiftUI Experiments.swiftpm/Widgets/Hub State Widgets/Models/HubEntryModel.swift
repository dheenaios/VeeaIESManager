import Swift
import SwiftUI

struct WidgetModel {
    var widgetTitle: String {
        if hubModels.count < 2 {
            return "VEEA HUB"
        }
        
        return "VEEA HUBS"
    }
    let hubModels: [HubEntryModel]
    let isInError: Bool
}

struct HubEntryModel {
    let iconName: String
    let locationDescription: String
    let iconColor: Color
    let healthColor: Color
    let healthStateText: String
}

