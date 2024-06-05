import SwiftUI

/// Up to 4 hubs stacked vertically with a title of Veea Hubs
struct LargeHealthWidgetView: View {
    
    let vm: WidgetModel
    
    var body: some View {
        if vm.state == .ok {
            VStack(alignment: .leading, spacing: 0) {
                Text(vm.widgetTitle())
                    .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(.gray)
                    .font(Font(FontManager.bodyText))
                
                VStack(alignment: .leading, spacing: 0.0) {
                    configViews(for: 0)
                    configViews(for: 1)
                    configViews(for: 2)
                    configViews(for: 3)
                }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))

            }
        }
        else {
            ErrorView(isLarge: true,
                      errorMessage: vm.state.errorMessage)
        }
    }

    @ViewBuilder
    private func configViews(for index: Int) -> some View {
        if vm.hubModels.count > index {
            HorizontalWidgetView(vm: vm.hubModels[index])
        }
        else {
            Spacer()
        }
    }
}
