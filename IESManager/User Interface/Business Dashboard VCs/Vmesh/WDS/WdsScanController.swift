//
//  WDSScanController.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/10/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation

protocol WdsScannerControllerProtocol {
    func updateDidCompleteWithNewReport(report: WdsScanReport)
    func updateDidCompleteWithError(error: String)
    func isScanningStateDidUpdate(isScanning: Bool)
}

class WdsScanController {
    private(set) var lastScanReport: WdsScanReport?
    private(set) var isScanning: Bool = false {
        didSet {
            delegate?.isScanningStateDidUpdate(isScanning: isScanning)
        }
    }

    private var updateTimer: Timer?

    var delegate: WdsScannerControllerProtocol?

    private var veeaHubConnection: HubConnectionDefinition? = {
        return HubDataModel.shared.connectedVeeaHub
    }()

    func startNewScan() {
        isScanning = true
        triggerScan()
    }

    private func triggerScan() {
        // node_config/vmesh_wds_scan_trigger

        guard var config = HubDataModel.shared.baseDataModel?.nodeConfig,
              let veeaHub = veeaHubConnection else {
            reportError(error: "Not connected to the VeeaHub")

            return
        }

        config.vmesh_wds_scan_trigger = true

        ApiFactory.api.setConfig(connection: veeaHub, config: config) { (message, error) in
            if let error {
                self.reportError(error: error.errorDescription())
                return
            }

            self.setUpTimer()
        }
    }

    private func setUpTimer() {
        if updateTimer != nil { return }
        updateTimer = Timer.scheduledTimer(withTimeInterval: 6.0,
                                           repeats: true,
                                           block: { [weak self] (timer) in
            self?.updateWdsScanReport()
        })
    }

    /// If a scan has never been run, this will not have any set values
    private func updateWdsScanReport() {
        guard let veeaHubConnection else {
            reportError(error: "No connection to the VeeaHub")
            return
        }

        ApiFactory.api.getWdsScanReport(connection: veeaHubConnection) { report, error in

            self.getIsScanning()

            // Report error
            if let error {
                self.reportError(error: error.errorDescription())
                return
            }

            // Report nothing returned (probably will never be called)
            guard let report else {
                self.reportError(error: "No report returned")
                return
            }

            // Report first new
            guard let lastScanReport = self.lastScanReport else {
                self.lastScanReport = report
                if report.hasScanValues {
                    self.delegate?.updateDidCompleteWithNewReport(report: report)
                    self.clearTimer()
                }
                return
            }

            // Report a new scan
            if report != lastScanReport {
                self.lastScanReport = report
                self.delegate?.updateDidCompleteWithNewReport(report: report)
                self.clearTimer()
                return
            }
        }
    }

    private func getIsScanning() {
        guard let veeaHubConnection else {
            reportError(error: "No connection to the VeeaHub")
            return
        }

        // node_status/vmesh_wds_scanning
        ApiFactory.api.getNodeStatus(connection: veeaHubConnection) { nodeStatus, error in
            guard let nodeStatus else {
                self.reportError(error: error?.localizedDescription ?? "Unable to check scan status")
                return
            }


            self.isScanning = nodeStatus.vmesh_wds_scanning

            if !self.isScanning {
                self.clearTimer()
            }
        }
    }

    private func reportError(error: String) {
        Logger.log(tag: "WdsScanController", message: "Error: \(error)")
        delegate?.updateDidCompleteWithError(error: error)
        clearTimer()
        isScanning = false
    }

    private func clearTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    init() {
        // On init get whatever scan info may exist already
        updateWdsScanReport()
    }
}
