import SwiftUI

// A single hub, with the carrier name, network type and signal strength
struct SmallUsageView: View {
    
    let vm: CellularWidgetModel
    
    var body: some View {
        if vm.state == .ok {
            VStack {
                Text(vm.widgetTitle(type: .usageSmall))
                    .font(Font(FontManager.bold(size: 13)))
                    .multilineTextAlignment(.leading)
                    .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(.gray)
                Spacer()
                VStack(spacing: 18) {
                    SmallUsageRowView(quant: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.todayUp).0,
                                      metric: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.todayUp).1,
                                      up: true)
                    .padding(.leading)
                    SmallUsageRowView(quant: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.todayDown).0,
                                      metric: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.todayDown).1,
                                      up: false)
                    .padding(.leading)
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
