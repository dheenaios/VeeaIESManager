import SwiftUI

/// A single or double widget, with the image, description and state in a vertical stack
struct VerticalWidgetView: View {
    
    let vm: HubEntryModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6.0) {
            HStack{
                Image("location_bed")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(vm.iconColor)
            }
            HStack {
                Text(vm.locationDescription)
                    .font(.system(size: 17))
            }
            HealthIndicatorView(indictorColor: vm.healthColor, 
                                healthText: vm.healthStateText)
        }
        //.padding(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
    }
}
