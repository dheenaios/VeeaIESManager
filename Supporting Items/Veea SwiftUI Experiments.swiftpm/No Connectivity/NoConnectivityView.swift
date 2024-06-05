import SwiftUI

struct NoConnectivityView: View {
    private let titleText = "No Internet Connection"
    private let subTitleText = "Slow or no internet connection"
    private let actionText = "Please check your internet connection"
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image("No Connection")
                .resizable()
                .frame(width: 75, height: 56)
            Spacer()
                .frame(height: 16)
            Text(titleText)
                .font(.system(size: 20.0))
            Spacer()
                .frame(height: 10)
            Text(subTitleText)
                .font(.system(size: 17.0))
            Text(actionText)
                .font(.system(size: 17.0))
        }
    }
}
