//
//  VmeshConfigViewModel.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 09/06/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


class VmeshConfigViewModel: BaseConfigViewModel {

    private var observer: ((ViewModelUpdateType?) -> Void)?

    let wlanWiredOnText = """
        Wireless networking will be disabled on VeeaHubs with a wired connection to this VeeaHub.
        Tap here for more...
        """
    let wlanWiredOffText = """
        Wireless networking will be enabled on any VeeaHubs with a wired connection to this VeeaHub.
        Tap here for more...
        """
    
    var selectedWLanOperationalOption: VmeshConfig.WanOperationalOption {
        get {
            let o = vmeshConfig.vmesh_local_control
            return VmeshConfig.WanOperationalOption.fromString(str: o)
        }
        set {
            vmeshConfig.vmesh_local_control = newValue.apiValue
            updateRelatedOptionsWhenWanOperationalOptionChanges(option: newValue)
        }
    }
    
    /// There are a number of changes to be made when the WanOperationalOption changes
    private func updateRelatedOptionsWhenWanOperationalOptionChanges(option: VmeshConfig.WanOperationalOption) {
        /*
         If MN & vmesh_local_control == join THEN WLAN vmesh_locked is false and Enable Beacon is off
         If MN & vmesh_local_control == start OR auto THEN vmesh_locked is false  and Enable Beacon is on
         If MN & vmesh_local_control == disabled THEN vmesh_locked is true.
         If MEN & vmesh_local_control == disabled THEN vmesh_locked is true
         If MEN & vmesh_local_control == start THEN WLAN vmesh_locked is false
         */
        
        if isMN {
            switch option {
            case .disabled:
                locked = true
                break
            case .join:
                locked = false
                break
            default: // Start or Auto
                locked = false
                break
            }
        }
        else {
            locked = option == .disabled
        }
    }
    
    var wLanEnabledWired: Bool {
        get {
            return !vmeshConfig.vmesh_locked_wired
        }
        set {
            vmeshConfig.vmesh_locked_wired = !newValue
        }
    }
    
    let automaticSelectionOptionString = "Auto Selection"
    let whiteListSegueId = "whiteList"
    var updatedWhiteListChannels: [Int]?

    var wdsDetails: WdsStateDetails?

    private lazy var vmeshConfig: VmeshConfig! = {
        return bdm?.vmeshConfig
    }()
    
    private lazy var nodeCapabilities: NodeCapabilities! = {
        return bdm?.nodeCapabilitiesConfig
    }()

    private lazy var meshWdsTopologyConfig: MeshWdsTopologyConfig? = {
        return odm?.meshWdsTopologyConfig
    }()
    
    override init() {
        super.init()
        
        // Set up the current channel
        if vmeshAcs {
            currentlySelectedChannelValue = automaticSelectionOptionString
        }
        else {
            currentlySelectedChannelValue = "\(channel)"
        }

        getLastReport()
    }

    private func getLastReport() {
        guard let connectedHub else { return }

        ApiFactory.api.getWdsScanReport(connection: connectedHub) { report, error in
            self.wdsDetails = WdsStateDetails(lastReport: report)
            self.informObserversOfChange(type: .dataModelUpdated)
        }
    }
    
    var ssid: String {
        get {return vmeshConfig.vmesh_ssid}
        set {vmeshConfig.vmesh_ssid = newValue}
    }
    
    var psk: String {
        get {return vmeshConfig.vmesh_psk}
        set {vmeshConfig.vmesh_psk = newValue}
    }
    
    var swarmName: String {
        get {return vmeshConfig.swarm_name}
        set {vmeshConfig.swarm_name = newValue}
    }
    
    var locked: Bool {
        get {return HubDataModel.shared.hasVmeshLockedFromVmeshLocalControl()}
        set { newValue }
    }
    
    var bw: Int {
        get {return vmeshConfig.vmesh_bandwidth}
        set {vmeshConfig.vmesh_bandwidth = newValue}
    }
    
    var bwString: String {
        get {return bandwidthString(from: vmeshConfig.vmesh_bandwidth)}
        set {vmeshConfig.vmesh_bandwidth = bandwidthInt(from: newValue)}
    }
    
    var abw: Int {
        return vmeshConfig.vmesh_bandwidth_actual
    }
    
    var transmitPwr: Int {
        get {return vmeshConfig.vmesh_power_scale}
        set {vmeshConfig.vmesh_power_scale = newValue}
    }
    
    var showVmeshBeacon: Bool {
        if !HubDataModel.shared.isMN {
            return false
        }

        return !nodeCapabilities.supportsWiredMesh && isVmeshEnabled
    }
    
    private var isVmeshEnabled: Bool {
        if nodeCapabilities.supportsWiredMesh {
            return selectedWLanOperationalOption != .disabled
        }
        
        return HubDataModel.shared.hasVmeshLockedFromVmeshLocalControl()
    }
    
    private var vmeshChannels: [Int] {
        return vmeshConfig.vmesh_wifi_channels
    }
    
    var vmeshChannelActual: Int {
        return vmeshConfig.vmesh_channel_actual
    }
    

    private let upperBandStr = "5ghz-upper"
    private let lowerBandStr = "5ghz-lower"
    var isUpperBand: Bool {
        get { vmeshConfig.vmesh_radio_name == upperBandStr }
        set { vmeshConfig.vmesh_radio_name = newValue ? upperBandStr : lowerBandStr }
    }

    var hasUpperBandChanged: Bool {
        if let name = bdm?.vmeshConfig?.vmesh_radio_name {
            if isUpperBand && name != upperBandStr || !isUpperBand && name != lowerBandStr {
                return true
            }
        }

        return false
    }
    
    
    var radioNames: [String] {
        return vmeshConfig.vmesh_radio_options
    }
    
    public var supportsVeeaHubMixedWiredWirelessDeployments: Bool {
        guard let cap = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig else {
            return false
        }
        
        return cap.supportsVeeaHubMixedWiredWirelessDeployments
    }
    
    public var supportForHideAndShowWLANEnabled: Bool {
        guard let cap = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig else {
            return false
        }
        
        return cap.supportForHideAndShowWLANEnabled
    }
    
    var showVmesh24gBandOption: Bool {
        let hasSingleBand = HubDataModel.shared
            .baseDataModel?
            .nodeCapabilitiesConfig?
            .ap2Charateristics?
            .meshRadio ?? false
        
        return hasSingleBand
    }
    
    fileprivate func bandwidthString(from: Int) -> String {
        if from == 80 {
            return "20/40/80"
            
        } else if from == 40 {
            return "20/40"
            
        } else {
            return "20"
        }
    }
    
    fileprivate func bandwidthInt(from: String) -> Int {
        // SW-3121 hack to get around the picker strings not being the same as the selection value (vmesh_bandwidth is not a string)
        if from.contains("80") {
            return 80
            
        } else if from.contains("40") {
            return 40
            
        } else {
            return 20
        }
    }
    
    // MARK: Channel Selection
    var currentlySelectedChannelValue: String?

    public var isCurrentChannelAuto: Bool {
        return currentlySelectedChannelValue == automaticSelectionOptionString
    }
    
    /// Returns the selected access channel.
    /// If its set to auto the auto string will be returned
    /// If not the selected channel will be returned
    var selectedAccessChannel: String {
        if vmeshAcs {
            return automaticSelectionOptionString
        }
        
        return "\(channel)"
    }

    var channel: Int {
        get {return vmeshConfig.vmesh_channel}
        set {vmeshConfig.vmesh_channel = newValue}
    }
    
    
    /// Hide rows if the WLAN is not enabled
    var hideAllButWLanEnabled: Bool {
        if nodeCapabilities.supportsVeeaHubMixedWiredWirelessDeployments {
            return selectedWLanOperationalOption == .disabled
        }
        else {
            return locked
        }
    }
}

// MARK: - Updating
extension VmeshConfigViewModel {
    func hasVmeshConfigChanged() -> Bool {
        guard let originalConfig = bdm?.vmeshConfig else {
            return false
        }
        
        return vmeshConfig != originalConfig
    }
    
    func updateHub(completion: @escaping Delegate) {
        guard let hub = connectedHub else {
            completion(nil, APIError.Failed(message: "No IES"))
            return
        }

        ApiFactory.api.setConfig(connection: hub, config: vmeshConfig) { (result, error) in
            completion(result, error)
        }
    }
}

// MARK: - IBSS Display
// See VHM - 540
extension VmeshConfigViewModel {
    
    var is5hgz: Bool {
        // Check if the properties exist
        guard let _ = vmeshConfig.vmesh_acs, let acsSup = nodeCapabilities.vmeshAcsSupport  else {
            return false
        }
        
        return acsSup
    }
    
    var vmeshAcs: Bool {
        get { return vmeshConfig.vmesh_acs ?? false}
        set { vmeshConfig.vmesh_acs = newValue }
    }
    
    var showExcludeDfs: Bool {
        if HubDataModel.shared.isMN {
            return false
        }

        if !is5hgz {
            return false
        }

        if isCurrentChannelAuto {
            return true
        }

        return false
    }
    
    var dfsIsOn: Bool {
        get {return vmeshConfig.vmesh_acs_exclude_dfs}
        set {vmeshConfig.vmesh_acs_exclude_dfs = newValue}
    }
    
    var canSelectChannel: Bool {
        return !isMN
    }
    
    var channelOptions: [String] {
        var channels = [String]()
        
        if is5hgz {
            channels.append(automaticSelectionOptionString)
        }
        
        for channel in vmeshChannels {
            channels.append("\(channel)")
        }
        
        return channels
    }
    
    var showChannelActual: Bool {
        if HubDataModel.shared.isMN {
            return true
        }
        
        // If MEN but ACS is off then do not show
        return vmeshAcs
    }
    
    // Including auto???
    var bandwidthOptions: [String] {
        var options = [String]()
        
        //For the vMesh, for the E09/10 we support 20, 20/40, and 20/40/80, but on the C05 for the wireless mesh we only support 20 and 20/40
        if (HubDataModel.shared.hardwareVersion == .vhc05) {
            options.append(contentsOf: ["20", "20/40"])
        } else {
            options.append(contentsOf: ["20", "20/40", "20/40/80"])
        }
        
        return options
    }
    
    var showBandwidthSelection: Bool {
        if HubDataModel.shared.isMN {
            return false
        }
        
        return true
    }
    
    var showBandwidthActual: Bool {
        return true
    }
    
    var showChannelScanOption: Bool {
        if HubDataModel.shared.isMN {
            return false
        }
        
        if is5hgz && currentlySelectedChannelValue == automaticSelectionOptionString {
            return true
        }
        
        return false
    }
    
    var showRadioSelect: Bool {
        // VHM-1548 - VHM needs to allow the MN to change the 5GHz radios high/low band setting.
        if HubDataModel.shared.isMN && !is5hgz {
            return false
        }
        
        if nodeCapabilities.radioSelect {
            if !radioNames.isEmpty && is5hgz {
                return true
            }
        }
        
        return false
    }
    
    var showAcsWhitelistOption: Bool {
        if HubDataModel.shared.isMN {
            return false
        }
        
        if vmeshAcs &&
            !vmeshWhiteListChannels.isEmpty ||
            (nodeCapabilities.vmeshDfsSupport ||
             currentlySelectedChannelValue == automaticSelectionOptionString) {
            return true
        }
        
        return false
    }
}

// MARK: - Whitelist
extension VmeshConfigViewModel {
    
    /// The channels available to select from
    private var vmeshWhiteListChannels: [Int] {
        return vmeshConfig.vmesh_allowed_whitelist_chans
    }
    
    // Channels that have been white listed for the selected AP
    var selectedWhiteListChannels: [Int] {
        get {
            if updatedWhiteListChannels != nil {
                return updatedWhiteListChannels!
            }
            
            let selectedWhiteListChannels = vmeshConfig.vmesh_auto_select_channels
            return selectedWhiteListChannels
        }
        set {
            updatedWhiteListChannels = newValue
            vmeshConfig.vmesh_auto_select_channels = newValue
        }
    }
    
    func whiteListOptions() -> [PickerItem] {
        var items = [PickerItem]()
        
        for value in vmeshWhiteListChannels {
            let ticked = selectedWhiteListChannels.contains(value) ? true : false
            items.append(PickerItem(title: "\(value)", isTicked: ticked))
        }
        
        return items
    }
    
    /// Updates the access channel and returns bool indicating if there has been a change
    /// - Parameter selectionText: The text description of the channel. Taken from the picker selection
    /// - Returns: If there has been an update
    func updateChannelChanges(selectionText: String?) {
        
        // There are 3 types of changes here...
        // 1. Moving from manual to auto
        // 2. Moving from auto to manual
        // 3. Moving from Manual to Manual
        
        guard let selectionText = selectionText else {
            return
        }
        
        // 1. Check if we have selected automatic, set the accessXAcs to true
        let acsState = vmeshAcs
        if selectionText == automaticSelectionOptionString && !acsState{
            vmeshAcs = true
            
            return
        }
        
        // 2. If the setting was auto and the new setting is manual
        if acsState && selectionText != automaticSelectionOptionString {
            vmeshAcs = false
            
            if let channel = Int(selectionText) {
                vmeshConfig?.vmesh_channel = channel
            }
            
            return
        }
        
        // 3. If we are switching from manual channel to manual channel
        if let v = Int(selectionText) {
            if v != vmeshConfig.vmesh_channel {
                vmeshConfig.vmesh_channel = v
                vmeshAcs = false
                
                return
            }
        }
    }
}

// MARK: - VHM 1346 - Show / hide channel configuration
extension VmeshConfigViewModel {
    var showChannelSelection: Bool {
        guard let nodeCapabilities = HubDataModel.shared.baseDataModel?.nodeCapabilitiesConfig else {
            return false
        }
        
        // If we have VMesh capability then we get into come complex checking
        if nodeCapabilities.hasVmeshCapability {
            if let r =  showChannelConfigForMeshRadioAvailable {
                return !(r && isMN)
            }
        }
        
        // If we do not have any vmesh capability revert to default behaiviour
        
        // If its an MEN show it
        if !isMN { return true }
        
        return selectedWLanOperationalOption == .auto || selectedWLanOperationalOption == .start
    }
    
    /// If we return nil then fall through to the default behaivour
    var showChannelConfigForMeshRadioAvailable: Bool? {
        // Get a new instance of vmesh
        guard let vmeshConfig = HubDataModel.shared.baseDataModel?.vmeshConfig else {
            return nil
        }
        
        if !(bdm?.nodeCapabilitiesConfig?.hasVmeshCapability ?? false) {
            return false
        }
        
        let localControl = VmeshConfig.WanOperationalOption.fromString(str: vmeshConfig.vmesh_local_control)
        switch localControl {
        case .disabled: // Locked
            return false
        case .auto:
            return showForVmeshLocalControlAuto
        case .join:
            return true // But will be read only
        case .start:
            return true
        }
    }
    
    private var showForVmeshLocalControlAuto: Bool {
        guard let mode = HubDataModel.shared.baseDataModel?.nodeStatusConfig?.vmeshOperatingMode else {
            return false
        }
        
        switch mode {
        case .wiredOnly:
            return false
        case .wirelessStart:
            return true
        case .wirelessJoin: // But will be read only
            return true
        }
    }
    
    var channelSelectionReadOnly: Bool {
        // Get a new instance of vmesh
        guard let vmeshConfig = HubDataModel.shared.baseDataModel?.vmeshConfig else {
            return false
        }
        
        let localControl = VmeshConfig.WanOperationalOption.fromString(str: vmeshConfig.vmesh_local_control)
        switch localControl {
        case .disabled: // Locked
            return false
        case .auto:
            return readonlyForAuto
        case .join:
            return true
        case .start:
            return false
        }
    }
    
    private var readonlyForAuto: Bool {
        guard let mode = HubDataModel.shared.baseDataModel?.nodeStatusConfig?.vmeshOperatingMode else {
            return true // Read only if not a known state
        }
        
        switch mode {
        case .wiredOnly:
            return false
        case .wirelessStart:
            return false
        case .wirelessJoin: // But will be read only
            return true
        }
    }
}

// VHM 1465: Screen adjustments for WDS on iOS and Android VHM
extension VmeshConfigViewModel {
    var hasWdsSupport: Bool {
        nodeCapabilities.wdsSupport
    }

    var ssidAndPasswordFieldsReadonly: Bool {
        hasWdsSupport
    }
}

// VHM-1501 - WDS
extension VmeshConfigViewModel {
    var showWdsRow: Bool {

        if !isMN {
            return false
        }

        let controlMode = vmeshConfig.vmeshLocalControlMode
        let localControlOk = controlMode != .disabled &&
        controlMode != .start

        return localControlOk &&
        nodeCapabilities.wdsSupport &&
        numberNodesConnected > 0
    }

    var wdsNodeValueText: String {
        guard let wdsDetails else { return "" }
        return wdsDetails.nodesConnectedString
    }

    private var numberNodesConnected: Int {
        guard let nodes = meshWdsTopologyConfig?.nodes else {
            return 0
        }

        return nodes.count
    }
}
