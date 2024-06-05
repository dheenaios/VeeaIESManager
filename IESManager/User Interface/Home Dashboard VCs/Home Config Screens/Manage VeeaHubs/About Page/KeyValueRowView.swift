import SwiftUI

struct KeyValueRowView: View {
    let key: String
    let value: String
    private let height: CGFloat = 15
    private let fontSize: CGFloat = 12
    private let hPadding: CGFloat = 10

    var iOS15: Bool {
        guard #available(iOS 15, *) else {
            return false
        }

        return true
    }

    let keyColor = InterfaceManager.shared.cm.text2
    
    var body: some View {
        HStack {
            Text(key)
                .foregroundColor(Color(keyColor.colorForAppearance))
                .font(.system(size: fontSize))
                .padding(.leading, hPadding)
            Spacer()
            Text(value)
                .font(.system(size: fontSize))
                .bold()
                .padding(.trailing, hPadding)
        }
        .frame(height: height)
        .if(iOS15) {
            if #available(iOS 15.0, *) {
                $0.listRowSeparator(.hidden)
            }
        }
    }
}

struct KeyValueRowView_Previews: PreviewProvider {
    static var previews: some View {
        KeyValueRowView(key: "This is the key", value: "This is the value")
    }
}
