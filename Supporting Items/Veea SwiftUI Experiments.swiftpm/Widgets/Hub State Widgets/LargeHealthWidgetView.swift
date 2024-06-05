import SwiftUI

/// Up to 4 hubs stacked vertically with a title of Veea Hubs
struct LargeHealthWidgetView: View {
    
    let vm: WidgetModel
    
    var body: some View {
        if !vm.isInError {
            VStack(alignment: .leading, spacing: 0) {
                Text(vm.widgetTitle)
                    .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(.gray)
                VStack(alignment: .leading, spacing: 0.0) {
                    HorizontalWidgetView(vm: vm.hubModels.first!)
                    HorizontalWidgetView(vm: vm.hubModels[1])
                    HorizontalWidgetView(vm: vm.hubModels[2])
                    HorizontalWidgetView(vm: vm.hubModels.last!)
                }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
            }
        }
        else {
            ErrorView.init(isLarge: true)
        }
    }
}
