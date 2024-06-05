import SwiftUI

// A single hub, with the carrier name, network type and signal strength
struct SmallUsageView: View {
    
    let vm: CellularWidgetModel
    
    var body: some View {
        if !vm.isInError {
            VStack {
                Text(vm.type.title)
                    .font(Font.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .frame(minWidth: 0.0, idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(.gray)
                Spacer()
                VStack(spacing: 18) {
                    SmallUsageRowView(quant: "20", 
                                      metric: "MB", 
                                      up: true)
                    .padding(.leading)
                    SmallUsageRowView(quant: "20", 
                                      metric: "MB", 
                                      up: false)
                    .padding(.leading)
                    Spacer()
                }
            }
        }
        else {
            ErrorView.init(isLarge: false)
        }
    }
}
