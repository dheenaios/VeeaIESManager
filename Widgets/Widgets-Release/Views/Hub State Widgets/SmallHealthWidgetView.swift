import SwiftUI

// A single hub, with a title of Veea Hub
struct SmallHealthWidgetView: View {
    
    let vm: WidgetModel
    
    var body: some View {
        if vm.state == .ok {
            ZStack {
                VStack {
                    Text(vm.widgetTitle(multipleHubs: false))
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .foregroundColor(.gray)
                        .font(Font(FontManager.bodyText))
                    Spacer()
                }
                HStack(alignment: .center) {
                    VStack {
                        Spacer()
                        VerticalWidgetView(vm: vm.hubModels.first!)
                        Spacer()
                    }
                }
            }
        }
        else {
            ErrorView(isLarge: false,
                      errorMessage: vm.state.errorMessage)
        }
    }
}
