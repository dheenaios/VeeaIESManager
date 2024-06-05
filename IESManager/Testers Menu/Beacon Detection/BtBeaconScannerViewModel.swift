//
//  BtBeaconScannerViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 10/02/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import Foundation

class BtBeaconScannerViewModel: ObservableObject, HubBeaconScannerDelegate {

    let beacon: VHBeacon

    struct FoundHubInfo: Hashable, Equatable {
        let name: String
        let ssid: String
        let psk: String
        let seenTime: String
        let lost: Bool
        let uuid = UUID()

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name &&
            lhs.ssid == rhs.ssid &&
            lhs.psk == rhs.psk &&
            lhs.uuid == rhs.uuid
        }
    }

    private var scanner = HubBeaconScanner.shared
    @Published var hubs: [FoundHubInfo]

    private var dateFormatter: DateFormatter

    func startScan() {
        scanner.delegate = self
        scanner.startScan(for: beacon)
    }

    func stopScan() {
        scanner.stopScan()
    }

    func didFindIes(_ device: VeeaHubConnection) {
        updateAfterSighting(device)
    }

    func didUpdateIes(_ device: VeeaHubConnection) {
        updateAfterSighting(device)
    }

    func didLooseIes(_ device: VeeaHubConnection) {
        updateAfterSighting(device, lost: true)
    }

    private func updateAfterSighting(_ device: VeeaHubConnection, lost: Bool = false) {
        let now = self.dateFormatter.string(from: Date())
        let foundHub = FoundHubInfo(name: device.hubDisplayName,
                                    ssid: device.ssid,
                                    psk: device.psk,
                                    seenTime: now,
                                    lost: lost)

        hubs.append(foundHub)
    }

    init(beacon: VHBeacon) {
        self.beacon = beacon
        self.hubs = [FoundHubInfo]()
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateStyle = .short
        self.dateFormatter.timeStyle = .long
    }
}
