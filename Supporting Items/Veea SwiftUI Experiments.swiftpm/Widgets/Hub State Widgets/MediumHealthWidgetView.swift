import SwiftUI

// A two hubs, side by side, with a title of Veea Hubs
struct MediumHealthWidgetView: View {
    
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
                VStack {
                    Spacer()
                    HStack {
                        VerticalWidgetView(vm: vm.hubModels.first!)
                            .frame(maxWidth: .infinity)
                        Divider()
                            .frame(height: 90.0)
                        VerticalWidgetView(vm: vm.hubModels.last!)
                            .frame(maxWidth: .infinity)
                    }
                    Spacer()
                }
                
            }
        }
        else {
            ErrorView.init(isLarge: false)
        }
    }
}
