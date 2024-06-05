import SwiftUI

struct MediumUsageView: View {
    
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
                VStack(spacing: 8.0) {
                    Spacer()
                    MediumUsageRowView(timeFrameString: "Today", 
                                       quantUp: "20", 
                                       metricUp: "MB", 
                                       quantDown: "20", 
                                       metricDown: "MB")
                    MediumUsageRowView(timeFrameString: "Yesterday", 
                                       quantUp: "20", 
                                       metricUp: "MB", 
                                       quantDown: "20", 
                                       metricDown: "MB")
                    MediumUsageRowView(timeFrameString: "This Month", 
                                       quantUp: "20", 
                                       metricUp: "MB", 
                                       quantDown: "20", 
                                       metricDown: "MB")
                    MediumUsageRowView(timeFrameString: "Last Month", 
                                       quantUp: "21", 
                                       metricUp: "MB", 
                                       quantDown: "20", 
                                       metricDown: "MB")
                }
                .padding()
                
            }
        }
        else {
            ErrorView.init(isLarge: false)
        }
    }
}
