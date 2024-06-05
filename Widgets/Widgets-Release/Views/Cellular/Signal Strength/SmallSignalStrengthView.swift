import SwiftUI

// A single hub, with the carrier name, network type and signal strength
struct SmallSignalStrengthView: View {
    
    let vm: CellularWidgetModel
    
    var body: some View {
        if vm.state == .ok {
            ZStack {
                VStack {
                    Text(vm.widgetTitle(type: .signalStrengthSmall))
                        .font(Font(FontManager.bold(size: 13)))
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .foregroundColor(.gray)
                    Spacer()
                }
                VStack {
                    Spacer()
                        .frame(height: 30)
                    HStack(alignment: .center) {
                        SignalStrengthView(carrierName: vm.cellularSignalStrengthModel.carrierName, 
                                           networkType: vm.cellularSignalStrengthModel.networkType, 
                                           signalStrengthBars: vm.cellularSignalStrengthModel.signalStrengthBars)
                    }
                }
            }
        }
        else {
            ErrorView.init(isLarge: false,
                           errorMessage: vm.state.errorMessage)
        }
    }
}
