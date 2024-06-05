import SwiftUI

// A single hub, with the carrier name, network type and signal strength
struct SmallSignalStrengthView: View {
    
    let vm: CellularWidgetModel
    
    var body: some View {
        if !vm.isInError {
            ZStack {
                VStack {
                    Text(vm.type.title)
                        .font(Font.system(size: 14))
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
            ErrorView.init(isLarge: false)
        }
    }
}
