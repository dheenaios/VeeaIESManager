//
//  ContentView.swift
//  UI_Playground
//
//  Created by Richard Stockdale on 13/10/2022.
//

import SwiftUI

struct WDSLinksView: View {

    let vm: WDSLinksViewModel
    @EnvironmentObject var host: HostWrapper

    var body: some View {
        List {
            if vm.shownUplinkDetails {
                if let bssid = vm.uplinkNodeBssid {
                    Section(header: Text("CONNECTED UPLINK NODE")) {
                        WdsListRows.horizontalKeyValueRow(key: "Name",
                                              value: vm.uplinkNodeName)
                        WdsListRows.horizontalKeyValueRow(key: "BSSID",
                                              value: bssid)
                    }

                    Section(header: Text("UPLINK NODE SELECTION")) {
                        NavigationLink(destination: UplinkNodeSelectionView(host: host)) {
                            Text(vm.uplinkNodeSelection)
                        }
                    }
                }
                else {
                    Section(header: Text("CONNECTED UPLINK NODE")) {
                        Text("No uplink node connected")
                    }
                }
            }
        }
        .simpleListStyle()
        .frame(maxWidth: .infinity)
    }

    static func newViewController() -> UIViewController {
            let vm = WDSLinksViewModel()

            let vc = HostingController(rootView: WDSLinksView(vm: vm))
            vc.title = "Links".localized()

            return vc
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = WDSLinksViewModel()

        WDSLinksView(vm: vm)
    }
}
