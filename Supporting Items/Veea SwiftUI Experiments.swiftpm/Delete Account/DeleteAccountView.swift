import SwiftUI

struct DeleteAccountView: View {
    private let deteteDescription = "Are you sure you want to delete your account?"
    private let moreInfo = "You'll have 30 days to re-login with your credentials. If you wish to cancel the account deletion in that period, please contact customer support.  After this period, your account will be irreversibly deleted."
    private let buttonTitle = "Delete my account"
    
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(deteteDescription)
            Text(moreInfo)
            
            Spacer()
            
            //Update to Action button in the app
            Button(action: action) {
                Text(buttonTitle)
                    .frame(minWidth: 0,
                           idealWidth: .infinity,
                           maxWidth: .infinity,
                           minHeight: 0,
                           idealHeight: 44, maxHeight: 44)
            }
            .foregroundColor(.white)
            .background(.red)
            .cornerRadius(8)
            //.font(Font(font))
        }
        .padding()
    }
}
