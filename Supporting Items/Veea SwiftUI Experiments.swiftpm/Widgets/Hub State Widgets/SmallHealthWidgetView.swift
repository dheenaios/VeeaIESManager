import SwiftUI

// A single hub, with a title of Veea Hub
struct SmallHealthWidgetView: View {
    
    let vm: WidgetModel
    
    var body: some View {
        if !vm.isInError {
            ZStack {
                VStack {
                    Text(vm.widgetTitle)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .foregroundColor(.gray)
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
            ErrorView.init(isLarge: false)
        }
    }
}
