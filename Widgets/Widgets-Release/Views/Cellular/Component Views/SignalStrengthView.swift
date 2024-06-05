import SwiftUI

struct SignalStrengthView: View {
    let carrierName: String
    let networkType: String
    let signalStrengthBars: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(carrierName)
                .font(Font(FontManager.medium(size: 16)))
                .lineLimit(1)
                .padding([.leading])
            
            HStack(spacing: 12) {
                NetworkTypeView(description: networkType)
                CellularSignalStrengthView(strength: signalStrengthBars)
                Spacer()
            }
            .padding([.leading])
            
            Spacer()
        }
    }
}
