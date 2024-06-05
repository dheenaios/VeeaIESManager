import SwiftUI

struct TodayUsageView: View {
    let timeFrameString = "Today"
    let quantUp: String
    let quantDown: String
    
    var body: some View {
        Spacer()
        Text(timeFrameString)
            .font(Font.system(size: 16))
            .padding([.leading])
            
        Spacer()
        SmallHorizontalUsageRowView(quantUp: quantUp, 
                                    quantDown: quantDown)
        .padding([.leading])
    }
}
