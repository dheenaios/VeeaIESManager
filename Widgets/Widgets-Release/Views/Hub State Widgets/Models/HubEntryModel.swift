import Swift
import SwiftUI


enum WidgetState: Equatable {
    case ok
    case loadingError(String)

    var errorMessage: String {
        switch self {
        case .loadingError(let string):
            return string
        case .ok:
            return ""
        }
    }
}

struct WidgetModel {
    func widgetTitle(multipleHubs: Bool = true) -> String {
        return multipleHubs ? "VEEA HUBS" : "VEEA HUB"
    }
    let hubModels: [HubEntryModel]
    let state: WidgetState

    static func placeHolderModel(state: WidgetState) -> WidgetModel {
        let placeHolderModel = HubEntryModel(iconName: "location_bed",
                                             locationDescription: "Bedroom",
                                             iconColor: .blue,
                                             healthColor: .green,
                                             healthStateText: "Online")

        let model = WidgetModel(hubModels: [placeHolderModel,
                                            placeHolderModel,
                                            placeHolderModel,
                                            placeHolderModel],
                                state: state)

        return model
    }
}

struct HubEntryModel {
    let iconName: String
    let locationDescription: String
    let iconColor: Color
    let healthColor: Color
    let healthStateText: String
}

