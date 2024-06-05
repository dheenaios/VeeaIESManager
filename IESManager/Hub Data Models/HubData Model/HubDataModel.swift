//
//  HubDataModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 04/07/2018.
//  Copyright © 2018 Virtuosys. All rights reserved.
//

import Foundation


protocol HubDataModelProgressDelegate {
    func updateDidComplete(success: Bool, message: String?)
    func updateDidCompleteAfterScan(success: Bool, message: String?)
    func updateDidProgress(progress: Float, message: String?)
}

class HubDataModel {
    
    /// Success, Progress, Message
    typealias ProgressAndCompletion = ((Bool, Float?, String?) -> Void)
    
    let tag = "HubDataModel"
    static var shared = HubDataModel()
    
    // MARK: - Data Models
    
    var baseDataModel: HubBaseDataModel?
    var optionalAppDetails: OptionalAppsDataModel?
    
    var delegate: HubDataModelProgressDelegate?
    var progressClosure: ProgressAndCompletion?
    
    // MARK: Hardware
    public var connectedVeeaHub: HubConnectionDefinition? {
        didSet {
            //print("Connected hub did change")
        }
    }
    
    /// The hardware version of the connected hub. Returns 0.5 is unknown
    var hardwareVersion: VeeaHubHardwareModel {
        guard let serial = baseDataModel?.nodeInfoConfig?.unit_serial_number else {
            return .unknown
        }
        
        return VeeaHubHardwareModel(serial: serial)
    }
    
    // MARK: Snapshots
    
    /// Optional. If "some:" the info returned will be this config
    public var configurationSnapShotItem: ConfigurationSnapShot?
    public var snapShotInUse = false {
        didSet {
            nilAllDataMembers()
            
            if snapShotInUse {
                updateDataModelsFromSnapshots()
            }
            else {
                if connectedVeeaHub != nil {
                    updateConfigInfo(observer: nil)
                }
            }
        }
    }
    
    var isMN: Bool {
        get { return baseDataModel?.nodeConfig?.node_type == "MN" }
    }
    
    var isDataSetComplete: Bool {
        get {
            guard baseDataModel != nil,
                  let originalJson = baseDataModel?.originalJson else {
                    return false
            }
            
            if originalJson.isEmpty {
                return false
            }
            
            return true
        }
    }
    
    /// Updates the config, but after a short delay. Useful if the hub needs to be given time to do some work
    ///
    /// - Parameter observer: completion observer
    func updateConfigInfoAfterDelay(observer: HubDataModelProgressDelegate?) {
        let delay = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.updateConfigInfo(observer: observer)
        }
    }
    
    func updateConfigInfo(observer: HubDataModelProgressDelegate?) {
        guard let connection = connectedVeeaHub else {
            //print("No IES")
            return
        }
        
        delegate = observer
        Logger.log(tag: tag, message: "Setting all data members to nil")
        nilAllDataMembers()
        getDataModels(connection: connection)
    }
    
    func updateConfigInfoForScan(observer: HubDataModelProgressDelegate?) {
        guard let connection = connectedVeeaHub else {
            //print("No IES")
            return
        }
        
        delegate = observer
        Logger.log(tag: tag, message: "Setting all data members to nil")
        nilAllDataMembers()
        getDataModelsForScan(connection: connection)
    }
    
    func updateConfigInfo(nilAllMembersBeforeCall: Bool = true,
                          progressAndCompletion: @escaping ProgressAndCompletion) {
        guard let connection = connectedVeeaHub else {
            print("No IES")
            return
        }
        
        progressClosure = progressAndCompletion
        Logger.log(tag: tag, message: "Setting all data members to nil")

        if nilAllMembersBeforeCall {
            nilAllDataMembers()
        }

        getDataModels(connection: connection)
    }
    
    public func nilAllDataMembers() {
        baseDataModel = nil
        optionalAppDetails = nil
    }
    
    func reportModelUpdateError(message: String) {
        DispatchQueue.main.async {
            self.delegate?.updateDidComplete(success: false, message: message)
            self.updateProgress(success: false, progress: nil, message: message)
        }
    }
    
    func updateCompletedSucessfully(message: String) {
        DispatchQueue.main.async {
            let updateComplete = "Update completed: ".localized()

            self.delegate?.updateDidComplete(success: true, message: "\(updateComplete) \(message)")
            self.updateProgress(success: true, progress: 1.0, message: "\(updateComplete) \(message)")

            NotificationCenter.default.post(name: Notification.Name.DataModelUpdateCompleted, object: nil, userInfo: nil)
            self.delegate = nil
            self.progressClosure = nil
        }
    }
    
    func updateCompletedSucessfullyAfterScan(message: String) {
        DispatchQueue.main.async {
            let updateComplete = "Update completed: ".localized()
            
            self.delegate?.updateDidCompleteAfterScan(success: true, message: "\(updateComplete) \(message)")
            self.updateProgress(success: true, progress: 1.0, message: "\(updateComplete) \(message)")

        }
    }
}

// MARK: - Fetch Data Calls
extension HubDataModel {
    fileprivate func getDataModels(connection: HubConnectionDefinition) {
        if snapShotInUse {
            // Update with the snapshot detail
            updateDataModelsFromSnapshots()
            self.updateCompletedSucessfully(message: "Success".localized())

            return
        }
        
        updateProgress(success: true, progress: 0.0, message: "Getting Hub Information".localized())
        
        // Update in the way appropriate for the connection type
        if let connection = connection as? VeeaHubConnection {
            Log.tag(tag: tag, message: "Getting new data from \(connection.hubName ?? connection.ssid )")
            getDataModelFromLocalHub(connection: connection)
        }
        
        if let connection = connection as?  MasConnection {
            Log.tag(tag: tag, message: "Getting new data from MAS")
            getDataModelFromMasApi(connection: connection)
        }
    }
    
    fileprivate func getDataModelsForScan(connection: HubConnectionDefinition) {
        if snapShotInUse {
            // Update with the snapshot detail
            updateDataModelsFromSnapshots()
            self.updateCompletedSucessfully(message: "Success".localized())
            
            return
        }
        
        updateProgress(success: true, progress: 0.0, message: "Getting Hub Information".localized())
        
        // Update in the way appropriate for the connection type
        if let connection = connection as? VeeaHubConnection {
            Log.tag(tag: tag, message: "Getting new data from \(connection.hubName ?? connection.ssid )")
            getDataModelFromLocalHub(connection: connection)
        }
        
        if let connection = connection as?  MasConnection {
            Log.tag(tag: tag, message: "Getting new data from MAS")
            getDataModelFromMasApiForScan(connection: connection)
        }
    }
}

// MARK: - Node AP Information
extension HubDataModel {

    var nodeApNamesAll: [String] {
        get {
            let ghz2 = nodeApNames2Ghz
            let ghz5 = nodeApNames5Ghz
            
            return ghz2 + ghz5
        }
    }
    
    var nodeApNames2Ghz: [String] {
        get {
            guard baseDataModel?.nodeAPConfig != nil, let aps = baseDataModel?.nodeAPConfig?.aps2ghz else {
                return [""]
            }
            
            return aps.map { $0.ssid }
        }
    }
    
    var nodeApNames5Ghz: [String] {
        get {
            guard baseDataModel?.nodeAPConfig != nil, let aps = baseDataModel?.nodeAPConfig?.aps5ghz else {
                return [""]
            }
            
            return aps.map { $0.ssid }
        }
    }    
}

// MARK: - Mesh AP Information
extension HubDataModel {
    
    var meshApNamesAll: [String] {
        get {
            let ghz2 = meshApNames2Ghz
            let ghz5 = meshApNames5Ghz
            
            return ghz2 + ghz5
        }
    }
    
    var meshApNames2Ghz: [String] {
        get {
            guard baseDataModel?.meshAPConfig != nil, let aps = baseDataModel?.meshAPConfig?.aps2ghz else {
                return [""]
            }
            
            return aps.map { $0.ssid }
        }
    }
    
    var meshApNames5Ghz: [String] {
        get {
            guard baseDataModel?.meshAPConfig != nil, let aps = baseDataModel?.meshAPConfig?.aps5ghz else {
                return [""]
            }
            
            return aps.map { $0.ssid }
        }
    }
    
    private func updateProgress(success: Bool, progress: Float?, message: String?) {
        guard let progressClosure = progressClosure else { return }
        DispatchQueue.main.async {
            if success {
                if let progress = progress {
                    self.delegate?.updateDidProgress(progress: progress, message: message)
                }
            }
            
            progressClosure(success, progress, message)
        }
    }
}

// MARK: - Cellular
extension HubDataModel {
    public func hubHasCellular() -> Bool {
        guard let cellular = baseDataModel?.nodeCapabilitiesConfig?.isCellularAvailable else {
            return false
        }
        
        return cellular
    }
    
    public func hubHasSdWan() -> Bool {
        guard (optionalAppDetails?.cellularDataStatsConfig) != nil else {
            return false
        }
        
        return true
    }
    
    public func cellularDataUsedInPeriod() -> UInt64 {
        guard let cellData = optionalAppDetails?.cellularDataStatsConfig else {
            return 0
        }
        
        return cellData.bytes_recv_current_month
    }
    
    public func showCellularIPAddress() -> Bool {
        guard let cellularIP = baseDataModel?.nodeCapabilitiesConfig?.showCellularIPAddress else {
            return false
        }
        
        return cellularIP
    }
    
    public func showWifiIPAddress() -> Bool {
        guard let wifiIP = baseDataModel?.nodeCapabilitiesConfig?.showWifiIPAddress else {
            return false
        }
        
        return wifiIP
    }
    
    public func hasCellularIpv4AddrAndWifiIpv4Addr() -> Bool {
        if showCellularIPAddress() && showWifiIPAddress() {
            return true
        }
        
        return false
    }
    
    public func getCellularIPAddressValue() -> String {
        guard let cellularIPaddress = baseDataModel?.nodeStatusConfig?.cellular_ipv4_addr else {
            return ""
        }
        
        return cellularIPaddress
    }
    
    public func getWifiIPAddressValue() -> String {
        guard let cellularIPaddress = baseDataModel?.nodeStatusConfig?.wifi_ipv4_addr else {
            return ""
        }
        
        return cellularIPaddress
    }
    
    public func getEthernetIPAddressValue() -> String {
        guard let ethernetIPaddress = baseDataModel?.nodeStatusConfig?.ethernet_ipv4_addr else {
            return ""
        }
        
        return ethernetIPaddress
    }
    
    public func hasVmeshLockedFromVmeshLocalControl() -> Bool {
        guard let vmeshLocal_control = baseDataModel?.vmeshConfig?.vmesh_local_control else {
            return false
        }
        
        if vmeshLocal_control.lowercased() == "locked".lowercased() {
            return true
        }
        
        return false
    }
    
}
