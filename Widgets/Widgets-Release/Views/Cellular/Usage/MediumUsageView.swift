import SwiftUI

struct MediumUsageView: View {
    
    let vm: CellularWidgetModel
    
    var body: some View {
        if vm.state == .ok {
            ZStack {
                VStack {
                    Text(vm.widgetTitle(type: .usageMedium))
                        .font(Font(FontManager.bold(size: 13)))
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .foregroundColor(.gray)
                    Spacer()
                }
                VStack(spacing: 8.0) {
                    Spacer()
                    MediumUsageRowView(timeFrameString: "Today", 
                                       quantUp: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.todayUp).0,
                                       metricUp: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.todayUp).1,
                                       quantDown: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.todayDown).0,
                                       metricDown: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.todayDown).1)
                    MediumUsageRowView(timeFrameString: "Yesterday", 
                                       quantUp: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.yesterdayUp).0,
                                       metricUp: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.yesterdayUp).1,
                                       quantDown: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.yesterdayDown).0,
                                       metricDown: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.yesterdayDown).1)
                    MediumUsageRowView(timeFrameString: "This Month", 
                                       quantUp: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.thisMonthUp).0,
                                       metricUp: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.thisMonthUp).1,
                                       quantDown: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.thisMonthDown).0,
                                       metricDown: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.thisMonthDown).1)
                    MediumUsageRowView(timeFrameString: "Last Month", 
                                       quantUp: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.lastMonthUp).0,
                                       metricUp: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.lastMonthUp).1,
                                       quantDown: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.lastMonthDown).0,
                                       metricDown: vm.cellularUsageModel.valueAndMetric(vm.cellularUsageModel.lastMonthDown).1)
                }
                .padding()
            }
        }
        else {
            ErrorView(isLarge: false,
                      errorMessage: vm.state.errorMessage)
        }
    }
}
