import SwiftUI
import SharedBackendNetworking

struct EntryRowView: View {
    
    let props: NetworkCallLoggerItem
    
    private let upArrow = "arrow.up"
    private let downArrow = "arrow.down"
    
    private var directionImageName: String {
        props.send ? upArrow : downArrow
    }
    
    let rows: [String] = ["URL", "Result", "Time"]
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: directionImageName)
            VStack(alignment: .leading) {
                ForEach(props.summaryRows, id: \.self) { row in
                    Text(row)
                        .font(.caption)
                }
            }
            Spacer()
        }
        .padding()
    }
}
