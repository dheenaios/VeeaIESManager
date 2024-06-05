import SwiftUI

struct ErrorView: View {
    
    let isLarge: Bool
    let errorMessage: String
    
    var width: CGFloat {
        isLarge ? 180 : 148
    }

    var bodyFont: Font {
        if isLarge {
            return Font(FontManager.bodyText)
        }

        return Font(FontManager.regular(size: 14))
    }

    var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 17.5) {
                Spacer()
                Image("red_veea_logo")
                    .resizable()
                    .frame(width: 28.5, height: 24.5)
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .font(bodyFont)
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                Spacer()
            }
            
            Spacer()
        }
    }
}
