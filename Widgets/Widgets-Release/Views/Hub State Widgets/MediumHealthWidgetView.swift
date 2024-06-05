import SwiftUI

// A two hubs, side by side, with a title of Veea Hubs
struct MediumHealthWidgetView: View {
    
    let vm: WidgetModel
    
    var body: some View {
        if vm.state == .ok {
            ZStack {
                VStack {
                    Text(vm.widgetTitle())
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .foregroundColor(.gray)
                        .font(Font(FontManager.bodyText))
                    
                    Spacer()
                }
                VStack {
                    Spacer()
                    HStack {
                        configViews(for: 0)
                            .frame(maxWidth: .infinity)
                        Divider()
                            .frame(height: 90.0)
                        configViews(for: 1)
                            .frame(maxWidth: .infinity)
                    }
                    Spacer()
                }

            }
        }
        else {
            ErrorView(isLarge: false,
                      errorMessage: vm.state.errorMessage)
        }
    }

    @ViewBuilder
    private func configViews(for index: Int) -> some View {
        if vm.hubModels.count > index {
            VerticalWidgetView(vm: vm.hubModels[index])
        }
        else {
            Spacer()
        }
    }
}
