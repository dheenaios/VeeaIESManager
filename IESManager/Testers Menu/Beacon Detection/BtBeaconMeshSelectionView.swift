//
//  BtBeaconMeshSelectionView.swift
//  IESManager
//
//  Created by Richard Stockdale on 09/02/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import SwiftUI

struct BtBeaconMeshSelectionView: View {

    let knownBeacons = UserSettings.beacons
    var group: String {
        if knownBeacons.isEmpty {
            return "Select a group in the main UI, then return here and select the mesh"
        }

        return knownBeacons.first!.groupId
    }

    var body: some View {
        VStack {
            if knownBeacons.isEmpty {
                Text(group)
            }
            else {
                List() {
                    Section(header: Text("Group ID:\n \(group)")) {
                        ForEach(knownBeacons) { beacon in
                            NavigationLink {
                                BtBeaconScannerView(vm: BtBeaconScannerViewModel(beacon: beacon))
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(beacon.meshName)
                                    Text("Encryption Key: \(beacon.encryptKey)")
                                        .font(.caption)
                                    Text("Sub Domain: \(beacon.subdomain)")
                                        .font(.caption)
                                    Text("Instance ID: \(beacon.instanceID)")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    static func inHostViewController() -> UIViewController {
        let vc = HostingController(rootView: BtBeaconMeshSelectionView())
        vc.title = "Select Mesh".localized()

        return vc
    }
}

struct BtBeaconMeshSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        BtBeaconMeshSelectionView()
    }
}
