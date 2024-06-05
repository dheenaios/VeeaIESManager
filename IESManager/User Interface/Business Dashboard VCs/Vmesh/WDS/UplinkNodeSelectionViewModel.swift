//
//  UplinkNodeSelectionViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 17/10/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SwiftUI

class UplinkNodeSelectionViewModel: ObservableObject {

    let scanController = WdsScanController()
    public var lastReport: WdsScanReport?
    var lastReportDate: String? {
        guard let lastReport else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy (HH:mm:ss)"
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")

        if let utcDate = dateFormatter.date(from:lastReport.scan_time) {
            dateFormatter.timeZone = TimeZone.current

            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let adjustedTimeStr = dateFormatter.string(from: utcDate)

            return adjustedTimeStr
        }

        return lastReport.scan_time
    }

    @Published var refreshButtonEnabled: Bool = false
    @Published var selectedBssid: String
    @Published var sending: Bool = false

    // Alerts
    var lastSendError = ""
    @Published var showErrorAlert = false
    var confirmText = "This action could interupt connectivity to this VeeaHub. Are you sure you would like to proceed?".localized()
    @Published var showConfirmationAlert = false

    func isSelectedBssid(nodeBssid: String) -> Bool {
        if nodeBssid.isEmpty && selectedBssid.isEmpty {
            return true
        }

        return nodeBssid == selectedBssid
    }

    var disableApplyButton: Bool {
        guard HubDataModel.shared.connectedVeeaHub != nil else {
            return true
        }

        return selectedBssid == HubDataModel.shared.baseDataModel?.nodeConfig?.vmesh_wds_manual_bssid ?? ""
    }

    var rows: [NodeInfoModel] {
        let details = WdsStateDetails(lastReport: lastReport)
        return details.nodesPresent
    }

    func startScanIfNonExisting() {
        if scanController.lastScanReport == nil {
            startScan()
        }
    }

    func startScan() {
        scanController.startNewScan()
    }

    /// Send changes to the hub
    /// - Parameter complete: Closure with completion
    func applyChanges(complete: @escaping(() -> Void)) {
        guard var config = HubDataModel.shared.baseDataModel?.nodeConfig,
              let veeaHub = HubDataModel.shared.connectedVeeaHub else {
            showError(error: "No connection".localized())
            return
        }

        sending = true
        config.vmesh_wds_manual_bssid = selectedBssid

        ApiFactory.api.setConfig(connection: veeaHub,
                                 config: config) { (message, error) in

            self.sending = false

            if let error {
                self.showError(error: error.errorDescription())
                return
            }

            // If success then dismiss the view
            self.lastSendError = ""
            complete()
        }
    }

    private func showError(error: String) {
        self.lastSendError = error
        self.showErrorAlert.toggle()
    }

    init() {
        self.selectedBssid = HubDataModel.shared.baseDataModel?.nodeConfig?.vmesh_wds_manual_bssid ?? ""
        scanController.delegate = self
    }
}

extension UplinkNodeSelectionViewModel: WdsScannerControllerProtocol {
    func isScanningStateDidUpdate(isScanning: Bool) {
        refreshButtonEnabled = !isScanning
    }

    func updateDidCompleteWithNewReport(report: WdsScanReport) {
        self.lastReport = report
    }

    func updateDidCompleteWithError(error: String) {
        //print("Scan did complete with error: \(error)")
    }
}
