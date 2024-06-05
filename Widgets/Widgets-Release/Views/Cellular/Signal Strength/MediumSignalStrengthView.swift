import SwiftUI

struct MediumSignalStrengthView: View {
    
    let vm: CellularWidgetModel
    private let leftSideTitle = "Network"
    private let rightSideTitle = "Data Usage"
    
    var body: some View {
        if vm.state == .ok {
            VStack {
                VStack {
                    Text(vm.widgetTitle(type: .signalStrengthMedium))
                        .font(Font(FontManager.bold(size: 12)))
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .foregroundColor(.gray)
                }
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(leftSideTitle)
                                .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                                .padding([.leading])
                                .foregroundColor(.gray)
                                .font(Font(FontManager.regular(size: 16)))
                            
                            SignalStrengthView(carrierName: vm.cellularSignalStrengthModel.carrierName, 
                                               networkType: vm.cellularSignalStrengthModel.networkType, 
                                               signalStrengthBars: vm.cellularSignalStrengthModel.signalStrengthBars)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading) {
                            Text(rightSideTitle)
                                .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                                .padding([.leading])
                                .foregroundColor(.gray)
                                .font(Font(FontManager.regular(size: 16)))
                            
                            TodayUsageView(quantUp: vm.cellularUsageModel.todayUp,
                                           quantDown: vm.cellularUsageModel.todayDown)
                            
                            Spacer()
                        }
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
}
