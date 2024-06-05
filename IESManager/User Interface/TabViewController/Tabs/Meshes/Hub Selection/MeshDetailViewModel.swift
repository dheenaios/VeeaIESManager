//
//  MeshDetailViewModel.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 4/10/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
import SharedBackendNetworking

protocol MeshDetailViewModelDelegate: AnyObject {
    func didUpdateMeshes(meshes: [VHMesh])
    func shouldUpdateGroups()
}

extension MeshDetailViewModelDelegate {
    func shouldUpdateGroups() {
        // Default implementation to allow this method to be optional
    }
}

final class MeshDetailViewModel: NSObject {
    
    weak var hostVC: MeshDetailViewController?
    private let TAG = "MeshDetailViewModel"
    private var dataFetchTimer: Timer!
    private var oldProcessingVeeaHubs = [EnrollStatusModel]()
    private var meshes = [VHMesh]()
    private var statusOfDevice :String?
    private var devices = [VHMeshNode]()
    private var selectedPosition = 0
    weak var delegate: MeshDetailViewModelDelegate?
    private(set) var groupId : String!
    private(set) var hubInfo: [HubInfo]?
    private let updateProgressController = UpdateProgressController()
    var searchTerm = ""
    private var lastDNSLookup: Date?
    
    private(set) var healthCheckUpAPIResponse: MeshStatusResponse?
    
    public var connectionInfo: ConnectionInfo!
    public var neededRebootCountVar = 0


    var viewIsVisible: Bool = true {
        didSet {
            if !viewIsVisible && dataFetchTimer != nil {
                dataFetchTimer.invalidate()
            }
        }
    }
    
    public var meshName: String {
        return meshes[selectedPosition].name
    }
    
    public var meshUUID: String {
        return meshes[selectedPosition].id
    }
    
    public var menUnitSerial: String? {
        let mesh = meshes[selectedPosition]
        if let devices = mesh.devices {
            for device in devices {
                if device.isMEN ?? false {
                    return device.id
                }
            }
        }
        
        return nil
    }
    
    public var dnsLookUp: DnsLookupManager? {
        didSet {
            if let _ = self.dnsLookUp {
                self.updateCellModels()
            }
        }
    }
    
    private(set) var mesh: VHMesh! {
        didSet {
            if let _ = self.mesh {
                self.updateCellModels()
            }
        }
    }
    private(set) var devicesForUpdatingPurpose: [VHMeshNode]! {
        didSet {
            if let _ = self.devicesForUpdatingPurpose {
                self.updateCellModels()
            }
        }
    }
    
    var cellViewModels: [NodeTableCellModel] = []
    
    var isBluetoothEnabled = Observable<Bool>(true)
    var networkAvailable = Observable<VKReachabilityManagerStatus>(.connected)
    
    var updatePackages: [PackagesWithUpdates]?

    private override init() { }
    
    convenience init(groupId: String,
                     meshes: [VHMesh],
                     selectedPosition:Int,
                     delegate: MeshDetailViewModelDelegate? = nil) {
        self.init()
        self.groupId = groupId
        self.meshes = meshes
        self.selectedPosition = selectedPosition
        self.setAndSortMesh(mesh: meshes[selectedPosition])
        self.updateCellModels()

        Task { await self.dispatchDataFetcher() }
        self.setupDeviceScanner()
        self.delegate = delegate
        self.checkIfBLEnabled()
        self.getMasHubHealth()
        self.getMeshHealthStatusAPI()
        self.getDeviceHealth()
    }
    
    private func setAndSortMesh(mesh: VHMesh) {
        self.mesh = mesh
        
        var mens = [VHMeshNode]() // There will be only one
        var mns = [VHMeshNode]() // There may be many
        
        if let hubs = mesh.devices {
            for hub in hubs {
                if let isMen = hub.isMEN {
                    if isMen {
                        mens.append(hub)
                        continue
                    }
                }
                
                mns.append(hub)
            }
        }
        
        // Put MNs into name order
        
        var allNodes = [VHMeshNode]()
        allNodes.append(contentsOf: mens)
        allNodes.append(contentsOf: mns.sorted(by: { node1, node2 in
            node1.name.lowercased() < node2.name.lowercased()
        }))
        
        self.meshes[self.selectedPosition].devices = allNodes.clone()
        self.devices = allNodes.clone()
        //VHM-1689 - CHECKING THE DEVICE COUNT AND CELLVIEWMODELS COUNT IF ANY VEEAHUB NEWLY ADDED/REMOVED
        if devices.count != self.cellViewModels.count {
            cellViewModels = []
            self.devicesForUpdatingPurpose = self.devices.clone()
        }
        self.mesh.devices = allNodes.clone()
    }
    
    func setupDeviceScanner() {
        guard let beacon = mesh.beacon else {
            Logger.log(tag: TAG.self, message: "No beacon attached to mesh \(mesh.name ?? "Unknown Mesh")")
            return

        }

        HubBeaconScanner.shared.startScan(for: beacon)
        HubBeaconScanner.shared.delegate = self

        if HubBeaconScanner.shared.isIesCacheFresh {
            let cache = HubBeaconScanner.shared.iesCache

            for ies in cache {
                updateNodeSignal(with: ies)
            }
        }
    }
    
    func cleanUp() {
        self.dataFetchTimer?.invalidate()
        HubBeaconScanner.shared.stopScan()
        HubBeaconScanner.shared.delegate = nil
        self.mesh = nil
        self.delegate = nil
        self.stopBLScanner()
    }
    
    deinit {
        cleanUp()
    }
    
    func getNumberOfSections() -> Int {
        if !searchTerm.isEmpty {
            return 1 // One section for the search results
        }
        
        if mnModels.isEmpty { return 1 }
        return 2
    }
    
    func getNumberOfRows(for section: Int) -> Int {
        if section == 0 {
            return menModels.count
        }
        return mnModels.count
    }
    
    func getViewModel(at indexPath: IndexPath) -> NodeTableCellModel? {
        if !searchTerm.isEmpty {
            return searchResultModels()[indexPath.row]
        }
        
        if indexPath.section == 0 { return menModels.at(index: indexPath.row)}
        else { return mnModels.at(index: indexPath.row) }
    }
    
    var men: NodeTableCellModel? {
        if menModels.isEmpty { return nil }
        return menModels.first
    }
    
    private var menModels: [NodeTableCellModel] {
        if !searchTerm.isEmpty {
            return searchResultModels()
        }
        let vms = cellViewModels.filter { cvm in
            cvm.device.isMEN ?? false
        }
        
        return vms
    }
    
    private var mnModels: [NodeTableCellModel] {
        if !searchTerm.isEmpty {
            return [NodeTableCellModel]()
        }
        
        let sortedCellViewModels = cellViewModels.sorted(by: { $0.device.name.lowercased() < $1.device.name.lowercased() })
        
        let vms = sortedCellViewModels.filter { cvm in
            !(cvm.device.isMEN ?? false)
        }
        
        return vms
    }
    
    private func searchResultModels() -> [NodeTableCellModel] {
        let vms = cellViewModels.filter { cvm in
            cvm.titleText.data.lowercased().contains(searchTerm)
        }
        
        return vms
    }

    /// TableView header title
    func titleForHeader(in section: Int) -> String? {
        if !searchTerm.isEmpty {
            return "Search Results".localized()
        }
        
        if section == 0 {
            return "Mesh Edge Node".localized()
        }
        return "Other VeeaHubs on this Mesh" + "(\(mnModels.count))"
    }
    
    func showEnrollingInfoIfNeeded(at indexPath: IndexPath) -> (vc: VUIViewController, pushView: Bool)? {
        HubIpOverride.shouldOverrideHubIp = false
        
        guard let vm = getViewModel(at: indexPath) else {
            Logger.log(tag: self.TAG, message: "showEnrollingInfoIfNeeded - index is out of range")
            
            Crashlytics.crashlytics().log("showEnrollingInfoIfNeeded - index is out of range")
            let e = NSError.init(domain: "Non fatal out of range",
                                 code: 1000,
                                 userInfo: nil)
            Crashlytics.crashlytics().record(error: e)

            return nil
        }
        if vm.isPreparing || vm.isPreparingFailed {
            return (EnrollmentStatusViewController(for: vm.device, mesh: self.mesh, connectionInfo: self.connectionInfo), true)
        }

        return nil
    }
    
    public func getConnectionInfo(indexPath: IndexPath) -> ConnectionInfo? {
        guard let devices = self.mesh.devices else {
            return nil
        }
        
        guard let vm = getViewModel(at: indexPath) else {
            Logger.log(tag: self.TAG, message: "getConnectionInfo - index is out of range")
            
            Crashlytics.crashlytics().log("getConnectionInfo - index is out of range")
            let e = NSError.init(domain: "Non fatal out of range",
                                 code: 1000,
                                 userInfo: nil)
            Crashlytics.crashlytics().record(error: e)
            return nil
        }
        
        let notAvailable = vm.signalStrength.data == .noSignal &&
        !vm.isAvailableOnLan.data &&
        !vm.isAvailableOnMas.data
        
        let deviceIndex = indexPath.section == 1 ? indexPath.row+1 : indexPath.row

        guard let node = devices.at(index: deviceIndex) else {
            return nil
        }
        
        var connectionInfo = ConnectionInfo.init(selectedMesh: mesh,
                                                 selectedMeshNode: node,
                                                 veeaHub: vm.veeaHub,
                                                 isAvailableForConnection: !notAvailable)
        
        if let message = testerDoesNotAllowMessage(vm: vm) {
            connectionInfo.availableButNotAllowedReason = message
        }
        
        return connectionInfo
    }

    public func refreshConnectionInfo(connectionInfo: ConnectionInfo) -> ConnectionInfo {
        let sMeshNode = connectionInfo.selectedMeshNode
        
        var vm: NodeTableCellModel?
        for cvm in cellViewModels {
            if cvm.id == sMeshNode.id {
                vm = cvm
                break
            }
        }
        
        if let vm = vm {
            let notAvailable = vm.signalStrength.data == .noSignal &&
            !vm.isAvailableOnLan.data &&
            !vm.isAvailableOnMas.data

            let connectionInfo = ConnectionInfo.init(selectedMesh: mesh,
                                                     selectedMeshNode: sMeshNode,
                                                     veeaHub: vm.veeaHub,
                                                     isAvailableForConnection: !notAvailable)
            
            return connectionInfo
        }
        
        return connectionInfo
    }
    
    private func testerDoesNotAllowMessage(vm: NodeTableCellModel) -> String? {
        // Only available on internal builds
        if !BackEndEnvironment.internalBuild {
            return nil
        }
        
        let allowedRoutes = TesterDefinedConnectionRoutes.selectedRoutes
        if  vm.signalStrength.data != .noSignal && allowedRoutes.contains(.ap) {
            return nil
        }
        if vm.isAvailableOnLan.data && allowedRoutes.contains(.lan){
            return nil
        }
        if vm.isAvailableOnMas.data && allowedRoutes.contains(.hubAvailableOnMas){
            return nil
        }
        
        return "A connection route is available but tester settings do not allow this to be used."
    }
    
    // MARK: - Private
    private func updateCellModels() {
        //print("Called update cell models")
        
        var deviceIndex = 0
        var cellModelIndex = 0
        
        // Update existing model
        while deviceIndex < devices.count && cellModelIndex < cellViewModels.count {
            if devices[deviceIndex].id == cellViewModels[cellModelIndex].id {
                let node = devices[deviceIndex]
                let dnsAddress = getDnsRecord(for: node)
                let model = cellViewModels[cellModelIndex]
                
                model.veeaHub.hubDnsIp = dnsAddress
                
                model.update(with: node)
            }
            
            deviceIndex += 1
            cellModelIndex += 1
        }
        
        // Add any that do not exist
        while deviceIndex < devices.count {
            let node = devices[deviceIndex]
            cellViewModels.append(NodeTableCellModel(device: node))
            deviceIndex += 1
        }
        
        hostVC?.configureHealthPill()
    }
    
    private func fetchProcessingVeeaHubs() {
        EnrollmentService.getProcessingVeeaHubsOfForGroup(groupId : self.groupId, success: { (veeahubsInProgress) in
            var currentlyRemovedVeeaHubs = [EnrollStatusModel]()
            currentlyRemovedVeeaHubs = self.oldProcessingVeeaHubs.filter { !veeahubsInProgress.contains($0) }
            
            if currentlyRemovedVeeaHubs.count > 0 {
                for veeahub in currentlyRemovedVeeaHubs {
                    if let _ = self.mesh, var devices = self.mesh.devices, let deviceIndex = devices.firstIndex(where: {$0.id == veeahub.device.id}) {
                        devices[deviceIndex].progress = 0
                        devices[deviceIndex].status = .ready
                        
                        if self.meshes.at(index: self.selectedPosition) != nil {
                            self.meshes[self.selectedPosition].devices = devices
                        }
                        else { self.showError() }
                    }
                }
            }
            
            for veeahub in veeahubsInProgress {
                if let _ = self.mesh, var devices = self.mesh.devices, let deviceIndex = devices.firstIndex(where: {$0.id == veeahub.device.id}) {
                    devices[deviceIndex].progress = veeahub.percentage
                    if veeahub.percentage != -1 {
                        // -1 represent error
                    } else {
                        if devices.at(index: deviceIndex) != nil {
                            devices[deviceIndex].status = .error
                            
                            if (devices[deviceIndex].error == nil) {
                                devices[deviceIndex].error = VHMeshNode.Error(code: 500, message: "Something went wrong.")
                            }
                        }
                        else { self.showError() }
                    }
                    
                    if self.meshes.at(index: self.selectedPosition) != nil {
                        self.meshes[self.selectedPosition].devices = devices
                    }
                    else { self.showError() }
                }
            }
            
            self.oldProcessingVeeaHubs = veeahubsInProgress
            
            DispatchQueue.main.async {
                self.doDnsLookUp()
                
                // Update the meshes data displayed in other places here
                self.delegate?.didUpdateMeshes(meshes: self.meshes)
                
                if (self.meshes.count > self.selectedPosition) {
                    self.mesh = self.meshes[self.selectedPosition]
                }
                else {
                    // Show a message. Then pop
                    self.showError()
                }
            }
        }) { (error) in
            VKLog(error)
        }
    }
    
    private func doDnsLookUp() {
        guard let lastDNSLookup = lastDNSLookup else {
            self.dnsLookUp?.updateMeshesAndNodes(meshes: self.meshes)
            lastDNSLookup = Date()
            return
        }

        if lastDNSLookup.inLast(seconds: 5) {
            return
        }
        
        self.lastDNSLookup = Date()
        self.dnsLookUp?.updateMeshesAndNodes(meshes: self.meshes)
    }
    
    private func showError() {
        if let vc = self.hostVC {
            let alert = UIAlertController(title: "Error",
                                          message: "There was an error getting information about this mesh. Please try again later".localized(),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized(),
                                          style: .default,
                                          handler: { alert in
                vc.navigationController?.popViewController(animated: true)
            }))
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    public func restartTimer() {
        if dataFetchTimer == nil || !dataFetchTimer.isValid {
            Task { await self.dispatchDataFetcher() }
        }
    }

    /// Resets the device details and reloads
    func removeModel(model: NodeTableCellModel) {
        mesh.devices?.removeAll { d in
            model.id == d.id
        }

        devices.removeAll { d in
            model.id == d.id
        }

        cellViewModels.removeAll { m in
            model.id == m.id
        }

        self.delegate?.didUpdateMeshes(meshes: meshes)
    }

    // this refetches data every 20 seconds from the server
    // this is the only way until we move to using sockets
    func dispatchDataFetcher() async {
        let result = await EnrollmentService.getOwnerConfig(groupId: self.groupId)
        if let error = result.1 {
            VKLog(error)
            return
        }

        guard let meshes = result.0 else { return }

        // Sort the meshes alphabetically to match the order of selection from the meshes view controller
        let sortedMeshes = meshes.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })

        await MainActor.run {
            self.meshes = sortedMeshes
            self.doDnsLookUp()
            self.delegate?.didUpdateMeshes(meshes: sortedMeshes)
            for item in sortedMeshes {
                if item.id == self.mesh.id {
                    self.mesh = item
                }
            }

            // Update the mesh info with the update mesh info
            let selectedPosition = self.selectedPosition
            if let mesh = sortedMeshes.at(index: selectedPosition) {
                self.setAndSortMesh(mesh: mesh)

            }
            
            if self.dataFetchTimer != nil {
                self.dataFetchTimer.invalidate()
            }

            self.dataFetchTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] (timer) in
                self?.fetchProcessingVeeaHubs()
                self?.getMasHubHealth()
                self?.getMeshHealthStatusAPI()
                self?.getDeviceHealth()
                self?.getUpdateInfo()
            }
            self.dataFetchTimer.fire()
        }
    }

    /// Updates the mesh name
    /// - Parameter newName: The new mesh name
    /// - Returns: An optional string describing an error, returned if there is an issue
    func updateMeshName(newName: String) async -> String? {
        let nameCheckResult = await EnrollmentService.checkMeshName(groupId: groupId, name: newName)
        if !nameCheckResult.0 { // If in error
            return nameCheckResult.1 ?? "Unknown(0)"
        }

        // Send
        let renameResult = await MeshAndHubRenameManager.setMeshName(newName, for: meshUUID )
        if !renameResult.0 { // If in error
            return renameResult.1 ?? "Unknown(1)"
        }

        await dispatchDataFetcher()
        delegate?.shouldUpdateGroups()

        return nil
    }
    
    fileprivate func updateNodeSignal(with node: VeeaHubConnection) {
        for device in self.cellViewModels {
            if node.ssid == device.getSSID() {
                if node.hasDefinedConnectionRoute {
                    device.updateVeeaHubDetails(updatedHub: node)
                } else {
                    device.signalBeaconLost()
                }
            }
        }
        
        updateCellModels()
    }
    
    fileprivate func didLooseNode(node: VeeaHubConnection) {
        for device in self.cellViewModels {
            if node.ssid == device.getSSID() {
                device.signalBeaconLost()
            }
        }
    }
}

extension MeshDetailViewModel: HubBeaconScannerDelegate {
    func didFindIes(_ device: VeeaHubConnection) {
        self.updateNodeSignal(with: device)
        Logger.log(tag: "MeshDetailViewModel", message: "Found VeeaHub \(device.hubName ?? "Unknown") via BlueTooth")
    }
    
    func didUpdateIes(_ device: VeeaHubConnection) {
        self.updateNodeSignal(with: device)
        Logger.log(tag: "MeshDetailViewModel", message: "Updated VeeaHub \(device.hubName ?? "Unknown") via BlueTooth")
    }
    
    func didLooseIes(_ device: VeeaHubConnection) {
        self.didLooseNode(node: device)
        Logger.log(tag: "MeshDetailViewModel", message: "Lost VeeaHub \(device.hubName ?? "Unknown") via BlueTooth")
    }
}

// MARK: - MAS Mesh and Hub health check
extension MeshDetailViewModel {

    var meshHealth: MeshNodeHealthState {
        if self.healthCheckUpAPIResponse != nil {
            return MeshNodeHealthState.getStateFromStatus(status: self.healthCheckUpAPIResponse?.response.status ?? "")
        }
        return .unknown
    }
    fileprivate func getMeshHealthStatusAPI() {
        guard let token = AuthorisationManager.shared.formattedAuthToken else {
            return
        }
        let baseUrl = BackEndEnvironment.masApiBaseUrl
        MasConnectionFactory.getMeshHealthInfoFromMas(meshId: self.mesh.id, apiToken: token, baseUrl: baseUrl) { (response, error) in
            self.healthCheckUpAPIResponse = response
            var needsRebootCount = 0
            if self.cellViewModels.count == 0 {
                self.hostVC?.configureHealthPill()
            }
            else {
                for model in self.cellViewModels {
                    for hub in self.hubInfo ?? [] {
                        if model.veeaHub.hubId == hub.UnitSerial {
                            if hub.NodeState.RebootRequired { needsRebootCount += 1 }
                        }
                    }
                }
                self.neededRebootCountVar = needsRebootCount
                if (needsRebootCount != 0) {
                    self.hostVC?.configureHealthPillWithRestart(restartHubsCount: needsRebootCount)
                }
                else{
                    self.hostVC?.configureHealthPill()
                }
            }
        }
    }
   
    fileprivate func getDeviceHealth() {
        guard let devices = mesh.devices else {
            return
        }
        if devices.isEmpty { return }
        
        for model in self.cellViewModels {
            var found = false
            guard let token = AuthorisationManager.shared.formattedAuthToken else {
                return
            }
            let baseUrl = BackEndEnvironment.masApiBaseUrl
            MasConnectionFactory.getDeviceHealthInfoFromMas(deviceId: model.device.id, apiToken: token, baseUrl: baseUrl) { (response, error) in
                self.healthCheckUpAPIResponse = response
                if error == nil {
                    for hub in self.hubInfo ?? [] {
                        if model.veeaHub.hubId == hub.UnitSerial {
                            if UserSettings.connectViaMasIfHubNotConnected{
                                model.isAvailableOnMas.data = true
                            }else{
                                model.isAvailableOnMas.data = hub.Connected
                            }
                            model.healthState.data = MeshNodeHealthState.getStateFromStatus(status: self.healthCheckUpAPIResponse?.response.status ?? "offline")
                            model.titleText.data = model.device.name
                            model.updateState()
                            found = true
                        }
                    }
                    if !found {
                    // If get to here, we have not found a match. That might be because the hub is installing so we get no hubInfo
                    model.healthState.data = MeshNodeHealthState.getStateFromStatus(status: self.healthCheckUpAPIResponse?.response.status ?? "offline")
                    model.titleText.data = model.veeaHub.hubId!
                    model.updateState()
                    }
                }
            }
        }
}
    
    fileprivate func getMasHubHealth() {
        guard let devices = mesh.devices, let token = AuthorisationManager.shared.formattedAuthToken else {
            return
        }
        
        if devices.isEmpty { return }
        
        var ids = [String]()
        for device in devices {
            if let id = device.id {
                ids.append(id)
            }
        }
        // Get the health information
        let baseUrl = BackEndEnvironment.masApiBaseUrl
        MasConnectionFactory.getHubInfoFromMas(nodeSerials: ids,
                                               apiToken: token,
                                               baseUrl: baseUrl) { (hubs, error) in
            if (error != nil || hubs?.count == 0) {
                return
            }
            self.hubInfo = hubs
        }
    }
}

// MARK: - DNS and MDNS Lookup
extension MeshDetailViewModel {
    fileprivate func getDnsRecord(for node: VHMeshNode) -> String? {
        return getIp(of: node, fromLookUp: dnsLookUp)
    }
    
    private func getIp(of node: VHMeshNode,
                       fromLookUp lookUp: HubLookupManager?) -> String? {
        guard let nodeIpDetails = lookUp?.nodeIpDetails else {
            return nil
        }
        
        for detail in nodeIpDetails {
            if detail.nodeId == node.id {
                //print("Found IP for \(node.id ?? "Error no id") - \(detail.nodeIp ?? "Error no ip")")
                
                return detail.nodeIp
            }
        }
        
        return nil
    }
}

// MARK: - Mesh Updates
extension MeshDetailViewModel {
    /// Get details of updates in progress and updates that are available.
    /// Called when the mesh details screen loads
    func getUpdateInfo() {
        guard let meshId = mesh.id else {
            return
        }
        
        getRunningUpdateProgress(meshId: meshId)
        //getUpdatesAvailable(meshId: meshId) // Disabled see vhm 1276
    }
    
    fileprivate func getRunningUpdateProgress(meshId: String) {
        updateProgressController.getUpdateProgress(meshId: meshId) { status, error in
            guard let status = status else {
                return
            }
            
            if let error = error {
                Logger.log(tag: self.TAG, message: "Error getting update progress info: \(error.localizedDescription)")
            }
            
            self.hostVC?.showUpdateProgress(status: status)
        }
    }
    
    // Currently unused due to some issues with some update types. Do not delete. VHM 1276
    fileprivate func getUpdatesAvailable(meshId: String) {
        UpdateAvailableController.getUpdateInfo(meshId: meshId) { updates, error in
            guard let updates = updates else {
                return
            }
            
            if let error = error {
                Logger.log(tag: self.TAG, message: "Error getting update info: \(error.localizedDescription)")
            }
            
            self.updatePackages = updates
            self.hostVC?.showUpdatePill(numberOfUpdates: updates.count)
        }
    }
}

struct ConnectionInfo {
    let selectedMesh: VHMesh
    let selectedMeshNode: VHMeshNode
    let veeaHub: VeeaHubConnection
    
    
    /// Is the hub available for connection over any route?
    let isAvailableForConnection: Bool
    
    /// The hub is available by some connection routes BUT these are not allowed given the user settings
    var availableButNotAllowedReason: String?
}
