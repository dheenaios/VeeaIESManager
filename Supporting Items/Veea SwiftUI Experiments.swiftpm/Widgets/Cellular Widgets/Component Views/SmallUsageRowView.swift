import SwiftUI

struct SmallUsageRowView: View {
    let quant: String
    let metric: String
    let up: Bool
    
    private var arrow: Image {
        if up {
            return Image(systemName: "arrow.up")
        }
        
        return Image(systemName: "arrow.down")
    }
    
    private var arrowColor: Color {
        up ? .green : .blue
    }
    
    var body: some View {
        HStack {
            arrow
                .foregroundColor(arrowColor)
            Text(quant)
                .font(.system(size: 25.0))
            Text(metric)
                .font(.system(size: 19.0))
            Spacer()
        }
    }
} 
