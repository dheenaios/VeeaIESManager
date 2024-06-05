import SwiftUI

/// A single or double widget, with the image, description and state in a vertical stack
struct VerticalWidgetView: View {
    
    let vm: HubEntryModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6.0) {
            VStack(alignment: .leading, spacing: 6.0) {
                HStack{
                    Image(vm.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(vm.iconColor)
                }
                HStack {
                    Text(vm.locationDescription)
                        .font(Font(FontManager.bodyText))
                }
                HealthIndicatorView(indictorColor: vm.healthColor,
                                    healthText: vm.healthStateText)
            }
        }
    }
}
