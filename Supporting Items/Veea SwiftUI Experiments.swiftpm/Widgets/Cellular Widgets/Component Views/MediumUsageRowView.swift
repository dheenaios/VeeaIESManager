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
                .frame(width: 125, alignment: .leading)
                .font(.system(size: 14.0))
                .foregroundColor(.gray)
            Image(systemName: "arrow.up")
                .foregroundColor(.green)
            Text("\(quantUp)\(metricUp)")
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 14.0))
            Image(systemName: "arrow.down")
                .foregroundColor(.blue)
            Text("\(quantDown)\(metricDown)")
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 14.0))
            Spacer()
        }
    }
} 

struct SmallHorizontalUsageRowView: View {
    let quantUp: String
    let quantDown: String
    
    var body: some View {
        HStack() {
            Image(systemName: "arrow.up")
                .foregroundColor(.green)
            Text(quantUp)
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 14.0))
            Image(systemName: "arrow.down")
                .foregroundColor(.blue)
            Text(quantDown)
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 14.0))
            Spacer()
        }
    }
} 
