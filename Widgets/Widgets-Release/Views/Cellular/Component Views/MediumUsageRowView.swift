import SwiftUI

struct MediumUsageRowView: View {
    let timeFrameString: String
    
    let quantUp: String
    let metricUp: String
    
    let quantDown: String
    let metricDown: String

    
    var body: some View {
        HStack() {
            Text(timeFrameString)
                .frame(width: 90, alignment: .leading)
                .font(Font(FontManager.regular(size: 14)))
                .foregroundColor(.gray)
            Image("usageUp")
            Text("\(quantUp)\(metricUp)")
                .frame(width: 60, alignment: .leading)
                .font(Font(FontManager.medium(size: 14)))
            Image("usageDown")
            Text("\(quantDown)\(metricDown)")
                .frame(width: 60, alignment: .leading)
                .font(Font(FontManager.medium(size: 14)))
            Spacer()
        }
    }
} 

struct SmallHorizontalUsageRowView: View {
    let quantUp: String
    let quantDown: String
    
    var body: some View {
        HStack() {
            Image("usageUp")
            Text(quantUp)
                .frame(width: 60, alignment: .leading)
                .font(Font(FontManager.medium(size: 16)))
            Image("usageDown")
            Text(quantDown)
                .frame(width: 60, alignment: .leading)
                .font(Font(FontManager.medium(size: 16)))
            Spacer()
        }
    }
} 
