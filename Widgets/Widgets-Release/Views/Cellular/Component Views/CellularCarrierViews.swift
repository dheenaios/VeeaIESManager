import SwiftUI


struct NetworkTypeView: View {
    let description: String
    
    var body: some View {
        ZStack {
            Capsule()
                .foregroundColor(.gray)
            Text(description)
                .foregroundColor(.white)
                .font(Font(FontManager.medium(size: 13)))
        }
        .frame(width: 37, height: 19, alignment: .center)
    }
}


struct CellularSignalStrengthView: View {
    let strength: Int
    
    private func barColor(barNumber: Int) -> Color {
        return barNumber < strength ? .green : .gray
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(barColor(barNumber: 0))
                    .frame(width: 6, height: 5.0)
            }
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(barColor(barNumber: 1))
                    .frame(width: 6, height: 10.0)
            }
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(barColor(barNumber: 2))
                    .frame(width: 6, height: 15.0)
            }
            VStack {
                Rectangle()
                    .foregroundColor(barColor(barNumber: 3))
                    .frame(width: 6, height: 19.0)
            }
            
        }
        .frame(width: 40, height: 20, alignment: .leading)
    }
    
}
