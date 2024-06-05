import SwiftUI

/// A colored indicator and explantory text to its left
struct HealthIndicatorView: View {
    
    let indictorColor: Color
    let healthText: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(indictorColor)
                .frame(width: 8, height: 8)
            Text(healthText)
                .font(.system(size: 14))
            
        }
    }
}
