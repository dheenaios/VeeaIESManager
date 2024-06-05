import SwiftUI

struct SignalStrengthView: View {
    let carrierName: String
    let networkType: String
    let signalStrengthBars: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(carrierName)
                .font(Font.system(size: 16))
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
