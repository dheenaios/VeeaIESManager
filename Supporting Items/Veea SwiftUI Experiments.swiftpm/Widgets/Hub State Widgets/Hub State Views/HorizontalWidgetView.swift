import SwiftUI

/// A single row in a lerge widget. with the image, description and state in a vertical stack
struct HorizontalWidgetView: View {
    
    let vm: HubEntryModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 25) {
            HStack{
                Image("location_bed")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(vm.iconColor)
            }
            
            
            VStack(alignment: .leading, spacing: 6.0) {
                Text(vm.locationDescription)
                    .font(.system(size: 17))
                HealthIndicatorView(indictorColor: vm.healthColor, 
                                    healthText: vm.healthStateText)
            }
        }
        .padding()
    }
}
