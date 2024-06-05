import SwiftUI

struct ActionButton: View {
    
    let title: String
    let bgColor: Color
    
    let action: () -> Void
    
    var body: some View {
        
        if #available(iOS 14, *) {
            Button(action: action) {
                Text(title)
                    .frame(minWidth: 0,
                           idealWidth: .infinity,
                           maxWidth: .infinity,
                           minHeight: 0,
                           idealHeight: 44, maxHeight: 44)
            }
            .foregroundColor(.white)
            .background(bgColor)
            .cornerRadius(8)
            .font(.subheadline)
        } else {
            Button(title, action: action)
                .foregroundColor(.white)
                .background(bgColor)
                .cornerRadius(8)
                .font(.subheadline)
            
        }
        
        
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ActionButton(title: "Button",
                     bgColor: .blue) {}
    }
}
