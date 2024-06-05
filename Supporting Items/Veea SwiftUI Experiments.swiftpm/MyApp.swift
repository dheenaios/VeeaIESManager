import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
//            HealthWidgets()
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//                .edgesIgnoringSafeArea(.all)
//                .background(Color.init(red: 248 / 255, green: 248 / 255, blue: 248 / 255))
            
//            CellularUsageWidgets()
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//                .edgesIgnoringSafeArea(.all)
//                .background(Color.init(red: 248 / 255, green: 248 / 255, blue: 248 / 255))
            
//            NoConnectivityView()
            
            //MaintenanceModeView()
            ActionButton(title: "Test", bgColor: .red) { 
                // Action
            }
            
        }
    }
}
