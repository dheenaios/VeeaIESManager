import SwiftUI

struct SmallUsageRowView: View {
    let quant: String
    let metric: String
    let up: Bool
    
    private var arrow: Image {
        if up {
            return Image("usageUp")
                .resizable()
        }
        
        return Image("usageDown")
            .resizable()
    }
    
    var body: some View {
        HStack {
            arrow
                .frame(width: 18, height: 18)
            Text(quant)
                .font(Font(FontManager.medium(size: 25)))
            Text(metric)
                .font(Font(FontManager.medium(size: 19)))
            Spacer()
        }
    }
} 
