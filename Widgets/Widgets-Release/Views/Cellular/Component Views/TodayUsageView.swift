import SwiftUI

struct TodayUsageView: View {
    let timeFrameString = "Today"
    let quantUp: String
    let quantDown: String
    
    var body: some View {
        Spacer()
        Text(timeFrameString)
            .font(Font(FontManager.bold(size: 12)))
            .padding([.leading])
            
        Spacer()
        SmallHorizontalUsageRowView(quantUp: quantUp, 
                                    quantDown: quantDown)
        .padding([.leading])
    }
}
