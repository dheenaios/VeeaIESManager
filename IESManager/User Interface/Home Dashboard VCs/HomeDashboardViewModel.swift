//
//  HomeDashboardViewModel.swift
//  IESManager
//
//  Created by Richard Stockdale on 16/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import Foundation
import SharedBackendNetworking

class HomeDashboardViewModel: HomeUserBaseViewModel {
    
    enum MeshState: Int {
        case gettingState = 0
        case healthy = 1
        case notAvailableOnMas = 2
        case enrollingHub = 3
        case enrollmentFailed = 4
    }
    
    private let loader = HomeDashboardLoader()
    private let allDashboardItems: [HomeDashboardItem]
    private var timer: Timer?
    private var loadingDataModel = false // Catch and stop repeated calls for model update
    private let widgetDeviceManager = DeviceOptionsManager()
    
    //====================================================
    // PUBLIC VARS

    var mesh: VHMesh? {
        return meshes.first
    }
    
    var deviceViewModels: [NodeTableCellModel]? {
        guard let cellViewModels = meshDetailViewModel?.cellViewModels else {
            return nil
        }
        
        return cellViewModels
    }
    
    var menDataLoaded: Bool {
        guard HubDataModel.shared.baseDataModel != nil else {
            return false
        }

        return !HubDataModel.shared.isMN
    }
    
    let leaseInfo = HostLeaseInfo()
    
    var headerConfig: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig {
        let firstName = UserSessionManager.shared.currentUser?.firstName ?? ""
        
        // MESH STATE
        var status: HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig.HeaderState = .healthy
        
        if isADevicePreparing {
            status = .isPreparing
        }
        else if isADeviceInError {
            status = .inError
        }
        else if !menIsConnectedToMas {
            status = .notAvailable
        }

        var cellular = CellularStatusAndStrength.noCellularSupport
        if let lastStats = lastStats {
            cellular = signalStrengthBars(stats: lastStats)
        }
        
        var hosts = 0
        if let leases = leaseInfo.leases?.numberOfLeases {
            hosts = leases
        }
        
        let config = HomeDashboardHeaderViewModel.HomeDashboardHeaderConfig(cellular: cellular,
                                                                            headerState: status,
                                                                            usersName: firstName,
                                                                            numberOfHubs: numberOfDevices,
                                                                            numberOfHosts: hosts,
                                                                            networkMode: lastStats?.network_mode)
        return config
    }
    
    var numberOfMeshes: Int {
        return meshes.count
    }
    
    var numberOfDevices: Int {
        var i = 0
        guard let mesh = meshes.first else {
            return i
        }
        
        if let devices = mesh.devices {
            i = i + devices.count
        }
        
        return i
    }
    
    //====================================================
    
    private var lastStats: CellularStats?
    private var meshes: [VHMesh]
    private let groupId: String
    
    private(set) var meshState: MeshState = .gettingState {
        didSet {
            if oldValue != meshState {
                informObserversOfChange(type: .dataModelUpdated)
            }
        }
    }
    
    private var isADevicePreparing: Bool {
        guard let deviceViewModels = deviceViewModels else { return false }
        
        for device in deviceViewModels {
            if device.isPreparing { return true }
        }
        
        return false
    }
    
    private var isADeviceInError: Bool {
        guard let deviceViewModels = deviceViewModels else { return false }
        
        
        for device in deviceViewModels {
            if device.healthState.data == .errors { return true }
        }
        
        return false
    }

    var menIsConnectedToMas: Bool {
        return meshState != .notAvailableOnMas
    }
    
    // Use the existing enterprise mesh detail view model to give us the info we need
    private(set) var meshDetailViewModel: MeshDetailViewModel?
    
    private func getMeshDetails() {
        guard InternetConnectionMonitor.shared.connectivityStatus != .Disconnected,
              !meshes.isEmpty else {
            return
        }

        // Use the existing VM to get mesh details
        self.meshDetailViewModel = MeshDetailViewModel(groupId: self.groupId,
                                                       meshes: self.meshes,
                                                       selectedPosition: 0,
                                                       delegate: self)
    }
    
    private func getUserDetails() {
        AuthorisationManager.shared.getUserInfo { completed in }

        // Cache details of devices on the mesh for the widget
        widgetDeviceManager.getDevices { nodes, error  in
            if let error = error {
                Logger.log(tag: "HomeDashboardViewModel", message: "Widget device cache update error: \(error)")
                return
            }

            Logger.log(tag: "HomeDashboardViewModel", message: "Widget device cache was updated")
        }

    }
    
    init(meshes: [VHMesh],
         for groupId: String) {
        self.meshes = meshes
        self.groupId = groupId
        self.allDashboardItems = loader.dashboardItems

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(HomeDashboardViewModel.reloadMen),
                                               name: Notification.Name.updateMeshes,
                                               object: nil)

        doFullUpdate()
    }
}

// MARK: - Updating
extension HomeDashboardViewModel {

    // Blanks the hub datamodel and reloads the men from scratch
    @objc
    func reloadMen() {
        HubDataModel.shared.nilAllDataMembers()
        doFullUpdate()
    }


    /// Get everything from the MAS
    private func doFullUpdate() {
        guard InternetConnectionMonitor.shared.connectivityStatus != .Disconnected,
              !meshes.isEmpty else {
            return
        }

        self.getMeshDetails()
        self.getUserDetails()
        self.getMasDataModel()

        self.getLeaseInfo()
    }


    /// Get MeshDetails, User Details, Cellular and lease info
    private func doPartialUpdate() {
        guard InternetConnectionMonitor.shared.connectivityStatus != .Disconnected,
              !meshes.isEmpty else {
            return
        }

        self.getMeshDetails()
        self.getUserDetails()
        self.getCellularStats()
        self.getLeaseInfo()
    }

    func startTimer() {
        if timer != nil { return }

        self.timer = Timer.scheduledTimer(withTimeInterval: 60.0,
                                          repeats: true,
                                          block: { timer in
            self.doPartialUpdate()
        })

        doFullUpdate()
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Mesh state updating
extension HomeDashboardViewModel {
    private func updateMeshState() {
        
        var currentState: MeshState = .gettingState
        if let cellViewModels = meshDetailViewModel?.cellViewModels {
            currentState = .healthy
            
            for model in cellViewModels {
                if model.isPreparing {
                    let new: MeshState = .enrollingHub
                    if new.rawValue > currentState.rawValue {
                        currentState = new
                    }
                }
                else if model.isPreparingFailed {
                    let new: MeshState = .enrollmentFailed
                    if new.rawValue > currentState.rawValue {
                        currentState = new
                    }
                }
                else if !model.isAvailableOnMas.data && model.device.isMEN! {
                    currentState = .notAvailableOnMas
                }
                else {
                    // TODO: What other states exsit
                }
            }
        }
        
        meshState = currentState
    }
}

// MARK: - Cellular Data

extension HomeDashboardViewModel {
    private func signalStrengthBars(stats: CellularStats) -> CellularStatusAndStrength {
        guard let base = HubDataModel.shared.baseDataModel else {
            return .noCellularSupport
        }
        
        if !(base.nodeCapabilitiesConfig?.isCellularAvailable ?? false) {
            return .noCellularSupport
        }

        if stats.network_operator.isEmpty && stats.current_connect_time.isEmpty {
            return .noCellularSupport
        }

        // Check if they're subscribed
        if HubDataModel.shared.optionalAppDetails?.cellularDataStatsConfig == nil {
            return .noCellularSubscription
        }
        
        let bars =  CellularStrengthToBars.convert(strengthPercentage: stats.signal_level)
        
        if bars == 1 { return CellularStatusAndStrength.bar1 }
        else if bars == 2 { return CellularStatusAndStrength.bar2 }
        else if bars == 3 { return CellularStatusAndStrength.bar3 }
        else if bars == 4 { return CellularStatusAndStrength.bar4 }
        else if bars == 5 { return CellularStatusAndStrength.bar5 }
        else { return CellularStatusAndStrength.bar0 }
    }
    
    private func getCellularStats() {
        guard let hasCellular = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig?.isCellularAvailable,
        let connection = masConnection else { return }
        if !hasCellular { return }
        
        ApiFactory.api.getCellularStats(connection: connection) { [weak self] (cellularStats, error) in
            if let stats = cellularStats {
                guard let ls = self?.lastStats else {
                    self?.lastStats = stats
                    self?.informObserversOfChange(type: .dataModelUpdated)
                    return
                }
                
                let newBars = self?.signalStrengthBars(stats: stats)
                let oldBars = self?.signalStrengthBars(stats: ls)
                
                self?.lastStats = stats
                
                if newBars != oldBars {
                    self?.informObserversOfChange(type: .dataModelUpdated)
                }
            }
        }
    }
}

// MARK: - Get capabilities
extension HomeDashboardViewModel {
    private func getMasDataModel() {
        // Get the MENs Capabilities
        guard let men = meshes.first!.devices!.first(where: {$0.isMEN == true}) else {
            return
        }

        if loadingDataModel { return }
        loadingDataModel = true
        
        MasConnectionFactory.makeMasConectionFor(nodeSerial: men.id) { success, connection in
            if !success {
                self.loadingDataModel = false
                self.informObserversOfChange(type: .noChange)
                return
            }

            guard let connection = connection else {
                self.loadingDataModel = false
                return
            }

            HubDataModel.shared.connectedVeeaHub = connection
            self.makeDataModelCall(connection: connection)
        }
    }


    
    private func makeDataModelCall(connection: MasConnection) {
        HubDataModel.shared.updateConfigInfo(nilAllMembersBeforeCall: false) { success, progress, message in
            self.loadingDataModel = false
            self.getCellularStats()
            self.informObserversOfChange(type: .dataModelUpdated)
        }
    }
}

extension HomeDashboardViewModel: MeshDetailViewModelDelegate {
    func didUpdateMeshes(meshes: [VHMesh]) {
        self.meshes = meshes
        updateMeshState()
    }
}

extension HomeDashboardViewModel {
    var dashboardItems: [HomeDashboardItem] {
        var filteredItems = [HomeDashboardItem]()
        for item in allDashboardItems {
            if let i = addItemForCurrentMesh(item: item) {
                filteredItems.append(i)
            }
        }
        
        return filteredItems
    }
    
    private func addItemForCurrentMesh(item: HomeDashboardItem) -> HomeDashboardItem? {
        guard let capabilities = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig else {
            return item
        }
        
        if item.destinationId == "CellularUsage" {

            if !capabilities.isCellularAvailable { return nil }

            var itemMod = item
            itemMod.faded = HubDataModel.shared.optionalAppDetails?.cellularDataStatsConfig == nil

            return itemMod
        }
        
        return item
    }
}

// MARK: - Get Host Lease information
extension HomeDashboardViewModel {
    fileprivate func getLeaseInfo() {
        leaseInfo.leasesForGroupAndMesh {
            self.informObserversOfChange(type: .dataModelUpdated)
        }
    }
}
