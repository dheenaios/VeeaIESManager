//
//  ApScanViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 24/04/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation
import UIKit


class ApScanViewModel {
    
    enum ScanType {
        case ghz2
        case ghz5
        case mesh
    }
    public var hasWifiRadioAcs = false
    
    public var scanTypeToShow: ScanType = .ghz2
    public var autoSelected = false
    
    
    private (set) var acsReport: AcsScanReport?
    private var updateTimer: Timer?
    private var scanning = false
    
    private var lastReportDate: String {
        switch scanTypeToShow {

        case .ghz2:
            return acsReport?.scan_time_2g4 ?? "Unknown".localized()
        case .ghz5:
            return acsReport?.scan_time_5g ?? "Unknown".localized()
        case .mesh:
            return acsReport?.scan_time_mesh ?? "Unknown".localized()
        }
    }
    
    public var lastReportDateCorrectedForTimezone: String {
        let dateStr = lastReportDate
        
        if dateStr == "Unknown" {
            return dateStr
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy (HH:mm:ss)"
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")

        if let utcDate = dateFormatter.date(from:dateStr) {
            dateFormatter.timeZone = TimeZone.current
            
            dateFormatter.dateFormat = "yyyy-MM-dd (HH:mm:ss)"
            let adjustedTimeStr = dateFormatter.string(from: utcDate)
            
            return "\("Last Scan".localized()): \(adjustedTimeStr)"
        }

        return "\("Last Scan".localized()): \(dateStr)"
    }
    
    var showExcludeDfs: Bool {
        guard let cap = HubDataModel
            .shared
            .baseDataModel?
            .nodeCapabilitiesConfig else {
            return false
        }
        
        let unii1AndDfsCh = scanTypeToShow == .ghz5 ? cap.unii1AndDfsCh_Ap1 : cap.unii1AndDfsCh_Ap2
        
        if !unii1AndDfsCh {
            return false
        }
        
        if scanTypeToShow == .ghz5 && autoSelected {
            return true
        }
        
        return false
    }
    
    
    var hasWifiRadioBkgndScan: Bool {
        guard let cap = HubDataModel
            .shared
            .baseDataModel?
            .nodeCapabilitiesConfig else {
            return false
        }
        
        return cap.hasWifiRadioBkgndScan
    }
    
    var numberOfRows: Int {
        guard let report = acsReport else {
            return 0
        }
        
        switch scanTypeToShow {
        case .ghz2:
            if hasWifiRadioBkgndScan {
                return report.neighbour_report_2g4?.count ?? 0
            }
            return report.channel_report_2g4?.count ?? 0
        case .ghz5:
            if hasWifiRadioBkgndScan {
                return report.neighbour_report_5g?.count ?? 0
            }
            return report.channel_report_5g?.count ?? 0
        case .mesh:
            if hasWifiRadioBkgndScan {
                return report.neighbour_report_mesh?.count ?? 0
            }
            return report.channel_report_mesh?.count ?? 0
        }
    }
    
    var footerLabelText: String {
        if acsReport == nil {
            return "Getting scan results".localized()
        }
        
        if numberOfRows > 0 {
            return ""
        }
        
        return "No Scan Results".localized()
    }
    
    var reports: [NeighbourScanReport] {
        guard let report = acsReport else {
            return [NeighbourScanReport]()
        }
        
        switch scanTypeToShow {
            
        case .ghz2:
            return report.neighbour_report_2g4 ?? []
        case .ghz5:
            return report.neighbour_report_5g ?? []
        case .mesh:
            return report.neighbour_report_mesh ?? []
        }
    }
    
    var channelReports: [ChannelScanReport] {
        guard let report = acsReport else {
            return [ChannelScanReport]()
        }
        
        switch scanTypeToShow {
            
        case .ghz2:
            return report.channel_report_2g4 ?? []
        case .ghz5:
            return report.channel_report_5g ?? []
        case .mesh:
            return report.channel_report_mesh ?? []
        }
    }
}

// MARK: - Get reports
extension ApScanViewModel {
    public func getLastScanDetails(veeaHub: HubConnectionDefinition, success:  @escaping(Bool) -> Void) {
        ApiFactory.api.getAcsScanReport(connection: veeaHub) { (report, error) in
            if (error != nil) {
                Logger.log(tag: "ApScanViewModel", message: "\("Error getting acs scan report".localized()): \(error?.localizedDescription ?? "Unknown".localized())")
                success(false)
                return
            }
            
            self.acsReport = report
            success(true)
        }
    }
    
    public func startCheckingForUpdate(veeaHub: HubConnectionDefinition, success:  @escaping(Bool, String) -> Void) {
        if scanning == true {
            return
        }
        
        scanning = true
        var count = 0
        updateTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true, block: { [weak self] (timer) in
            ApiFactory.api.getAcsScanReport(connection: veeaHub) { (report, error) in
                if self == nil {
                    return
                }
                
                if (error == nil) {
                    switch self!.scanTypeToShow {
                    case .ghz2:
                        if report?.scan_time_2g4 != self?.acsReport?.scan_time_2g4 {
                            self?.acsReport = report
                            success(true, "")
                            timer.invalidate()
                            self?.scanning = false
                        }
                    case .ghz5:
                        if (report?.scan_time_5g != self?.acsReport?.scan_time_5g) {
                            self?.acsReport = report
                            success(true, "")
                            timer.invalidate()
                            self?.scanning = false
                        }
                    case .mesh:
                        if (report?.scan_time_mesh != self?.acsReport?.scan_time_mesh) {
                            self?.acsReport = report
                            success(true, "")
                            timer.invalidate()
                            self?.scanning = false
                        }
                    }
                }
                else {
                    success(false, "Scan has started and connection to hub has dropped. Please reconnect to see your scan results.".localized())
                    timer.invalidate()
                    self?.scanning = false
                }
            }
                
            if count >= 10 {
                timer.invalidate()
                
                if HubDataModel.shared.hardwareVersion == .vhc05 {
                    success(false, "The scan started successfully, the hub reported no updated scan information.".localized())
                    self?.scanning = false
                }
                else {
                    success(false, "The scan started successfully, but there was no updated results from the hub. Please check your connection to the hub.".localized())
                    self?.scanning = false
                }
            }
            
            count += 1
        })
    }
}

// MARK: - Sending
extension ApScanViewModel {
    public func sendScanRequest(veeaHub: HubConnectionDefinition, success:  @escaping(Bool) -> Void) {
        guard let config = HubDataModel.shared.baseDataModel?.nodeConfig else {
            success(false)
            
            return
        }
       
        guard let cap = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig else {
            success(false)
            
            return
        }
        
        var nodeConfigWifiScan = config.getWifiScanConfig()
        
        if scanTypeToShow == .mesh {
                if cap.hasWifiRadioBkgndScan {
                    nodeConfigWifiScan.access1_bkgnd_scan = false
                    nodeConfigWifiScan.access2_bkgnd_scan = false
                    nodeConfigWifiScan.vmesh_bkgnd_scan = true
                }
                else if cap.hasWifiRadioAcs {
                    nodeConfigWifiScan.vmesh_acs_rescanTrigger = true
                    nodeConfigWifiScan.access1_acs_rescanTrigger = false
                    nodeConfigWifiScan.access2_acs_rescanTrigger = false
                }
                else {
                    nodeConfigWifiScan.vmeshRestartTrigger = true
                    nodeConfigWifiScan.accessRestartTrigger = false
                }
        }
        else {
                if scanTypeToShow == .ghz2 {
                    if cap.hasWifiRadioBkgndScan {
                        nodeConfigWifiScan.access1_bkgnd_scan = true
                        nodeConfigWifiScan.access2_bkgnd_scan = false
                        nodeConfigWifiScan.vmesh_bkgnd_scan = false
                    }
                    else if cap.hasWifiRadioAcs {
                        nodeConfigWifiScan.vmesh_acs_rescanTrigger = false
                        nodeConfigWifiScan.access1_acs_rescanTrigger = true
                        nodeConfigWifiScan.access2_acs_rescanTrigger = false
                    }
                    else {
                        nodeConfigWifiScan.vmeshRestartTrigger = false
                        nodeConfigWifiScan.accessRestartTrigger = true
                    }
                    
                }else if scanTypeToShow == .ghz5{
                   
                    if cap.hasWifiRadioBkgndScan {
                        nodeConfigWifiScan.access2_bkgnd_scan = true
                        nodeConfigWifiScan.access1_bkgnd_scan = false
                        nodeConfigWifiScan.vmesh_bkgnd_scan = false
                    }
                    else if cap.hasWifiRadioAcs {
                        nodeConfigWifiScan.vmesh_acs_rescanTrigger = false
                        nodeConfigWifiScan.access1_acs_rescanTrigger = false
                        nodeConfigWifiScan.access2_acs_rescanTrigger = true
                    }
                    else {
                        nodeConfigWifiScan.vmeshRestartTrigger = false
                        nodeConfigWifiScan.accessRestartTrigger = true
                    }
                }
        }
        ApiFactory.api.setConfig(connection: veeaHub, config: nodeConfigWifiScan) { (message, error) in
            if error == nil {
                success(true)
                return
            }
            
            Logger.log(tag: "ApScanViewModel", message: "\("Update failed".localized()): \(error?.localizedDescription ?? "Unknown error".localized())")
            success(false)
        }
    }
    
    public func sendScanRequestForReselect(veeaHub: HubConnectionDefinition, success:  @escaping(Bool) -> Void) {
        guard let config = HubDataModel.shared.baseDataModel?.nodeConfig else {
            success(false)
            
            return
        }        
        var nodeConfigWifiScan = config.getWifiScanConfig()
        nodeConfigWifiScan.vmesh_acs_rescanTrigger = false
        nodeConfigWifiScan.access1_acs_rescanTrigger = false
        nodeConfigWifiScan.access2_acs_rescanTrigger = false
        if scanTypeToShow == .ghz2 {
                nodeConfigWifiScan.access1_acs_rescanTrigger = true
        }
        else if scanTypeToShow == .ghz5{
                nodeConfigWifiScan.access2_acs_rescanTrigger = true
        }
        else {
            nodeConfigWifiScan.vmesh_acs_rescanTrigger = true
        }
        
        ApiFactory.api.setConfig(connection: veeaHub, config: nodeConfigWifiScan) { (message, error) in
            if error == nil {
                success(true)
                return
            }
            
            Logger.log(tag: "ApScanViewModel", message: "\("Update failed".localized()): \(error?.localizedDescription ?? "Unknown error".localized())")
            success(false)
        }
    }
}
