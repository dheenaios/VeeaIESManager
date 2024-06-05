import SwiftUI

struct ErrorView: View {
    
    let isLarge: Bool
    
    var width: CGFloat {
        isLarge ? 180 : 148
    }
    
    var fontSize: CGFloat {
        isLarge ? 17 : 14
    }
    
    let text = "Something went wrong\nUnable to load"
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 17.5) {
                Spacer()
                Image("red_veea_logo")
                    .resizable()
                    .frame(width: 28.5, height: 24.5)
                Text(text)
                    .multilineTextAlignment(.center)
                    .font(Font.system(size: fontSize))
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                Spacer()
            }
            
            Spacer()
        }
    }
}
