//
//  BtBeaconScanner.swift
//  IESManager
//
//  Created by Richard Stockdale on 10/11/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import SwiftUI

struct BtBeaconScannerView: View {

    @ObservedObject var vm: BtBeaconScannerViewModel

    var body: some View {
        VStack {
            VStack {
                Text("Looking for beacons on \(vm.beacon.meshName)")
            }
            .padding()

            if !vm.hubs.isEmpty {
                List {
                    Section(header: Text("Found Hubs")) {
                        ForEach(vm.hubs, id: \.self) { hub in
                            VStack(alignment: .leading) {
                                if hub.lost {
                                    Text("LOST: " + hub.name)
                                    Text("at: \(hub.seenTime)")
                                        .font(.caption)
                                }
                                else {
                                    Text("Saw: " + hub.name)
                                    Text("at: \(hub.seenTime)")
                                        .font(.caption)
                                    Text("SSID: \(hub.ssid). Psk: \(hub.psk)")
                                        .font(.caption)
                                }

                            }
                        }
                    }
                }
            }
            else {
                Text("This can take a few seconds")
            }
        }
        .onAppear { vm.startScan() }
        .onDisappear { vm.stopScan() }
    }
}
